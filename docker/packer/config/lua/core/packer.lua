vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'rpapallas/illustrate.nvim',
        opt = true,
        requires = {
            {'rcarriga/nvim-notify', opt = true}, 
            {'nvim-lua/plenary.nvim', opt = true}, 
            {'nvim-telescope/telescope.nvim', opt = true}, 
        },
    }
end)

