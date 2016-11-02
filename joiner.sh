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
if [[ "$unamestr" == 'Darwin' ]]; then
   J_PATH_MODULES=$(greadlink -f "$J_PATH/../../")
else
   J_PATH_MODULES=$(readlink -f "$J_PATH/../../")
fi

J_PARAMS="$@"

#
# JOINER FUNCTIONS
#

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

