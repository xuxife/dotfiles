function! myspacevim#sendline()
  call jobsend(g:last_terminal_job_id, trim(getline(".")) . "\n")
endfunction

function! myspacevim#sendselection()
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:inde = indent(l:lnum1)
  for l:i in range(0, len(l:lines)-1)
    let l:lines[l:i] = l:lines[l:i][l:inde:]
  endfor
  call jobsend(g:last_terminal_job_id, add(l:lines, "\n"))
endfunction

function! myspacevim#after() abort
  let g:conceallevel = 0
  let g:vebugger_path_python_lldb = "python3"
  let g:vebugger_path_python = "python3"
  let g:sonokai_style = 'maia'
  " nnoremap <silent> <c-m> :<c-u>call myspacevim#sendline()<cr>
  " vnoremap <silent> <c-m> :<c-u>call myspacevim#sendselection()<cr>
endfunction

