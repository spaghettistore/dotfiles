return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
        },
        config = function()
            require('telescope').setup {
                pickers = {
                    find_files = {
                        theme = "ivy"
                    }
                },
                extensions = {
                    fzf = {}
                }
            }

            require('telescope').load_extension('fzf')

            -- Find Files
            vim.keymap.set("n", "<leader>ff", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<leader>fg", require('telescope.builtin').live_grep)
            vim.keymap.set("n", "<leader>fb", require('telescope.builtin').buffers)
            vim.keymap.set("n", "<leader>fc", require('telescope.builtin').quickfix)
            vim.keymap.set("n", "<leader>fr", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>grr", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>fd", require('telescope.builtin').diagnostics)
            vim.keymap.set("n", "<leader>[d", require('telescope.builtin').diagnostics)
            vim.keymap.set("n", "<leader>]d", require('telescope.builtin').diagnostics)
            vim.keymap.set("n", "<leader>f?", require('telescope.builtin').builtin)
            vim.keymap.set("n", "<leader>z=", require('telescope.builtin').spell_suggest)
            -- Edit Neovim
            vim.keymap.set("n", "<leader>en", function()
                require('telescope.builtin').find_files {
                    cwd = vim.fn.stdpath("config")
                }
            end)
        end
    }
}
