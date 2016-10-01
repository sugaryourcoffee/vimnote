" formats a table like structure to a pandoc multiline table
function! FormatTable()
  normal `<y`>
  let selection = @0
  let lines = split(selection, '\n')
"  echomsg "---" . join(lines, ';') . "..."
  let line_columns = []
  for line in lines
    call add(line_columns, split(line, '|'))
  endfor
"  echomsg join(line_columns, ';')
  let columns = []
  for line_column in line_columns
    let i = 0
    for column in line_column
      let column = substitute(column, '\v^\s*|\s*$', '', 'g')
      "echomsg ">>" . column . "<<"
      if len(columns) < i + 1
        call add(columns, [column])
      else 
        call add(columns[i], column)
      endif
      " echomsg join(columns[i], ' | ')
      let i += 1
    endfor
  endfor
  let widths = []
  for column in columns
    call add(widths, max(map(column, 'len(v:val)')))
  endfor
  echomsg join(widths, ',')
  
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

  echomsg '[vimnote] . message[0]
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

