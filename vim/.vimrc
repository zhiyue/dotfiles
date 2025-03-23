" 基础设置
set nocompatible              " 关闭vi兼容模式
filetype plugin indent on     " 启用文件类型检测
syntax enable                 " 启用语法高亮
set encoding=utf-8           " 使用UTF-8编码
set fileencoding=utf-8       " 使用UTF-8保存文件
set number                   " 显示行号
set relativenumber           " 显示相对行号
set ruler                    " 显示光标位置
set showcmd                  " 显示命令
set showmode                 " 显示当前模式
set showmatch               " 显示匹配的括号
set mouse=a                 " 启用鼠标
set history=1000           " 历史记录数
set backspace=indent,eol,start  " 允许退格键删除

" 搜索设置
set hlsearch                " 高亮搜索结果
set incsearch              " 增量搜索
set ignorecase            " 搜索时忽略大小写
set smartcase             " 如果搜索模式包含大写字符，不忽略大小写

" 缩进设置
set autoindent             " 自动缩进
set smartindent            " 智能缩进
set expandtab             " 将制表符展开为空格
set tabstop=4            " 制表符宽度
set shiftwidth=4         " 缩进宽度
set softtabstop=4       " 退格键删除空格数

" 外观设置
set termguicolors        " 启用24位颜色
set background=dark      " 深色背景
set cursorline          " 高亮当前行
set colorcolumn=80      " 显示80列标尺
set laststatus=2       " 始终显示状态栏
set noshowmode         " 不显示模式（使用lightline时）
set scrolloff=5       " 光标距离顶部/底部保持5行
set sidescrolloff=5   " 光标距离左/右边界保持5列
set nowrap           " 禁用自动换行

" 性能优化
set lazyredraw        " 延迟重绘（提高性能）
set ttyfast          " 快速终端连接
set updatetime=300   " 更新时间（毫秒）

" 备份和撤销设置
set nobackup         " 不创建备份文件
set nowritebackup    " 不创建写入备份
set noswapfile      " 不创建交换文件
set undofile        " 持久撤销
set undodir=~/.vim/undo  " 撤销文件目录

" 分割窗口设置
set splitbelow      " 新窗口在下方打开
set splitright      " 新窗口在右侧打开

" 自动命令
augroup vimrc
    autocmd!
    " 保存时自动删除行尾空格
    autocmd BufWritePre * :%s/\s\+$//e
    " 保存时自动创建目录
    autocmd BufWritePre * :call mkdir(expand("<afile>:p:h"), "p")
    " 打开文件时回到上次位置
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END

" 键位映射
" Leader键设置为空格
let mapleader = " "

" 快速保存和退出
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>x :x<CR>

" 窗口导航
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 调整窗口大小
nnoremap <M-j> :resize -2<CR>
nnoremap <M-k> :resize +2<CR>
nnoremap <M-h> :vertical resize -2<CR>
nnoremap <M-l> :vertical resize +2<CR>

" 缓冲区导航
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprevious<CR>
nnoremap <Leader>bd :bdelete<CR>

" 取消搜索高亮
nnoremap <Leader><CR> :nohlsearch<CR>

" 移动行
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" 保持选中状态
vnoremap < <gv
vnoremap > >gv

" 复制到系统剪贴板
vnoremap <Leader>y "+y
nnoremap <Leader>Y "+yg_
nnoremap <Leader>y "+y

" 从系统剪贴板粘贴
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P

" 快速编辑vimrc
nnoremap <Leader>ve :edit $MYVIMRC<CR>
nnoremap <Leader>vr :source $MYVIMRC<CR>

" 命令行模式下的快捷键
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>

" 插件设置（如果安装了插件管理器）
" 此处可以添加插件的具体配置

" 文件类型特定设置
augroup FileTypeSpecific
    autocmd!
    " Python
    autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4
    " JavaScript/TypeScript
    autocmd FileType javascript,typescript,json setlocal expandtab shiftwidth=2 tabstop=2
    " HTML/CSS
    autocmd FileType html,css setlocal expandtab shiftwidth=2 tabstop=2
    " Markdown
    autocmd FileType markdown setlocal wrap linebreak nolist
augroup END