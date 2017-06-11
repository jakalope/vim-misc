if exists('s:loaded')
   finish
endif
let s:loaded = 1

" Vim runs .vimrc before knowing how many columns we'll have, so to set the
" number of splits correctly upon startup, we need to set an autocmd on the
" VimEnter event, which happens after the number of columns are known.
if exists('g:util_min_split_cols')
    autocmd VimEnter * call jakalope#utilities#vsplits(g:util_min_split_cols)
endif

" I find this useful because a lot of my file-opener tricks rely on vim being
" in the root of my workspace and it turns out a lot of plugins disrupt that.
if exists('g:util_workspace_dir')
    call jakalope#utilities#lock_cwd(g:util_workspace_dir)
endif
