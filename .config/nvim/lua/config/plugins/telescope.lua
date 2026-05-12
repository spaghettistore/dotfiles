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
                    find_files = {theme = "ivy"},
                    live_grep = {theme = "ivy"},
                    current_buffer_fuzzy_find = {theme = "ivy"},
                    grep_string = {theme = "ivy"}
                },
                extensions = {
                    fzf = {}
                }
            }

            require('telescope').load_extension('fzf')

            vim.keymap.set("n", "<leader>fd", require('telescope.builtin').find_files, {desc = ":Telescope find_files"})
            vim.keymap.set("n", "<leader>Fd", function() require('telescope.builtin').find_files {hidden=true} end, {desc = ":Telescope find_files hidden=true"})
            vim.keymap.set("n", "<leader>fa", function() require('telescope.builtin').find_files {hidden=true} end, {desc = ":Telescope find_files hidden=true"})
            vim.keymap.set("n", "<leader>f.", function() require('telescope.builtin').find_files {cwd="%:h"} end, {desc = ":Telescope find_files cwd=%:h"})
            vim.keymap.set("n", "<leader>F.", function() require('telescope.builtin').find_files {hidden=true, cwd="%:h"} end, {desc = ":Telescope find_files hidden=true cwd=%:h"})
            vim.keymap.set("n", "<leader>fh", function() require('telescope.builtin').find_files {cwd = "$HOME"} end, {desc = ":Telescope find_files cwd=~"})
            vim.keymap.set("n", "<leader>Fh", function() require('telescope.builtin').find_files {hidden=true, cwd = "$HOME"} end, {desc = ":Telescope find_files hidden=true cwd=~"})
            vim.keymap.set("n", "<leader>fi", function() require('telescope.builtin').find_files {cwd= "$HOME/inbox" } end, {desc = ":Telescope find_files cwd=~/inbox"})
            vim.keymap.set("n", "<leader>fp", function() require('telescope.builtin').find_files {cwd = "$HOME/projects"} end, {desc = ":Telescope find_files cwd=~/projects"})
            vim.keymap.set("n", "<leader>fr", function() require('telescope.builtin').find_files {cwd = "$HOME/resources"} end, {desc = ":Telescope find_files cwd=~/resources"})
            vim.keymap.set("n", "<leader>fc", function() require('telescope.builtin').find_files {cwd = "$HOME/resources/code"} end, {desc = ":Telescope find_files cwd=~/resources/code"})
            vim.keymap.set("n", "<leader>fD", function() require('telescope.builtin').find_files {cwd="$HOME/resources/dotfiles", hidden=true} end, {desc = ":Telescope find_files cwd=~/resources/dotfiles hidden=true"})
            vim.keymap.set("n", "<leader>sg", require('telescope.builtin').live_grep, {desc = ":Telescope live_grep"})
            vim.keymap.set('n', '<leader>Sg',
                function()
                    require("telescope.builtin").live_grep({
                        additional_args = function() return {"--hidden"} end
                    })
                end,
                {desc = "Telescope Live Grep hidden=true"})
            vim.keymap.set("n", "<leader>s.", function() require('telescope.builtin').live_grep {cwd="%:h"} end, {desc = ":Telescope live_grep cwd=%:h"})
            vim.keymap.set('n', '<leader>S.',
                function()
                    require("telescope.builtin").live_grep({
                        additional_args = function() return {"--hidden"} end,
                        cwd="%:h"
                    })
                end,
                {desc = "Telescope Live Grep hidden=true cwd=%:h "})
            vim.keymap.set("n", "<leader>sb", function() require('telescope.builtin').grep_string {grep_open_files=true, search=""} end, {desc = "Telescope Live Grep current open buffers"})
            vim.keymap.set("n", "<leader>/", require('telescope.builtin').current_buffer_fuzzy_find, {desc = ":Telescope current_buffer_fuzzy_find"})
            vim.keymap.set("n", "<leader>ls", require('telescope.builtin').buffers, {desc = ":Telescope buffers"})
            vim.keymap.set("n", "<leader>,", require('telescope.builtin').buffers, {desc = ":Telescope buffers"})
            vim.keymap.set("n", "<leader>q/", require('telescope.builtin').search_history, {desc = ":Telescope search_history"})
            vim.keymap.set("n", "<leader>s/", require('telescope.builtin').search_history, {desc = ":Telescope search_history"})
            vim.keymap.set("n", "<leader>q:", require('telescope.builtin').command_history, {desc = ":Telescope command_history"})
            vim.keymap.set("n", "<leader>sc", require('telescope.builtin').command_history, {desc = ":Telescope command_history"})
            vim.keymap.set("n", "<leader>s:", require('telescope.builtin').command_history, {desc = ":Telescope command_history"})
            vim.keymap.set("n", "<leader>gr", require('telescope.builtin').lsp_references, {desc = ":Telescope lsp_references"})
            vim.keymap.set("n", "<leader>sd", require('telescope.builtin').diagnostics, {desc = ":Telescope diagnostics"})
            vim.keymap.set("n", "<leader>sq", require('telescope.builtin').quickfix, {desc = ":Telescope quickfix"})
            vim.keymap.set("n", "<leader>sl", require('telescope.builtin').loclist, {desc = ":Telescope loclist"})
            vim.keymap.set("n", "<leader>sj", require('telescope.builtin').jumplist, {desc = ":Telescope jumplist"})
            vim.keymap.set("n", "<leader>s\"", require('telescope.builtin').registers, {desc = ":Telescope registers"})
            vim.keymap.set("n", "<leader>sm", require('telescope.builtin').marks, {desc = ":Telescope marks"})
            vim.keymap.set("n", "<leader>fg", require('telescope.builtin').git_files, {desc = ":Telescope git_files"})
            vim.keymap.set("n", "<leader>gs", require('telescope.builtin').git_status, {desc = ":Telescope git_status"})
            vim.keymap.set("n", "<leader>gS", require('telescope.builtin').git_stash, {desc = ":Telescope git_stash"})
            vim.keymap.set("n", "<leader>sr", require('telescope.builtin').oldfiles, {desc = ":Telescope oldfiles"})
            vim.keymap.set("n", "<leader>sR", require('telescope.builtin').resume, {desc = ":Telescope resume"})
            vim.keymap.set("n", "<leader>sk", require('telescope.builtin').keymaps, {desc = ":Telescope keymaps"})
            vim.keymap.set("n", "<leader>sh", require('telescope.builtin').help_tags, {desc = ":Telescope help_tags"})
            vim.keymap.set("n", "<leader>sM", require('telescope.builtin').man_pages, {desc = ":Telescope man_pages"})
            vim.keymap.set("n", "<leader>f?", require('telescope.builtin').builtin, {desc = ":Telescope builtin"})
            vim.keymap.set("n", "<leader>s?", require('telescope.builtin').builtin, {desc = ":Telescope builtin"})
            --vim.keymap.set("n", "<leader>uC", function() require('telescope.builtin').colorscheme {enable_preview=true} end, {desc = ":Telescope colorscheme enable_preview=true"})
            vim.keymap.set("n", "<leader>z=", require('telescope.builtin').spell_suggest, {desc = ":Telescope spell_suggest"})
            vim.keymap.set("n", "<leader>en", function() require('telescope.builtin').find_files {cwd = vim.fn.stdpath("config")} end, {desc = "Telescope edit nvim config files"})
        end
    }
}
