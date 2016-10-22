" Assign a default notes directory if 'g:notes_dir' doesn't exist
if !exists("g:notes_dir")
  let g:notes_dir = expand("~/vimnote/")
endif

" Create the directory saved in 'g:notes_dir' if it doesn't exist
if !isdirectory(expand(g:notes_dir))
  call mkdir(expand(g:notes_dir) . "pdf", "p")
endif

" Assign a default image directory if 'g:image_dir' doesn't exist
if !exists("g:image_dir")
  let g:image_dir = expand(g:notes_dir . "images")
endif

" Create the image directory saved in 'g:image_dir' if it doesn't exist
if !isdirectory(expand(g:image_dir))
  call mkdir(expand(g:image_dir), "p")
endif

" insert image file from image directory. The image directory can be set in the
" vimrc file
function! InsertImage()
  if !exists("g:image_sequence")
    if v:char == '!'
      let g:image_sequence = v:char
      let g:image_line = line('.')
    endif
  else
    let g:image_sequence .= v:char
    if g:image_line != line('.')
      unlet g:image_sequence
    elseif g:image_sequence =~ '^!\[.\+\]('
      unlet g:image_sequence
      let v:char .= g:image_dir
    endif
  endif
endfunction
autocmd InsertCharPre * call InsertImage()

" formats a table like structure to a pandoc multiline table
function! FormatTable(separator, start_line, end_line)
  let sep = len(a:separator) > 0 ? a:separator : '|'
  let lines = getline(a:start_line, a:end_line)
  
  if a:start_line == a:end_line
    echomsg "[vimnote] --> FormatTable needs a range for formatting a table"
    return
  endif

  " check for a header row
  let header_row = lines[1] =~ '^-\+'
  if header_row == 0
    if lines[0] !~ '^-\+'
      let col_count = len(split(lines[0], sep))
      call insert(lines, '-' . repeat(sep . '-', col_count-1), 0)
    endif
  endif

  " split up each line into columns
  let line_columns = []
  for line in lines
    call add(line_columns, map(split(line, sep), 'vimnote#Trim(v:val)')) 
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
  for acolumn in columns
    call add(max_widths, max(map(acolumn, 'len(v:val)')))
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

  " check if full table width is exploited. If not add rest to smallest column
  execute 'let table_total_width = ' . join(col_widths, '+')
  let table_max_width = 80 - col_count + 1
  if table_total_width < table_max_width
    let col_widths[index(col_widths, 
                 \ min(col_widths))] += table_max_width - table_total_width
  endif

  " split up each column into multiple rows so a column won't exceed the 
  " calculated column width
  let row_idx = 0
  for line_column in line_columns 
    let col_idx = 0
    for column in line_column
      let line_columns[row_idx][col_idx] = vimnote#SplitColumn(column, 
                                                     \ col_widths[col_idx])
      let col_idx += 1
    endfor 
    let row_idx += 1
  endfor

  " create the new multiline table
  if header_row
    let table = [repeat('-', 80)]
  else
    let table = []
  endif

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
    if line_column_idx > (0 + header_row) && 
     \ line_column_idx < len(line_columns) - 1
      call add(table, " ")
    endif
    let line_column_idx += 1
  endfor
  call add(table, repeat('-', 80))

  " finally replace the visually selected text with the newly formatted table
  let current_row   = getpos("'<")[1]
  let end_row     = getpos("'>")[1]
  
  if getline(end_row) !~ '\v^\s*$'
    call add(table, " ")
  endif

  for row in table
    if current_row < end_row
      call setline(current_row, row)
    else
      call append(current_row - 1, row)
    end
    let current_row += 1
  endfor
endfunction
command! -range -nargs=? FormatTable call FormatTable(<q-args>,<line1>,<line2>)

" creates a PDF from the currently used file and writing it to
" g:notes_dir/pdf/ with the name of the file
function! CreatePDF()
  let pdf_dir = g:notes_dir . 'pdf/'
  let outfile = pdf_dir . split(fnamemodify(@%, ':t'), '.md')[0] . '.pdf'
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

  if len(result) > 0
    echomsg '[vimnote] ' . vimnote#GetMessage(result, "-->")
  else
    echomsg '[vimnote] ' . result[0]
  endif
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

" Load a template if a file with the extension '.minutes|.note|.speech' is 
" opened and file does not exist
function! CreateOrOpenFile(name)
  let path = &path
  execute 'set path+=' . expand(g:notes_dir)
  let existing = findfile(a:name)
  if !empty(existing)
    execute 'silent bd! ' . @%
    execute 'edit! ' . existing
  else
    let extension = expand('%:e')
    execute '0r ' . expand("~/.vim/bundle/vimnote/templates/" . extension)
  endif
  let &path = path
endfunction
autocmd BufNewFile *.minutes nested call CreateOrOpenFile(expand('<afile>'))
autocmd BufNewFile *.note    nested call CreateOrOpenFile(expand('<afile>'))
autocmd BufNewFile *.speech  nested call CreateOrOpenFile(expand('<afile>'))

" Mappings to jump to and replace the place holders in the template
nnoremap <c-j> /<+.\{-1,\}+><cr>c/+>/e<cr>
inoremap <c-j> <ESC>/<+.\{-1,}+><cr>c/+>/e<cr>

" Intercept the write command for '.minutes|.note|.speech' and save it to the 
" 'notes_dir'
function! SaveToNotesDir()
  if expand("%:p") == expand(g:notes_dir) . expand("%:p:t")
    write!
  else
    let original_buffer = @%
    execute 'save! ' . g:notes_dir . expand("%:p:t")
    set nomodified
    execute 'silent bd! ' . original_buffer
  endif
endfunction
autocmd BufWriteCmd *.minutes call SaveToNotesDir()
autocmd BufWriteCmd *.note    call SaveToNotesDir()
autocmd BufWriteCmd *.speech  call SaveToNotesDir()

