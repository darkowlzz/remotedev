call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
Plug 'vim-airline/vim-airline'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'fatih/molokai'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'SirVer/ultisnips'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'tsandall/vim-rego'
Plug 'rust-lang/rust.vim'
call plug#end()


" Theme.
let g:rehash256 = 1
let g:molokai_original = 1
silent! colorscheme molokai


" Text wrap.
set tw=79
" Hybrid line numbering.
set nu rnu
" Highlight cursor.
set cursorline
set cursorcolumn

"set tabstop=2 shiftwidth=2 expandtab

set colorcolumn=80

" Enable scrolling with scroll wheel (iTerm 2)
set mouse=a

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Search as you type
set incsearch


let mapleader = "\<Space>"

nmap <C-b> :NERDTreeToggle<CR>

nmap <Leader>p :PlugInstall<CR>

" Tab navigation.
map  <C-l> :tabn<CR>
map  <C-h> :tabp<CR>
map  <C-n> :tabnew<CR>

" Turn off highlight until the next search
nnoremap <leader>h :noh<cr>

" Toggle paste
nnoremap <leader>tp :set invpaste paste?<cr>

" Reload vimrc
nnoremap <leader>rl :source ~/.config/nvim/init.vim<cr>

" Open Explore
nnoremap <leader>e :Explore<cr>

" Quick save
nnoremap <leader>w :w!<cr>

" Quick close
nnoremap <leader>q :q<cr>

" Start file search
nnoremap <leader>f :Files<cr>

" Toggle NERDTree
nnoremap <leader>b :NERDTreeToggle<CR>
" Revel the current file in NERDTree
nnoremap <leader>br :NERDTreeFind<CR>

" Start windows search
nnoremap <leader>ww :Windows<CR>


let g:NERDTreeShowHidden=1
let g:deoplete#enable_at_startup = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Use system clipboard when copying
set clipboard=unnamedplus

" Disable folding in markdown files
let g:vim_markdown_folding_disabled = 1

" Set hold method by syntax
set foldmethod=syntax

" Set fold leve start to a high number to avoid auto fold by default
set foldlevelstart=99

"set nofoldenable " disable folding

" Automatically closing braces
inoremap {<CR> {<CR>}<Esc>ko<tab>
inoremap [<CR> [<CR>]<Esc>ko<tab>
inoremap (<CR> (<CR>)<Esc>ko<tab>


" vim-go related configurations

call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })

let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1

autocmd FileType go nmap <Leader>i <Plug>(go-info)

let g:go_auto_type_info = 1
" Update time for the auto type info trigger
set updatetime=100

let g:go_auto_sameids = 1

autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

" Auto package imports
let g:go_fmt_command = "goimports"

" Use camelcase in the tags
let g:go_addtags_transform = "camelcase"

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 

" Run go test for the selected function
autocmd FileType go nmap <leader>t  <Plug>(go-test-func)
" Open definition in a new tab.
autocmd FileType go nmap <silent> <Leader>d <Plug>(go-def-tab)

let g:go_def_reuse_buffer = 1

let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment']

" let g:go_metalinter_autosave = 1

" Others
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'


" vim-rust related configurations

let g:rustfmt_autosave = 1
