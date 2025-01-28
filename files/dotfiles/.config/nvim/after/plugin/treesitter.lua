require("nvim-treesitter.configs").setup({
    ensure_installed = {"yaml","lua", "python","go","vimdoc"}, --any language parsers you want installed
    sync_install = false, --if you want to load the parsers synchronously
    auto_install = true,
    highlight = {
        enable = true,
        disable = {}, --include any languages you want to disable highlighting
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KiB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size < max_filesize then
                return true
            end
        end,
        additional_vim_regex_highlighting = false,
    }
})
