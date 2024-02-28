#!/usr/bin/env zsh

EXCLUDE_NAMES=(target/ .git/ .DS_Store)
DELETE_EXTRAS=true # extraneous files at destination are be deleted by default

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
        --no-delete)
            DELETE_EXTRAS=false
            shift
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
    if [[ ! -d $1 ]]; then return 0; fi
    find $1  \( -type d -name .git \) -o \( ${(z)find_filter} \) \
    | xargs -L 1 bash -c '
        if [[ $0 =~ /.git$ ]]; then d=$0; cd $d; echo "$(git rev-parse HEAD) $d";
        elif [[ ! -d $0 ]]; then sha1sum "$0"; fi
    ' \
    | sed "s#$1##" \
    | sort -k 2
}

diff <(sha_tree $DST) <(sha_tree $SRC) | while read line; do
    pth=$(echo $line | tr -s ' ' | cut -d ' ' -f 3)
    case "$(echo $line | head -c 1)" in
        "<") rem+=("╎$pth╎") ;;
        ">") add+=("╎$pth╎") ;;
    esac
done

for deli_pth in "${rem[@]}"; do
    if [[ "${add[@]}" =~ "$deli_pth" ]]; then
        cha+=($deli_pth)
        rem=(${rem/$deli_pth/})
        add=(${add/$deli_pth/})
    fi
done

if [[ $DELETE_EXTRAS == false ]]; then
    rem=()
fi

all_sorted="$(echo "${rem[@]} ${add[@]} ${cha[@]}" | tr -d '╎' | tr -s ' ' '\n' | sort)"

for pth in $(echo $all_sorted); do
    note=""
    if [[ "${rem[@]}" =~ "╎$pth╎" ]]; then echo -n "$(tput setaf 1)-";
    elif [[ "${add[@]}" =~ "╎$pth╎" ]]; then echo -n "$(tput setaf 2)+";
    elif [[ "${cha[@]}" =~ "╎$pth╎" ]]; then
        echo -n "$(tput setaf 3)~"
        if [[ $(stat -c %Y $SRC$pth) -lt $(stat -c %Y $DST$pth) ]]; then
            note=" (excluded: newer in $DST)"
        fi
    fi
    echo " ${pth##/}$note"
done
tput sgr0

if [[ -z "$all_sorted" ]]; then
    echo "no differences detected"
    exit 0
fi

echo "continue with sync?"
read confirm
[[ "$confirm" == "" || "$confirm" == [Yy]* ]] || exit 1

rem_pths=(${rem//╎/})
add_pths=(${add//╎/})
cha_pths=(${cha//╎/})

if [[ ! -z "$rem_pths" ]]; then
    sh -xc "rm --recursive --force $(echo ${rem_pths/#/$DST})"
fi

if [[ ! -z "$add_pths" ]]; then
    for pth in ${add_pths[*]}; do
        pth_dir=$(dirname $DST$pth)
        if [[ ! -d $pth_dir ]]; then
            sh -xc "mkdir -p $pth_dir"
        fi
        sh -xc "cp --archive --no-target-directory $SRC$pth $DST$pth"
    done
fi

if [[ ! -z "$cha_pths" ]]; then
    for pth in ${cha_pths[*]}; do
        sh -xc "cp --update --archive --no-target-directory $SRC$pth $DST$pth"
    done
fi
