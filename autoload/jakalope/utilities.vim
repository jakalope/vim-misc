if exists('g:vim_utilities_loaded')
   finish
endif
let g:vim_utilities_loaded = 1

" Detect filetype in each tab.
command! Detect :tabdo exec 'filetype detect'

" Reload all windows, tabs, buffers, etc.
command! Reload :call s:Reload()

" Remove all non-terminal buffers.
command! Clear :call jakalope#utilities#clear_non_terminals()
function! jakalope#utilities#clear_non_terminals()
    bufdo call s:BdeleteNonTerm()
    windo b1
    wincmd b
    if has("nvim")
        b2
    endif
    stopinsert
endfunction

" Format the current file using external prog `formatter`.
function! jakalope#utilities#format(formatter)
    let view = winsaveview()
    exec 'silent! undojoin | keepmarks keepjumps %!'.a:formatter
    call winrestview(view)
endfunction

" Generates maximum number of vertical splits with at least `col` columns each.
function! jakalope#utilities#vsplits(col)
    silent only!                         " close all splits but this one
    let l:splits =  &columns / a:col - 1 " the number of splits to create
    while l:splits > 0                   " create the splits
        vsplit
        let l:splits -= 1
    endwhile
    wincmd =                             " set all splits to equal width
endfunction

" Locks your working directory to `dir`.
function! jakalope#utilities#lock_cwd(dir) 
    augroup lock_cwd  " make this function replaceable upon sourcing
        " remove previous definition
        autocmd!
        if !empty(a:dir)   " only generate the autocmd if we have a real input
            " change directories to `dir`, then lock us into that directory
            exec 'cd '.a:dir
            exec 'autocmd DirChanged * cd '.a:dir
        endif
    augroup end
endfunction

" Find a companion file, if it exists (e.g. test.h -> test.cpp)
function! jakalope#utilities#companion()
    let l:fn_ext = expand("%:e")
    let l:fn_root = expand("%:r")
    let l:c_ext = ["cpp", "c", "cc", "cx", "cxx"]
    let l:h_ext = ["h", "hpp", "hxx", "hh"]
    if index(l:c_ext, l:fn_ext) != -1
        let l:fns = jakalope#utilities#sequence(l:fn_root, l:h_ext)
        for l:fn in l:fns
            let l:companion_file = jakalope#utilities#git_ls(l:fn)
            if l:companion_file != ""
                return l:companion_file
            endif 
        endfor
    elseif index(l:h_ext, l:fn_ext) != -1
        let l:fns = jakalope#utilities#sequence(l:fn_root, l:c_ext)
        for l:fn in l:fns
            echom l:fn
            let l:companion_file = jakalope#utilities#git_ls(l:fn)
            echom l:companion_file
            if l:companion_file != ""
                return l:companion_file
            endif 
        endfor
    endif
    return expand("%")
endfunction

" Source vimrc, clear and reload scripts, clear and reset options.
command! Src call jakalope#utilities#source()
function! jakalope#utilities#source()
    " Reset all options and mappings.
    set all&
    mapclear | mapclear <buffer> | mapclear! | mapclear! <buffer>

    " Source vimrc
    source ~/.vimrc

    " Reload scripts that were unmapped at the top of this file.
    unlet! g:vim_utilities_loaded
    unlet! g:loaded_smartword
    unlet! g:command_t_loaded
    unlet! g:loaded_abolish
    ReloadScript ~/.vim/bundle/vim-smartword/plugin/smartword.vim
    ReloadScript ~/.vim/bundle/command-t/plugin/command-t.vim
    ReloadScript ~/.vim/bundle/vim-abolish/plugin/abolish.vim

    " Re-detect filetypes.
    Detect
endfunction

function! jakalope#utilities#sequence(prefix, list)
    let l:out = []
    for item in a:list
        let l:out += [a:prefix.".".item]
    endfor
    return l:out
endfunction

function! jakalope#utilities#git_ls(fn)
    let l:git_ls_command = "git ls-files --full-name ".a:fn
    exec "let l:companion_file = system(\"".l:git_ls_command."\")"
    return l:companion_file
endfunction

"
" Private functions
"

function! s:IsATerm()
    if bufname("%")=~#"term://.*"
        return 1
    endif
    return 0
endfunction

function! s:BdeleteNonTerm()
    if !s:IsATerm()
        Bdelete
    endif
endfunction

function! s:Reload()
    setlocal autoread
    checktime
    set autoread<
endfunction

