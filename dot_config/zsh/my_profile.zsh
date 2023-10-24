alias hx='helix'
alias shx='sudo /usr/bin/helix -c ~/.config/helix/config.toml'

mkdir -p ~/scratch
alias bak_scratch='() { ${HOST_WORKDIR}/bin/difow.zsh ~/scratch/$1 ${HOST_WORKDIR}/data/scratch_bak/$1 }'
alias bak_hctarcs='() { ${HOST_WORKDIR}/bin/difow.zsh ${HOST_WORKDIR}/data/scratch_bak/$1 ~/scratch/$1 }'

gh_clone () {
    mkdir -p ~/github
    cd $_
    git clone git@github.com:$1.git
    cd ${1##*/}
}