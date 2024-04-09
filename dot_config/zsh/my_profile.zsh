# a workspace directory which can be manually synced with a directory mounted in the host file system
mkdir -p $HOME/scratch
alias bak_scratch='() { $HOST_WORKDIR/bin/difow.zsh $HOME/scratch/$1 $HOST_WORKDIR/data/scratch_bak/$1 ${@:2} }'
alias bak_hctarcs='() { $HOST_WORKDIR/bin/difow.zsh $HOST_WORKDIR/data/scratch_bak/$1 $HOME/scratch/$1 ${@:2} }'

setopt auto_cd
cdpath=($HOME/scratch)

bak_config() {
    local include=(git/ helix/ lsd/ shellcheckrc starship.toml zellij/ zsh/)
    $HOST_WORKDIR/bin/difow.zsh \
        --exclude-from <( \
            /bin/ls -p $XDG_CONFIG_HOME \
            | grep -v -E "$(echo ${include[@]} | tr ' ' '|')"
        ) \
        $XDG_CONFIG_HOME $HOST_WORKDIR/dot_config
}

gh_clone() {
    mkdir -p ~/github
    cd $_
    if ! [[ -d "${1##*/}" ]]; then
        git clone git@github.com:$1.git || return 1
    fi
    cd ${1##*/}
}

rg_open() {
    rg ${@} --color=ansi --no-heading --line-number \
    | sk --ansi --tac --select-1 --exit-0 \
    | cut -d ':' -f 1,2 \
    | tee /dev/fd/2 \
    | sed 's/:/ +/' \
    | xargs -I X zsh -c 'dhx X'
}

alias git_='() { git ${@} -- . ":(exclude)Cargo.lock" }'

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
source /usr/share/bash-completion/completions/makers

zt() {
    if [[ $# -eq 1 ]]; then
        zellij action rename-tab $1
    else
        zellij action rename-tab "$(date +%H%M) $(basename $(pwd))"
    fi
}
zt
