if exists('s:loaded')
   finish
endif
let s:loaded = 1

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
