-- ########
-- Keybinds
-- ########

-- Leader Key
-- ----------
vim.g.mapleader = " "

-- Marks
-- -----
vim.keymap.set("n", "<Leader>'h", "<cmd>edit ~/.bash_history<CR>")

-- File Explorer
-- -------------
vim.keymap.set("n", "<Leader>fe", "<cmd>Ex<CR>")

-- Buffer
-- ------
vim.keymap.set("n", "<Leader>bn", "<cmd>bnext<CR>")
vim.keymap.set("n", "<Leader>bp", "<cmd>bprevious<CR>")
vim.keymap.set("n", "<Leader>bd", "<cmd>bdelete<CR>")
--vim.keymap.set("n", "<Leader>bg", "<cmd>ls<CR>:b<space>")  -- Not needed due to telescope

-- Quickfix list
-- -------------
vim.keymap.set("n", "<Leader>cn", "<cmd>cnext<CR>")
vim.keymap.set("n", "<Leader>cp", "<cmd>cprev<CR>")
vim.keymap.set("n", "<Leader>co", "<cmd>copen<CR>")
vim.keymap.set("n", "<Leader>cc", "<cmd>cclose<CR>")

-- Keep yanked (Delete)
-- --------------------
vim.keymap.set("n", "<Leader>d", "\"_d")
vim.keymap.set("v", "<Leader>d", "\"_d")

-- Other keybinds
-- --------------
-- Is default on nvim
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "J", "J^")
vim.keymap.set("n", "<leader>+x", "<cmd>!chmod +x %<CR>")

-- Clipboard
-- ---------
vim.keymap.set({"n", "v"}, "<Leader>y", "\"+y")
vim.keymap.set("n", "<Leader>Y", "\"+y$")
vim.keymap.set({"n", "v"}, "<Leader>p", "\"+p")
vim.keymap.set({"n", "v"}, "<Leader>P", "\"+P")

-- Movement
-- --------
-- Windows
--vim.keymap.set("n", "<C-h>", "<C-w>h")
--vim.keymap.set("n", "<C-j>", "<C-w>j")
--vim.keymap.set("n", "<C-k>", "<C-w>k")
--vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Center line after movement
--vim.keymap.set("n", "n", "nzz")
--vim.keymap.set("n", "N", "Nzz")
--vim.keymap.set("n", "<C-d>", "<C-d>zz")
--vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Tabs (Note: Using raw <Tab> will mess up: Ctrl + i)
--vim.keymap.set("n", "<Leader><Tab>", "gt")
--vim.keymap.set("n", "<Leader><S-Tab>", "gT")
