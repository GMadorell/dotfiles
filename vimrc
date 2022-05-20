set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()


Plugin 'VundleVim/Vundle.vim' " Let Vundle manage itself, required

Plugin 'derekwyatt/vim-scala'
Plugin 'dracula/vim'
Plugin 'GEverding/vim-hocon'
Plugin 'terryma/vim-expand-region'
Plugin 'chaoren/vim-wordmotion'


" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on 


syntax on
color dracula

:set number "Line numbers

" Identation configuration
"" tabstop    -> Indentation width in spaces
"" shiftwidth -> Autoindentation width in spaces
"" expandtab  -> Use actual spaces instead of tabs
:set tabstop=2 shiftwidth=2 expandtab


" Commands
"" Json Formatting
com! FormatJSON %!python -m json.tool
