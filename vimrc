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

" Commands
"" Json Formatting
com! FormatJSON %!python -m json.tool
