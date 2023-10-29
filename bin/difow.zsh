#!/bin/zsh

POSITIONAL_ARGS=()
IGNORE_PATTERNS=("*/target/*" "*/.DS_Store")

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ignore)
            IGNORE_PATTERNS+=("$2")
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ $# -ne 2 ]]; then
    >&2 echo "usage: $0 [(-i | --ignore) glob] SRC DST"
    >&2 echo ""
    >&2 echo "backup files from SRC to DST"
    >&2 echo "show diff and wait for approval"
    exit 1
fi

rsync --version 2> /dev/null | head -1 | grep rsync
if [[ $? -ne 0 ]]; then
    >&2 echo "rsync is required" # rsync is ubiquitous
    exit 1
fi

SRC=$1
DST=$2
if ! [[ -d $SRC && -r $SRC ]]; then
    >&2 echo "${SRC} is not a readable directory"
    exit 1
fi

echo "$(tput setaf 1)SRC: ${SRC}\n$(tput setaf 2)DST: ${DST}\n$(tput sgr0)"

FIND_FILTER=""
for pattern in "${IGNORE_PATTERNS[@]}"; do
    FIND_FILTER+=("-not -path $pattern")
done

sha_tree() {
    find $1 -not -path "*/.git/*" ${(z)FIND_FILTER} \
    | xargs -L 1 bash -c 'if ! [ -d $0 ] ; then sha1sum "$0"; fi' \
    | sed "s#$1##" \
    | sort -k 2
}

diff --color <(sha_tree $DST) <(sha_tree $SRC)

if [[ $? -eq 0 ]]; then
    echo "no differences detected"
    exit 0
fi

echo "continue with sync? (includes .git)"
read confirm
[[ "$confirm" == "" || "$confirm" == [Yy]* ]] || exit 1

RSYNC_FILTER=""
for pattern in "${IGNORE_PATTERNS[@]}"; do
    # convert patterns like */target/* to target for rsync
    pattern=${pattern##\*/} # remove */ from start
    pattern=${pattern%%/\*} # remove /* from end
    RSYNC_FILTER+=("--exclude $pattern")
done

rsync -r --delete --out-format="%i %n" ${(z)RSYNC_FILTER} $SRC/ $DST | grep -v ".git/*"
