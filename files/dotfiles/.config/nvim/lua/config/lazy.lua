local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","

local plugins = {
    {
      "nvim-lua/plenary.nvim",
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate"
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = '0.1.6',
      requires = {{"nvim-lua/plenary.nvim"}}
    },
		{
			"nvim-telescope/telescope-file-browser.nvim",
			dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
		},
    {
      "Tsuzat/NeoSolarized.nvim",
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
        vim.cmd [[ colorscheme NeoSolarized ]]
      end
    },
    {
      "mbbill/undotree"
    },
    {
      "tpope/vim-fugitive"
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" }
    }
}

require("lazy").setup(plugins, {})
