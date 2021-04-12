## misstypes
alias cd..="cd .."
alias cd.="cd .."
alias ..="cd .."
alias cls="clear"
alias ks='ls'
alias l="ls"

## updates
# Ubuntu
alias update='sudo apt-get update && sudo apt-get upgrade'
# Manjaro
# alias update="sudo pacman -Syu && sudo pamac upgrade -a"

## various
alias localsudo='sudo -E env "PATH=$PATH"'
# asks for confirmation on delete, use sudo to bypass
alias rm='rm -i'
# checks the firewall
alias ufws='sudo ufw status verbose numbered'
# downloads all the links in the file "list" with uget
alias wgetlist='sudo wget -bqc -i list'
alias youtube-dl='sudo youtube-dl --add-metadata --write-info-json --embed-subs --all-subs'
alias ll='ls -al'
# shows size in MB
# alias ll="ls -al --block-size=MB"

## docker stuff
alias dcup='docker-compose up -d'
alias dcnano='nano docker-compose.yml'
alias dclogs='docker-compose logs'
alias dcrestart='docker-compose restart'
alias dcdown='docker-compose down'
alias dcpull="docker-compose pull"
alias dcupdate="docker-compose pull && docker-compose up -d"
alias dcstop="docker-compose stop"
dcbash() { docker exec -it "$1" /bin/bash; }
dcsh() { docker exec -it "$1" /bin/sh; }
# returns a container details or every container if no parameter is given
dclist() {
    if [ -z "$1" ]; then
        docker ps -a --format "table {{.ID}}\t{{.Names}}" | (read -r; printf "%s\n" ""; sort -k 2);
    else
        docker ps -a --format "table {{.ID}}\t{{.Names}}" | (read -r; printf "%s\n" ""; sort -k 2) | grep "$1";
    fi
}
# zip all the folders in the current directory as separate uncompressed zips
compressfolders() {
  for filename in $PWD/*/; do
    zip -0 -r "${filename%?}.zip" "$filename"
  done
}
alias zerozip='zip -0 -r'