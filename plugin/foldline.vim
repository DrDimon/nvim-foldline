if exists('g:foldline') | finish | endif

command! FoldlineOpen lua require'outline'.open_buffer()
