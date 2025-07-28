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
            vim.keymap.set("n", "<leader>fo", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<leader>fd", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<leader>go", require('telescope.builtin').live_grep)
            vim.keymap.set("n", "<leader>ls", require('telescope.builtin').buffers)
            vim.keymap.set("n", "<leader>bo", require('telescope.builtin').buffers)
            vim.keymap.set("n", "<leader>co", require('telescope.builtin').quickfix)
            vim.keymap.set("n", "<leader>jo", require('telescope.builtin').jumplist)
            vim.keymap.set("n", "<leader>q:", require('telescope.builtin').command_history)
            vim.keymap.set("n", "<leader>q/", require('telescope.builtin').search_history)
            vim.keymap.set("n", "<leader>lo", require('telescope.builtin').loclist)
            vim.keymap.set("n", "<leader>ro", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>grr", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>do", require('telescope.builtin').diagnostics)
            vim.keymap.set("n", "<leader>f?", require('telescope.builtin').builtin)
            vim.keymap.set("n", "<leader>z=", require('telescope.builtin').spell_suggest)
            vim.keymap.set("n", "<leader>/", require('telescope.builtin').current_buffer_fuzzy_find)
            vim.keymap.set("n", "<leader>:h", require('telescope.builtin').help_tags)
            -- Edit Neovim
            vim.keymap.set("n", "<leader>en", function()
                require('telescope.builtin').find_files {
                    cwd = vim.fn.stdpath("config")
                }
            end)
        end
    }
}
