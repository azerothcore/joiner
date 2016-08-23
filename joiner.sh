#
# DEFINES
#

PATH_JOINER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH_MODULES=$(readlink -f $PATH_JOINER"/../../")

PARAMS="$@"

#
# JOINER FUNCTIONS
#

function Joiner:add_repo() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path=$PATH_MODULES/$basedir/$name
    
    if [ -e $path/.git/ ]; then
        # if exists , update
        git --git-dir=$path/.git/ rev-parse && git --git-dir=$path/.git/ pull origin $branch
    else
        # otherwise clone
        git clone $url -c advice.detachedHead=0 -b $branch $path 
    fi

    [ -f $path/install.sh ] && bash $path/install.sh $PARAMS
}

function Joiner:add_git_submodule() {
    url=$1
    name=$2
    branch=$3
    basedir=$4

    path=$PATH_MODULES/$basedir/$name
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

    [ -f $path/install.sh ] && bash $path/install.sh $PARAMS
}

function Joiner:add_file() {
    mkdir -p $PATH_MODULES/"$(dirname $2)"
    [ ! -e $PATH_MODULES/$2 ] && curl -o $PATH_MODULES/$2 $1
}

