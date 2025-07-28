" #######
" Options
" #######

" Visual
" ------
syntax on
set background=dark
" Line number
set number
set relativenumber
" Show position in bottom right, enabled by default
set ruler
" Show keystrokes
set showcmd
" Show mode in bottom left, enabled by default
set showmode
" Enable use of mouse
set mouse=a
" Do not let cursor scroll below or above N number of lines when scrolling
set scrolloff=8
set nowrap

" Searching
" ---------
" Show and highlight matching words during a search
set incsearch
" Ignore case sensitivity during search
set ignorecase
" Override the ignorecase option if searching for capital letters
set smartcase
" Highlight all matching search
"set hlsearch
" Bracket/paren/brace jump thing
"set showmatch

" Wild Menu
" ---------
" Enable visual auto completion menu after pressing TAB
set wildmenu
" Make wildmenu behave like similar to Bash completion
"set wildmode=list:longest
" Wildmenu will ignore files with these extensions
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
" Ignore case sensitivity in wildmenu
set wildignorecase

" Indent is four spaces instead of tabs
" -------------------------------------
" When pressing o O
set autoindent
" When pressing enter
set smartindent
" Make tab create multispace not ^I or \t
set expandtab
" How many spaces is >>
set shiftwidth=4
" How many spaces is tab
" Because you have set 'expandtab', all your own files will use spaces for
" indentation. However, in the outside world, hard TABs are modulo-8.
" Therefore, to ensure TAB characters in files not written by you aren't
" displayed with the wrong size, 'tabstop' should never be changed from 8.
set tabstop=8
" Backspace deletes multispace like tabs
set softtabstop=4

" Indent Lines
" ------------
set listchars=leadmultispace:\┊\ \ \ \▏\ \ \ ,tab:→\ ,trail:·,extends:▸,precedes:◂,nbsp:␣
"set listchars=eol:¬,space:·,lead:\ ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:\┊\ \▏\ 
set list

" Split
" -----
" Ctrl-W Ctrl-N
set splitbelow
set splitright

" Cursor Line
" -----------
set cursorline
"set cursorcolumn
set colorcolumn=80
"set colorcolumn=80,120

" Not sure what this even does
"set nocompatible

" Netrw
" -----
let g:netrw_banner = 0
let g:netrw_bufsettings = 'nu rnu'
let g:netrw_winsize = 25


" ######
" Colors
" ######

set termguicolors
colorscheme gruvbox
hi Normal guibg=NONE ctermbg=NONE
hi Comment gui=ITALIC

" ########
" Keybinds
" ########

" Leader key
" ----------
let mapleader = "\<Space>"

" Marks
" -----
noremap <Leader>'h <cmd>edit ~/.bash_history<CR>

" File Explorer
" -------------
noremap <Leader>fe <cmd>Ex<CR>
noremap <Leader>fo :find 

" Buffer
" ------
noremap ]b <cmd>bnext<CR>
noremap [b <cmd>bprevious<CR>
noremap <Leader>bd <cmd>bdelete<CR>
noremap <Leader>ls <cmd>ls<CR>:b<space>

" Quickfix list
" -------------
noremap ]q <cmd>cnext<CR>
noremap [q <cmd>cprev<CR>
noremap <Leader>co <cmd>copen<CR>
noremap <Leader>cc <cmd>cclose<CR>

" Location list
" -------------
noremap <Leader>lo <cmd>lopen<CR>
noremap ]l <cmd>lnext<CR>
noremap [l <cmd>lprev<CR>

" Keep yanked (Delete)
" --------------------
noremap <Leader>d "_d
vnoremap <Leader>d "_d

" Other keybinds
" --------------
noremap Y y$
noremap J J^
noremap <leader>+x <cmd>!chmod +x %<CR>

" Tmux
" ----
noremap <Leader>f <cmd>!tmux display-popup -E ~/.config/tmux/tmux_fzed.sh<CR>
noremap <Leader>g <cmd>!tmux display-popup -E ~/.config/tmux/tmux_fzcd.sh<CR>

" Clipboard (Tmux) Does not seem to work in vim, only nvim
" --------------------------------------------------------
noremap <Leader>y "+y
vnoremap <Leader>y "+y
noremap <Leader>Y "+y$
noremap <Leader>p "+p
vnoremap <Leader>p "+p
noremap <Leader>P "+P
vnoremap <Leader>P "+P

" Movement
" --------
" Windows
"noremap <C-h> <C-w>h
"noremap <C-j> <C-w>j
"noremap <C-k> <C-w>k
"noremap <C-l> <C-w>l
" Center line after movement
"noremap n nzz
"noremap N Nzz
"noremap <C-d> <C-d>zz
"noremap <C-u> <C-u>zz
" Tabs (Note: Using raw <Tab> will mess up: Ctrl + i)
"noremap <Leader>n gt
"noremap <Leader>p gT
"noremap <Leader><Tab> gt
"noremap <Leader><S-Tab> gT
