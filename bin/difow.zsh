#!/bin/zsh

EXCLUDE_NAMES=(target/ .git/ .DS_Store)

while [[ $# -gt 0 ]]; do
    case $1 in
        --exclude)
            EXCLUDE_NAMES+=("$2")
            shift # past argument
            shift # past value
            ;;
        --exclude-from)
            if ! [[ -r "$2" ]]; then
                >&2 echo "$2 is not readable"
                exit 1
            fi
	          EXCLUDE_NAMES+=($(cat $2))
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
    >&2 echo "usage: $0 [--exclude filename | dirname/] [--exclude-from file of excludes] SRC DST"
    >&2 echo ""
    >&2 echo "synchronize a file tree from SRC to DST"
    >&2 echo "show differences and wait for approval"
    exit 1
fi

SRC=$1
DST=$2
if ! [[ -d $SRC && -r $SRC ]]; then
    >&2 echo "${SRC} is not a readable directory"
    exit 1
fi

for name in "${EXCLUDE_NAMES[@]}"; do
    if [[ "${name:(-1)}" == "/" ]]; then
        find_filter+=("-not -path */$name*")
    else
        find_filter+=("-not -path */$name")
    fi
done

sha_tree() {
    find $1 ${(z)find_filter} \
    | xargs -L 1 bash -c 'if ! [ -d $0 ] ; then sha1sum "$0"; fi' \
    | sed "s#$1##" \
    | sort -k 2
}

diff <(sha_tree $DST) <(sha_tree $SRC) | while read line; do
    file=$(echo $line | tr -s ' ' | cut -d ' ' -f 3)
    case "$(echo $line | head -c 1)" in
        "<") rem+=($file) ;;
        ">") add+=($file) ;;
    esac
done

for file in "${rem[@]}"; do
    if [[ "${add[@]}" =~ ".*$file.*" ]]; then
        cha+=($file)
        rem=(${rem/$file/})
        add=(${add/$file/})
    fi
done

all_sorted="$(echo "${rem[@]} ${add[@]} ${cha[@]}" | tr -s ' ' '\n' | sort)"

for file in $(echo $all_sorted); do
    note=""
    if [[ "${rem[@]}" =~ ".*$file.*" ]]; then echo -n "$(tput setaf 1)-";
    elif [[ "${add[@]}" =~ ".*$file.*" ]]; then echo -n "$(tput setaf 2)+";
    elif [[ "${cha[@]}" =~ ".*$file.*" ]]; then
        echo -n "$(tput setaf 3)~"
        if [[ $(stat -c %Y $SRC$file) -lt $(stat -c %Y $DST$file) ]]; then
            note=" (excluded: newer in $DST)"
        fi
    fi
    echo " $file$note"
done
tput sgr0

if [[ -z "$all_sorted" ]]; then
    echo "no differences detected"
    exit 0
fi

echo "continue with sync? (includes .git)"
read confirm
[[ "$confirm" == "" || "$confirm" == [Yy]* ]] || exit 1

if [[ ! -z "$rem" ]]; then
    sh -xc "rm --recursive $(echo ${rem/#/$DST})"
fi

if [[ ! -z "$add" ]]; then
    for file in ${add[*]}; do
        sh -xc "cp --no-dereference --preserve=all $SRC$file $DST$file"
    done
fi

if [[ ! -z "$cha" ]]; then
    for file in ${cha[*]}; do
        sh -xc "cp --update --no-dereference --preserve=all $SRC$file $DST$file"
    done
fi

for git_dir in $(find $SRC -name .git -type d -prune | sed "s#^$SRC##"); do
    mkdir -p $DST$git_dir
    sh -xc "cp --update --archive $SRC$git_dir $DST$git_dir"
done
