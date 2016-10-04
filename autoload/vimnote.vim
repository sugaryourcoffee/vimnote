" helper function to execute a search. Requires the search 'command', the
" 'condition' that indicates unsuccessful search and a 'message' for that case
function! vimnote#ExecuteSearch(command, condition, message)
  let quickfix_file = tempname()
  let result = system(a:command)[:-3]

  if result == "" || result =~ a:condition
    echomsg '[vimnote] ' . a:message
  else
    let write_command = 'echo "' . result . '" > ' . quickfix_file
    echomsg system(write_command)
    execute "cfile " . quickfix_file
    copen
  endif

  call delete(quickfix_file)
endfunction

" helper to remove white spaces at the beginning and the end of the 'value'
function! vimnote#Trim(value)
  return substitute(a:value, '\v^\s*|\s*$', '', 'g')
endfunction

" split column into multiple rows so the column will fit into the column width
function! vimnote#SplitColumn(column, width)
  if a:column =~ "^-*$"
    return [repeat('-', a:width)]
  elseif len(a:column) == a:width
    return [a:column]
  elseif len(a:column) < a:width
    return [a:column . repeat(' ', a:width - len(a:column))]
  endif
  let words = split(a:column)
  let rows = []
  let row = ""
  while len(words) > 0
    let word = words[0]
    if len(word) > a:width
      call extend(words, vimnote#SplitWord(word, a:width), index(words, word) + 1)
    elseif len(row) == 0
      let row = word
    elseif len(row) + 1 + len(word) < a:width
      let row = row . " " . word
    elseif len(row) + 1 + len(word) == a:width
      let row = row . " " . word
      call add(rows, row)
      let row = ""
    else
      let row = row . repeat(' ', a:width - len(row))
      call add(rows, row)
      let row = word
    endif
    call remove(words, 0)
  endwhile
  if len(row) > 0
    let row = row . repeat(' ', a:width - len(row))
    call add(rows, row)
  endif
  return rows
endfunction

" Split word in width chunks
function! vimnote#SplitWord(word, width)
  if len(a:word) <= a:width
    return [a:word]
  endif
  let word_chunks = []
  let chunks = 1.0 * len(a:word) / a:width
  if floor(chunks) < chunks
    let chunks = floor(chunks) + 1
  endif
  let chunks = float2nr(chunks) 
  let pos = 0
  while chunks > 0
    call add(word_chunks, a:word[pos : pos+a:width-1])
    let pos += a:width
    let chunks -= 1
  endwhile
  return word_chunks
endfunction

