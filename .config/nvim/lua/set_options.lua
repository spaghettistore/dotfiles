-- Visual
-- ------
vim.opt.syntax = 'on'
-- Line number
vim.opt.number = true
vim.opt.relativenumber = true
-- Show position in bottom right
vim.opt.ruler = true
-- Show keystrokes
vim.opt.showcmd = true
-- Show mode in bottom left, enabled by default
vim.opt.showmode = true
-- Enable use of mouse
vim.opt.mouse = 'a'
-- Do not let cursor scroll below or above N number of lines when scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false

-- Searching
-- ---------
-- Show matching words during a search
vim.opt.incsearch = true
-- Ignore case sensitivity during search
vim.opt.ignorecase = true
-- Override the ignorecase option if searching for capital letters
vim.opt.smartcase = true
-- Highlight all matching search
vim.opt.hlsearch = false
  -- Bracket/paren/brace jump thing
--vim.opt.showmatch = false

-- Wild Menu
-- ---------
-- Enable auto completion menu after pressing TAB
vim.opt.wildmenu = true
  -- Make wildmenu behave like similar to Bash completion
--vim.opt.wildmode = {list = 'longest'}
-- Wildmenu will ignore files with these extensions
vim.cmd("set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx")
-- Ignore case sensitivity in wildmenu
vim.opt.wildignorecase = true

-- Indent is four spaces instead of tabs
-- -------------------------------------
-- When pressing o O
vim.opt.autoindent = true
-- When pressing enter
vim.opt.smartindent = true
-- Make tab create multispace not ^I or \t
vim.opt.expandtab = true
-- How many spaces is >>
vim.opt.shiftwidth = 4
-- How many spaces is tab
-- Because you have set 'expandtab', all your own files will use spaces for
-- indentation. However, in the outside world, hard TABs are modulo-8.
-- Therefore, to ensure TAB characters in files not written by you aren't
-- displayed with the wrong size, 'tabstop' should never be changed from 8.
vim.opt.tabstop = 8
-- Backspace deletes multispace like tabs
vim.opt.softtabstop = 4

-- Indent Lines
-- ------------
-- If leadmultispace doesn't work, use this
--vim.opt.listchars = {multispace = '┊   ▏   ', trail = '·', extends = '▸', precedes = '◂', nbsp = '␣'}
vim.opt.listchars = {leadmultispace = '┊   ▏   ', trail = '·', extends = '▸', precedes = '◂', nbsp = '␣'}
  -- Extra characters
--vim.cmd("set listchars=eol:¬,space:·,lead:\ ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,leadmultispace:\┊\ \ \ ")
vim.opt.list = true

-- Split
-- -----
-- Ctrl-W Ctrl-N
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Cursor Line
-- -----------
vim.opt.cursorline = true
--vim.opt.cursorcolumn = false
vim.opt.colorcolumn = {80}
--vim.opt.colorcolumn = {80, 120}

-- Netrw
-- -----
vim.g.netrw_banner = 0
--vim.g.netrw_browse_split = 4
--vim.g.netrw_liststyle = 3 -- Tree
-- Number, RelativeLineNumber
vim.g.netrw_bufsettings = 'nu rnu'
--vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.g.netrw_winsize = 25


-- Colors
-- ------
vim.opt.termguicolors = true
vim.o.background = "dark"

-- Misc
-- ----
vim.opt.spell = false
vim.opt.backup = false
--vim.opt.compatible = false  -- This is default for nvim

-- ##########
-- Status bar
-- ##########

vim.o.statusline = " "
-- "%#StatusBuffer#"
    .. "%n "
-- "%#StatusFile#"
    .. "%F "
-- "%#StatusModified#"
    .. "%m "
-- "%#StatusNorm#"
    .. "%="
-- "%#StatusType#"
    .. "%Y"
-- "%#StatusLocation#"
    .. " %l,%c "
-- "%#StatusPercent#"
    .. "%p%% "
