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
  let result = system(command)

  let message = len(result) == 1 ? result[0] : result[1]
  echomsg '[vimnote] . message 
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

" Load a template if a file '.mom.md' is opened
autocmd BufNewFile *.mom.md 0r ~/.vim/bundle/vimnote/templates/mom.md
" Mappings to jump to and replace the place holders in the template
nnoremap <c-j> /<+.\{-1,\}+><cr>c/+>/e<cr>
inoremap <c-j> <ESC>/<+.\{-1,}+><cr>c/+>/e<cr>

