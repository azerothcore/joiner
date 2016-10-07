# cross-OS compatibility
[[ `uname` == 'Darwin' ]] && {
	which greadlink > /dev/null && {
		unalias readlink
		alias readlink=greadlink
	} || {
		echo 'ERROR: GNU utils required for Mac. You may use homebrew to install them: brew install coreutils'
		exit 1
	}
}
