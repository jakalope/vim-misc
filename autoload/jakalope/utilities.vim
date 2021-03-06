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

function! jakalope#utilities#terminal()
    if has('nvim')
        " Support for Neovim
        terminal
        return 1
    elseif has('terminal')
        " Support for Vim8
        terminal ++curwin
        return 1
    endif
    return 0
endfunction

" Generates maximum number of vertical splits with at least `col` columns each.
function! jakalope#utilities#vsplits(col)
    silent only!                         " close all splits but this one
    let l:splits =  &columns / a:col - 1 " the number of splits to create
    let l:i = l:splits
    while l:i > 0                        " create the splits
        vsplit
        let l:i -= 1
    endwhile
    wincmd =                             " set all splits to equal width
    return l:splits
endfunction

function! jakalope#utilities#vsplits_with_terminal(col)
    if jakalope#utilities#vsplits(a:col) > 0
        call jakalope#utilities#terminal()
    endif
endfunction

" Locks your working directory to `dir`.
function! jakalope#utilities#lock_cwd(dir) 
    if has('nvim')
        augroup lock_cwd  " make this function replaceable upon sourcing
            " remove previous definition
            autocmd!
            if !empty(a:dir)   " only generate the autocmd if we have a real input
                " change directories to `dir`, then lock us into that directory
                exec 'cd '.a:dir
                exec 'autocmd DirChanged * cd '.a:dir
            endif
        augroup end
    endif
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
    if has('nvim') && bufname("%")=~#"term://.*"
        " Support for Neovim
        return 1
    elseif has('terminal') && bufname("%")=~&shell
        " Support for Vim8
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

