# VIM / NVim

``` bash
mklink .vimrc c:\users\[username]\config\vim\.vimrc
cd %LOCALAPPDATA%\nvim\
mklink init.vim c:\Users\kedde\.vimrc
```

neovim %LOCALAPPDATA%\nvim\init.vim
````
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
````

