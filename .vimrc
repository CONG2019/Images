"通用配置
"通用配置
syntax on  " 开启语法高亮
"colorscheme peachpuff "vim配置方案
colorscheme wombat256grf
set number  " 显示行号
set hls "搜索时高亮显示被找到的文本
set scrolloff=3 " 上下可视行数
set incsearch   " 搜索时高亮显示被找到的文本
set ignorecase "搜索忽略大小写
set enc=utf-8  "编码设置
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1 "编码自动识别
" set mouse=n "鼠标普通模式
" set cursorline "选中行出现下划线
map qq :qa!<CR> "多窗口不保存关闭
map ww :wqa!<CR> "多窗口保存关闭
"vim自动打开跳到上次的光标位置
if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
set nocompatible  "设置backspace的工作方式
set backspace=indent,eol,start " 设置backspace的工作方式
map <F5> :set listchars=tab:>-,trail:-<CR> :set list<CR> " 显示空格和tab
map <F6> :set list!<CR> " 取消显示空格和tab
set ts=4

"配置nerdtree使用F3打开关闭
map <F3> :NERDTreeMirror <CR>
map <F3> :NERDTreeToggle <CR>
"NERDTree配置
let NERDChristmasTree=1       "显示增强
let NERDTreeAutoCenter=1      "自动调整焦点
let NERDTreeShowFiles=1       "显示文件
let NERDTreeShowLineNumbers=1 "显示行号
let NERDTreeHightCursorline=1 "高亮当前文件
let NERDTreeShowHidden=0      "显示隐藏文件
let NERDTreeMinimalUI=0       "不显示'Bookmarks' label 'Press ? for help'
let NERDTreeWinSize=31        "窗口宽度

"默认最大化窗口打开
au GUIEnter * simalt ~x 
"taglist配置信息
 let Tlist_Auto_Open=1 " Let the tag list open automatically
 let Tlist_Auto_Update=1 " Update the tag list automatically
 let Tlist_Compact_Format=1 " Hide help menu
 let Tlist_Ctags_Cmd='ctags' " Location of ctags
 let Tlist_Enable_Fold_Column=0 "do show folding tree
 let Tlist_Process_File_Always=1 " Always process the source file
 let Tlist_Show_One_File=1 " Only show the tag list of current file
 let Tlist_Exist_OnlyWindow=1 " If you are the last, kill yourself
 let Tlist_File_Fold_Auto_Close=0 " Fold closed other trees
 let Tlist_Sort_Type="name" " Order by name
 let Tlist_WinWidth=30 " Set the window 40 cols wide.
 let Tlist_Close_On_Select=1 " Close the list when a item is selected
 let Tlist_Use_SingleClick=1 "Go To Target By SingleClick
 let Tlist_Use_Right_Window=1 "在右侧显示
 map f :TlistToggle<CR>   
 "打开关闭快捷键

"airline状态栏配置
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = '|'
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
map <c-Left> :bp<CR>    " 切换到上一个
map <c-Right> :bn<CR>   " 切换到下一个
map <F2> :bd<CR>        " 关闭当前窗口
map 11 :b1<CR>          " 切换到编号1
map 22 :b2<CR>          " 切换到编号2
map 33 :b3<CR>          " 切换到编号3
map 44 :b4<CR>          " 切换到编号4
map 55 :b5<CR>          " 切换到编号5
map 66 :b6<CR>          " 切换到编号6
map 77 :b7<CR>          " 切换到编号7
map 88 :b8<CR>          " 切换到编号8
map 99 :b9<CR>          " 切换到编号<F12><F12>
map 00 :b10<CR>         " 切换到编号10

"nerdcommenter插件快速注释
let g:NERDSpaceDelims            = 1      " 在注释符号后加一个空格
let g:NERDCompactSexyComs        = 1      " 紧凑排布多行注释
let g:NERDDefaultAlign           = 'left' " 逐行注释左对齐
let g:NERDAltDelims_java         = 1      " JAVA 语言使用默认的注释符号
let g:NERDCustomDelimiters       = {'c': {'left': '/*', 'right': '*/'}} " C 语言注释符号
let g:NERDCommentEmptyLines      = 1      " 允许空行注释
let g:NERDTrimTrailingWhitespace = 1      " 取消注释时删除行尾空格
let g:NERDToggleCheckAllLines    = 1      " 检查选中的行操作是否成功
map <F12> <plug>NERDCommenterSexy         " 选中注释
map <c-F12> <plug>NERDCommenterUncomment  " 选中取消注释

" " 配置 ctags 的参数 "
map <c-]> g<c-]>  "ctags跳转不自动选择
" gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'
" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('ctags')
        let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
        let g:gutentags_modules += ['gtags_cscope']
endif
" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags目录中，避免污染工程目录
let g:gutentags_cache_dir = expand('~/.cache/tags')
" 配置 ctags 的参数，老的 Exuberant-ctags 不能有--extra=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" 如果使用 universal ctags 需要增加下面一行，老的Exuberant-ctags 不能加下一行
"let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

GIT_TERMINAL_PROMPT=0
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'vim-scripts/taglist.vim' "Tlist标签列表插件
Plug 'preservim/nerdcommenter' "nerdcommenter快速注释插件
Plug 'vim-airline/vim-airline' "airline状态栏
Plug 'vim-scripts/vim-gutentags-master' "gutentags异步tags插件
Plug 'vim-scripts/LeaderF-master' "LeaderF模糊查找插件
Plug 'vim-scripts/AutoComplPop' "查字典补全
call plug#end()




