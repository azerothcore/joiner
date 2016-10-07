#!/usr/bin/env bash

#
# bash >= 4.x required
#

#
# DEFINES
#

J_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
J_PATH_MODULES=$(readlink -f $PATH_JOINER"/../../")

J_PARAMS="$@"

#
# JOINER FUNCTIONS
#

function Joiner:add_repo() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path=$J_PATH_MODULES/$basedir/$name

    if [ -e $path/.git/ ]; then
        # if exists , update
        git --git-dir=$path/.git/ rev-parse && git --git-dir=$path/.git/ pull origin $branch
    else
        # otherwise clone
        git clone $url -c advice.detachedHead=0 -b $branch $path
    fi

    [ -f $path/install.sh ] && bash $path/install.sh $J_PARAMS
}

function Joiner:add_git_submodule() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path=$J_PATH_MODULES/$basedir/$name
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
    mkdir -p $J_PATH_MODULES/"$(dirname $2)"
    [ ! -e $J_PATH_MODULES/$2 ] && curl -o $J_PATH_MODULES/$2 $1
}

function Joiner:with_dev() {
    if [ "${J_OPT[dev]}" = true ]
        return 1;
    else
        return 0;
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

