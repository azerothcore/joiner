# DESCRIPTION OF PROBLEM: Implementations of sed, readlink, zcat, etc. are different on OS X and Linux.
# NOTE: Put this on top of your script using sed, readlink, zcat, etc. that should work alike on Mac OS X.

# cross-OS compatibility (greadlink, gsed, zcat are GNU implementations for OS X)
[[ `uname` == 'Darwin' ]] && {
	which greadlink gsed gzcat > /dev/null && {
		unalias readlink sed zcat
		alias readlink=greadlink sed=gsed zcat=gzcat
	} || {
		echo 'ERROR: GNU utils required for Mac. You may use homebrew to install them: brew install coreutils gnu-sed'
		exit 1
	}
}

# NOTE: Now all uses of `sed`, `readlink`, `zcat`, etc. will refer to their GNU implementation in your script below.
# NOTE: In order to use the original implementation for Mac OS X again you'd have to do `unalias ...` (as in line 7 above).