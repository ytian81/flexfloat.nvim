if exists('g:flexfloat_loaded')
  finish
endif
let g:flexfloat_loaded = 1

" Single command that chooses the appropriate method
command! -nargs=? YaziExplorer lua require('flexfloat').open_explorer(<f-args>)

" Single key mapping
nnoremap <leader>e <cmd>lua require('flexfloat').open_explorer(vim.fn.expand('%:p'))<CR>

" Auto commands
augroup YaziFileExplorer
    autocmd!
    autocmd VimEnter * ++once silent! autocmd! FileExplorer
    autocmd VimEnter * ++once lua require('flexfloat').handle_directory_open()
augroup END
