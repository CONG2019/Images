"通用配置
"通用配置
syntax on  " 开启语法高亮
colorscheme peachpuff "vim配置方案
set number  " 显示行号
set hls "搜索时高亮显示被找到的文本
set scrolloff=3 " 上下可视行数
set incsearch   " 搜索时高亮显示被找到的文本
set ignorecase "搜索忽略大小写
set enc=utf-8  "编码设置
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1 "编码自动识别
set mouse=n "鼠标普通模式
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
