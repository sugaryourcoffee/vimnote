" formats a table like structure to a pandoc multiline table
function! FormatTable()
  normal `<y`>
  let selection = @0
  let lines = split(selection, '\n')

  " split up each line into columns
  let line_columns = []
  for line in lines
    call add(line_columns, map(split(line, '|'), 'vimnote#Trim(v:val)')) 
  endfor

  " group the lines' columns
  let columns = []
  for line_column in line_columns
    let i = 0
    for column in line_column
      if len(columns) < i + 1
        call add(columns, [column])
      else 
        call add(columns[i], column)
      endif
      let i += 1
    endfor
  endfor

  " determine max width for each column
  let max_widths = []
  for column in columns
    call add(max_widths, max(map(column, 'len(v:val)')))
  endfor
  
  " calculate the column widths so the table won't exceed 80 characters
  let col_widths = []
  execute 'let col_widths_total = ' . join(max_widths, '+')
  let col_count = len(columns)
  let table_width = 80 - col_count 
  for max_width in max_widths
    call add(col_widths, 
           \ float2nr(round(1.0*max_width/col_widths_total*table_width)))
  endfor

  " split up each column into multiple rows so a column won't exceed the 
  " calculated column width
  let row_idx = 0
  for line_column in line_columns 
    let col_idx = 0
    for column in line_column
      let line_columns[row_idx][col_idx] = SplitColumn(column, 
                                                     \ col_widths[col_idx])
      let col_idx += 1
    endfor 
    let row_idx += 1
  endfor

  " create the new multiline table
  let table = [repeat('-', 80)]
  let line_column_idx = 0
  for line_column in line_columns
    let max_rows = max(map(copy(line_column), 'len(v:val)'))
    let row_idx = 0
    while row_idx < max_rows
      let table_row = ""
      let col_idx = 0
      while col_idx < len(line_column)
        if len(table_row) > 0
          let table_row .= " "
        endif
        let table_row .= get(line_column[col_idx], row_idx, 
                       \ repeat(' ', col_widths[col_idx])) 
        let col_idx += 1
      endwhile 
      call add(table, table_row) 
      let row_idx += 1  
    endwhile
    if line_column_idx > 1 && line_column_idx < len(line_columns) - 1
      call add(table, " ")
    endif
    let line_column_idx += 1
  endfor
  call add(table, repeat('-', 80))
  call add(table, " ")

  " finally replace the visually selected text with the newly formatted table
  let current_row   = getpos("'<")[1]
  let end_row     = getpos("'>")[1]
  for row in table
    if current_row < end_row
      call setline(current_row, row)
    else
      call append(current_row - 1, row)
    end
    let current_row += 1
  endfor
  
endfunction

" split column into multiple rows so the column will fit into the column width
function! SplitColumn(column, width)
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
      call extend(words, SplitWord(word, a:width), index(words, word) + 1)
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
function! SplitWord(word, width)
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
    call add(word_chunks, a:word[pos:pos+a:width-1])
    let pos += a:width
    let chunks -= 1
  endwhile
  return word_chunks
endfunction

" creates a PDF from the currently used file and writing it to
" g:notes_dir/pdf/ with the name of the file
function! CreatePDF()
  let pdf_dir = g:notes_dir . 'pdf/'
  let outfile = pdf_dir . split(fnamemodify(@%, ':t'), 'md')[0] . 'pdf'
  let command = 'pandoc ' . @% . ' -f markdown -s -o ' . outfile
  let message = system(command)[:-2]
  
  if message == ''
    let message = 'created ' . outfile
  endif

  echomsg '[vimnote] ' . message
endfunction
command! WritePDF call CreatePDF()

" extract tasks annotated with '@tasks|' where '|' is an example of a
" spearator. See more about syc-task at 
" https://rubygems/sugaryourcoffee/syc-task.
function! ExtractTasks()
  let command = 'syctask scan ' . @%
  let result = split(system(command), '\n')

  echomsg '[vimnote] ' . message[0]
endfunction
command! ScanTasks call ExtractTasks()

" search for the word 'word' and populating the result in the quickfix list
function! SearchWord(word)
  let command   = 'grep -rn ' . a:word . ' ' . g:notes_dir
  let condition = "\v^\s+$"
  let message   = 'Search ' . a:word . ' word not found'
  call vimnote#ExecuteSearch(command, condition, message)
endfunction
command! -nargs=1 FindWord call SearchWord(<q-args>)

" search for the file 'filename' and populating the result in the quickfix
" list
function! SearchFiles(filename)
  let command = 'find ' . g:notes_dir . ' -type f -name "' .
                   \ a:filename . '" | xargs file | sed "s/:/:1:/"'
  let condition = 'Usage: '
  let message   = 'Search ' . a:filename . ' file not found'
  call vimnote#ExecuteSearch(command, condition, message)
endfunction
command! -nargs=1 FindFiles call SearchFiles(<q-args>)

" Load a template if a file with the extension '.mom.md' is opened and file
" does not exist
function! CreateOrOpenFile(name)
  let path = &path
  execute 'set path+=' . expand(g:notes_dir)
  let existing = findfile(a:name)
  if !empty(existing)
    execute 'silent bd! ' . @%
    execute 'edit! ' . existing
  else
    0r ~/.vim/bundle/vimnote/templates/mom.md
  endif
  let &path = path
endfunction
autocmd BufNewFile *.mom.md nested call CreateOrOpenFile(expand('<afile>'))

" Mappings to jump to and replace the place holders in the template
nnoremap <c-j> /<+.\{-1,\}+><cr>c/+>/e<cr>
inoremap <c-j> <ESC>/<+.\{-1,}+><cr>c/+>/e<cr>

" Intercept the write command for '.mom.md' and save it to the 'notes_dir'
function! SaveToNotesDir()
  if expand(@%) == expand(g:notes_dir) . expand("%:p:t")
    write!
  else
    let original_buffer = @%
    execute 'save! ' . g:notes_dir . expand("%:p:t")
    set nomodified
    execute 'silent bd! ' . original_buffer
  endif
endfunction
autocmd BufWriteCmd *.mom.md call SaveToNotesDir()

