check the file `.zshrc`, the only difference is that functions needs the keyword "function" prepended.

# zsh
dcsh() { docker exec -it "$1" /bin/sh; }
# bash
function dcsh() { docker exec -it "$1" /bin/sh; }
