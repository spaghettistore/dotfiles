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
            vim.keymap.set("n", "<leader>fl", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<leader>fd", require('telescope.builtin').find_files)
            vim.keymap.set("n", "<leader>gl", require('telescope.builtin').git_files)
            vim.keymap.set("n", "<leader>lg", require('telescope.builtin').live_grep)
            vim.keymap.set("n", "<leader>ls", require('telescope.builtin').buffers)
            vim.keymap.set("n", "<leader>cl", require('telescope.builtin').quickfix)
            vim.keymap.set("n", "<leader>jl", require('telescope.builtin').jumplist)
            vim.keymap.set("n", "<leader>q:", require('telescope.builtin').command_history)
            vim.keymap.set("n", "<leader>q/", require('telescope.builtin').search_history)
            vim.keymap.set("n", "<leader>ll", require('telescope.builtin').loclist)
            vim.keymap.set("n", "<leader>rl", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>grr", require('telescope.builtin').lsp_references)
            vim.keymap.set("n", "<leader>dl", require('telescope.builtin').diagnostics)
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
            vim.keymap.set("n", "<leader>fh", function()
                require('telescope.builtin').find_files {
                    cwd = "$HOME"
                }
            end)
            vim.keymap.set("n", "<leader>fi", function()
                require('telescope.builtin').find_files {
                    cwd = "$HOME/inbox"
                }
            end)
            vim.keymap.set("n", "<leader>fp", function()
                require('telescope.builtin').find_files {
                    cwd = "$HOME/projects"
                }
            end)
            vim.keymap.set("n", "<leader>fr", function()
                require('telescope.builtin').find_files {
                    cwd = "$HOME/refs"
                }
            end)
        end
    }
}
