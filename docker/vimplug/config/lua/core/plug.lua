local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
    Plug 'rcarriga/nvim-notify'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
vim.call('plug#end')
