if exists('g:foldline') | finish | endif

function OpenBuffer()
  echo "opening buffer"
  lua require'outline'.open_buffer()
endfunction
