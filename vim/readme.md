# VIM / NVim

``` bash
mklink .vimrc c:\users\[username]\config\vim\.vimrc
mklink .vimrc c:\users\[user]\config\vim\.vimrc
cd %LOCALAPPDATA%\nvim\
mklink init.vim c:\Users\[user]\.vimrc
#

# powershell evaluated shell?
New-Item -ItemType SymbolicLink -Path C:\users\[user]\.vimrc -Target C:\Users\[user]\win-dot-files\vim\.vimrc
cd $ENV:LOCALAPPDATA\nvim
New-Item -ItemType SymbolicLink -Path .\init.vim -Target C:\Users\[user]\win-dot-files\vim\.vimrc
```

neovim %LOCALAPPDATA%\nvim\init.vim
````
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
````