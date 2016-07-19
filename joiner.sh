#
# DEFINES
#

PATH_JOINER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH_ROOT=$(reallink -f $PATH_JOINER)

PARAMS="$@"

#
# JOINER FUNCTIONS
#

function Joiner:add_repo() {
    url=$1
    name=$2
    branch=$3
    basedir=$4
    path=$PATH_ROOT/$basedir/$name
    
    ([ -e $path/.git/ ] && git --git-dir=$path/.git/ rev-parse && git --git-dir=$path/.git/ pull origin $branch) || git clone $url/$name.git -b $branch $path 
	[ -f $path/install.sh ] && bash $path/install.sh $PARAMS
}

function Joiner:add_file() {
    mkdir -p $PATH_ROOT/"$(dirname $2)"
    [ ! -e $PATH_ROOT/$2 ] && curl -o $PATH_ROOT/$2 $1
}

