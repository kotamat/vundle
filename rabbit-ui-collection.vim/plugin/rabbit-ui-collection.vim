
scriptencoding utf-8

if exists("g:loaded_rabbit_ui_collection")
  finish
endif
let g:loaded_rabbit_ui_collection = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:error(msg)
  echohl Error
  echomsg printf('[rabbit-ui-collection] %s', a:msg)
  echohl NONE
endfunction
function! s:option()
  return get(g:, 'rabbit_ui_collection_option', {
        \   'box_left' : &columns / 10 * 1,
        \   'box_right' : &columns / 10 * 9,
        \   'box_top' : &lines / 5 * 2,
        \   'box_bottom' : &lines / 5 * 3,
        \ })
endfunction

function! s:rabbit_ui_collection_choice_buffer()
  redir => joined_lines
  silent! buffers
  redir END
  let lines = split(joined_lines, "\n")
  let x = rabbit_ui#choices('buffers', lines, s:option())
  if !empty(x)
    execute 'buffer ' . matchstr(lines[x['value']], '^\s*\zs\d\+\ze\s')
  endif
endfunction
function! s:rabbit_ui_collection_choice_mark()
  redir => joined_lines
  silent! marks
  redir END
  let lines = split(joined_lines, "\n")[1:]
  let x = rabbit_ui#choices('buffers', lines, s:option())
  if !empty(x)
    execute 'normal `' . matchstr(lines[x['value']], '^\s*\zs[^ ]\+\ze\s')
  endif
endfunction
function! s:rabbit_ui_collection_edit_csv(path)
  let path = expand(a:path)
  if filereadable(path)
    let lines = readfile(path)
    let rtn_value = rabbit_ui#gridview(map(lines,'split(v:val,",",1)'))
    if empty(rtn_value)
    else
      call writefile(map(rtn_value['value'], "join(v:val, ',')") , path)
    endif
  endif
endfunction

command! -nargs=1 -complete=file RabbitUICollectionEditCSV        :call <sid>rabbit_ui_collection_edit_csv(<q-args>)
command! -nargs=0                RabbitUICollectionChoiceMark     :call <sid>rabbit_ui_collection_choice_mark()
command! -nargs=0                RabbitUICollectionChoiceBuffer   :call <sid>rabbit_ui_collection_choice_buffer()

let &cpo = s:save_cpo
finish

