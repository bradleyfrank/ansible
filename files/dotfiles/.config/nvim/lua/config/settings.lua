-- line numbering
vim.opt.nu = true
vim.opt.relativenumber = true

-- set tab spaces to 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.expandtab = true

-- hand off undoing to undotree plugin and don't keep a swapfile
vim.opt.swapfile = false
vim.opt.backup = false
vim.undodir = os.getenv("HOME") .. "/.vim.undodir"
vim.opt.undofile = true

-- set incremental search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- fast update time
vim.opt.updatetime = 50

-- color column to 100 characters
vim.opt.colorcolumn = "100"

-- filetype trigger
vim.opt.filetype='on'

-- copy to system clipboard
vim.api.nvim_set_option("clipboard", "unnamed")
