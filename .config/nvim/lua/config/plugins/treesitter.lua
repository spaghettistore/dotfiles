return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",

        -- Version 0.12 change, commented out this block
        --config = function()
        --    require'nvim-treesitter.configs'.setup {
        --        ensure_installed = { "python", "bash", "json", "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
        --        sync_install = false,
        --        auto_install = true,
        --        highlight = {
        --            enable = true,
        --            disable = function(lang, buf)
        --                local max_filesize = 100 * 1024 -- 100 KB
        --                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        --                if ok and stats and stats.size > max_filesize then
        --                    return true
        --                end
        --            end,
        --            additional_vim_regex_highlighting = false,
        --        },
        --    }
        --end,

        -- Version 0.12 change:
        -- 'ensure_installed' is no longer a config option.
        -- You call the install API yourself instead.
        -- This init callback diffs against already-installed parsers so it
        -- doesn't reinstall everything on every startup:
        init = function()
          local ensureInstalled = {
              "bash", "c", "cpp", "css", "csv", "desktop", "git_config",
              "gitcommit", "gitignore", "html", "ini", "javascript", "json",
              "lua", "markdown", "markdown_inline", "python", "query",
              "rasi", "readline", "ssh_config", "toml", "vim",
              "vimdoc", "xml"
          }
          local alreadyInstalled = require('nvim-treesitter.config').get_installed()
          local parsersToInstall = vim.iter(ensureInstalled)
            :filter(function(parser)
              return not vim.tbl_contains(alreadyInstalled, parser)
            end)
            :totable()
          require('nvim-treesitter').install(parsersToInstall)
        end,


    }
}
