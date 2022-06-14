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

    if !exists("g:easybackup_retain")
        let g:easybackup_retain = 10
    endif

    " Functions {{{
    function! s:GetDir(dir)
        " hash code generation
        let i = 5348
        for c in a:dir
            let cn = char2nr(c)
            let i = (cn * 32) + cn + i
        endfor
        return g:easybackup_dir . '/' . fnamemodify(a:dir, ':t') . '-' . string(i)
    endfunction

    function! s:GetBackups(dir, name)
        return sort(readdir(a:dir, { name -> name =~ a:name . '_\d\{4}_\w\{3}_\d\{1,2}_\d\{2}:\d\{2}:\d\{2}'}))
    endfunction

    function! s:EasyBackup(dir, name)
        let dir = s:GetDir(a:dir)
        if !isdirectory(dir)
            call mkdir(dir, 'p', 0o755)
        endif
        let backups = s:GetBackups(dir, a:name)
        if len(backups) >= g:easybackup_retain
            let c = len(backups) - g:easybackup_retain + 1
            let i = 0
            while i < c
                call delete(dir . '/' . backups[i])
                let i += 1
            endwhile
        endif
        exe 'set backupext=_' . strftime("%Y_%b_%d_%T")
        exe 'set backupdir=' .  dir
    endfunction

    function! s:EasyRestore(dir, name)
        if strlen(a:name) == 0
            echo 'Not file buffer'
            return
        endif
        let dir = s:GetDir(a:dir)
        let backups = s:GetBackups(dir, a:name)
        if len(backups) == 0
            echo 'No backups'
            return
        endif
        let message = 'Select backup to restore for ' . a:name . "\n"
        let i = 1
        for file in backups
            let message .= string(i) . ') ' . substitute(strpart(file, strlen(a:name) + 1), '_', ' ', 'g') . "\n"
            let i += 1
        endfor
        let message .= string(i) . ") Current file\n"
        let r = str2nr(input(message))
        redraw
        if r > 0 && r <= len(backups)
            let backup = readfile(dir . '/' . backups[r-1])
            normal! gg_dG
            exe backup->appendbufline('%', 0)
            echo 'Backup loaded from file ' . backups[r-1]
        elseif r == len(backups) + 1
            silent edit!
            echo 'Current file restored'
        else
            echo 'No backup selected'
        endif
    endfunction
    " }}}

    set writebackup
    set backup
    autocmd BufWritePre * :call s:EasyBackup(expand('<afile>:p:h'), expand('<afile>:p:t'))
    command! -nargs=0 EasyRestore call <SID>EasyRestore(expand('%:p:h'), expand('%:p:t'))
    let s:easybackup_loaded = 1
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:

