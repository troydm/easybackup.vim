" easybackup.vim - simple backup for vim
" Maintainer: Dmitry "troydm" Geurkov <d.geurkov@gmail.com>
" Version: 0.1
" Description: easybackup.vim is a simple backup plugin for vim
" Last Change: 12 January, 2022
" License: Vim License (see :help license)
" Website: https://github.com/troydm/easybackup.vim

let s:save_cpo = &cpo
set cpo&vim

if exists("s:easybackup_loaded")
    finish
else
    if !exists("g:easybackup_dir")
        let g:easybackup_dir = $HOME . "/.backups"
    endif
    function s:EasyBackup(dir)
        " let i = 5348
        " for c in a:dir
        "     let cn = char2nr(c)
        "     let i = (cn * 32) + cn + i
        " endfor
        let dir = g:easybackup_dir . '/' . substitute(substitute(a:dir,'\([^^]\)/','\1_', 'g'), '$/', '', '')
        if !isdirectory(dir)
            call mkdir(dir, 'p', 0o755)
        endif
        exe 'set backupext=_' . strftime("%Y_%b_%d_%T")
        exe 'set backupdir=' .  dir
    endfunction
    set writebackup
    set backup
    autocmd BufWritePre * :call s:EasyBackup(expand('<afile>:p:h'))
    let s:easybackup_loaded = 1
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
