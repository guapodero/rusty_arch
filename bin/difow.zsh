#!/bin/zsh

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"

if [[ $# -ne 2 ]]; then
    >&2 echo "usage: $0 src dst"
    exit 1
fi

src=$1; dst=$2

[[ -d $src && -r $src ]] || (>&2 echo "${src} isn't a readable directory" && exit 1)

info="${RED} src: ${src} \n ${GREEN} dst: ${dst} \n ${RESET}"

sha_tree() {
    find $1 -not -path "*/.git/*" -not -path "*/target/*" -not -path "*/.DS_Store" \
        | xargs -L 1 bash -c 'if ! [ -d $0 ] ; then sha1sum "$0"; fi' \
        | sed "s@$1@@" \
        | sort -k 2
}

diff --color <(sha_tree $dst) <(sha_tree $src)

if [ $? -eq 0 ]; then
    echo "${info}no changes detected"
    exit 0
fi

echo "${info}waiting for approval or ^C"
read wait

# remove unwanted files before cp
find $src -type d -name target -prune -exec rm -r {} +
find $src -type f -name .DS_Store -delete
# overwrite
rm -rf $dst
cp -r $src $dst
