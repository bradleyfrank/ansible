local ok_status, NeoSolarized = pcall(require, "NeoSolarized")

if not ok_status then
  return
end

NeoSolarized.setup {
  style = "light", -- "dark" or "light"
  transparent = false, -- true/false; Enable this to disable setting the background color
  terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
  enable_italics = true, -- Italics for different hightlight groups (eg. Statement, Condition, Comment, Include, etc.)
  styles = {
    -- Style to be applied to different syntax groups
    comments = { italic = true },
    keywords = { italic = true },
    functions = { bold = true },
    variables = {},
    string = { italic = true },
    underline = true, -- true/false; for global underline
    undercurl = true, -- true/false; for global undercurl
  },
  -- Add specific hightlight groups
  on_highlights = function(highlights, colors)
    -- highlights.Include.fg = colors.red -- Using `red` foreground for Includes
  end,
}
-- Set colorscheme to NeoSolarized
vim.cmd[[colorscheme NeoSolarized]]
