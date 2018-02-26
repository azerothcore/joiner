#!/usr/bin/env bash

#
# bash >= 4.x required
#

#
# DEFINES
#

# boolean bash convention ( inverse )
TRUE=0
FALSE=1

J_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

unamestr=`uname`
if [ -z "$J_PATH_MODULES" ]; then
    if [[ "$unamestr" == 'Darwin' ]]; then
        J_PATH_MODULES=$(greadlink -f "$J_PATH/../../")
    else
        J_PATH_MODULES=$(readlink -f "$J_PATH/../../")
    fi
fi

J_PARAMS="$@"

#
# JOINER FUNCTIONS
#

function Joiner:remove() {
    name=$1
    basedir=$2

    path="$J_PATH_MODULES/$basedir/$name"

    if [ -d "$path" ]; then
        rm -rf $path
        [[ -f $path/uninstall.sh ]] && bash $path/uninstall.sh $J_PARAMS
    elif [ -f "$path" ]; then
        rm -f $path
    fi

    return $TRUE
}

function Joiner:upd_repo() {
    Joiner:add_repo $@
}

function Joiner:add_repo() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path="$J_PATH_MODULES/$basedir/$name"
    changed="yes"

    if [ -e $path/.git/ ]; then
        # if exists , update
        git --git-dir=$path/.git/ rev-parse && git --git-dir=$path/.git/ pull origin $branch | grep 'Already up-to-date.' && changed="no"
    else
        # otherwise clone
        git clone $url -c advice.detachedHead=0 -b $branch $path
    fi

    [[ -f $path/install.sh && "$changed" = "yes" ]] && bash $path/install.sh $J_PARAMS
}

function Joiner:add_git_submodule() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path="$J_PATH_MODULES/$basedir/$name"
    cur_git_path=$(git rev-parse --show-toplevel)"/"
    rel_path=${path#$cur_git_path}

    if [ -e $path/ ]; then
        # if exists , update
        git submodule update --init $rel_path
    else
        # otherwise add
        git submodule add -b $branch $url $rel_path
        git submodule update --init $rel_path
    fi

    [ -f $path/install.sh ] && bash $path/install.sh $J_PARAMS
}

function Joiner:add_file() {
    declare -A _OPT;
    for i in "$@"
    do
    case $i in
        --unzip|-u)
            _OPT[unzip]=true
            shift
        ;;
        *)
            # unknown option
        ;;
    esac
    done

    mkdir -p $J_PATH_MODULES/"$(dirname $2)"

    destination="$J_PATH_MODULES/$2"

    [ ! -e $J_PATH_MODULES/$2 ] && curl -o "$destination" "$1"

    if [ "${_OPT[unzip]}" = true ]; then
        unzip -d $(dirname $destination) $destination
        rm $destination
    fi
}

function Joiner:with_dev() {
    if [ "${J_OPT[dev]}" = true ]; then
        return $TRUE;
    else
        return $FALSE;
    fi
}

#
# Parsing parameters
#

if [ -e "$J_PATH/.git/" ]; then
    # self update
    if [ ! -z "$J_VER_REQ" ]; then
        # if J_VER_REQ is defined then update only if tag is different
        _cur_branch=`git rev-parse --abbrev-ref HEAD`
        _cur_ver=`git --git-dir="$J_PATH/.git/" name-rev --tags --name-only $_cur_branch`
        if [ "$_cur_ver" != "$J_VER_REQ" ]; then
            git --git-dir="$J_PATH/.git/" rev-parse && git --git-dir="$J_PATH/.git/" fetch --tags origin "$_cur_branch" --quiet
            git --git-dir="$J_PATH/.git/" checkout "tags/$J_VER_REQ" -b "$_cur_branch"
        fi
    else
        # else always try to keep at latest available version (worst performances)

        git --git-dir="$J_PATH/.git/" rev-parse && git --git-dir="$J_PATH/.git/" fetch origin "$_cur_branch" --quiet
    fi
fi

declare -A J_OPT;

for i in "$@"
do
case $i in
    -e=*|--extras=*)
        J_OPT[extra]="${i#*=}"
        shift
    ;;
    --dev|-d)
        J_OPT[dev]=true
        shift
    ;;
    *)
        # unknown option
    ;;
esac
done

