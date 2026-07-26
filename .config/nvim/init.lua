require("set_options")
require("keybinds_keymaps")

-- Plugins
require("config.lazy")
vim.cmd.colorscheme "gruvbox"

-- Version 0.12 Change:
-- Enable treesitter
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'bash', 'sh', 'c', 'c++', 'cpp', 'css', 'csv', 'desktop', 'git_config',
        'gitcommit', 'gitignore', 'html', 'ini', 'javascript', 'json',
        'lua', 'markdown', 'markdown_inline', 'python', 'query',
        'rasi', 'readline', 'ssh_config', 'toml', 'vim',
        'vimdoc', 'xml', 'svelete'
    },
    callback = function()
        vim.treesitter.start()
    end,
})
