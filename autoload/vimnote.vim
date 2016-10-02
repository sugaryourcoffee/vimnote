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


