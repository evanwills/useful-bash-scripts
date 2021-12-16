#!/bin/sh

# ===============================================
# Make all the aliases in user's .bashrc file more human readable
# ===============================================


home=$HOME'/';
_docs=$home'Documents/';
_evan=$_docs'Evan/';
_code=$_evan'code/';
_shell=$_code'shell-scripts';
_acu=$_docs'ACU/';
_shellExec='/bin/sh '$_shell;
_shell=$_shell'/';


# -----------------------------------------------
# @function sedit() used to convert variables in .bashrc
# to their value strings when piping contents of grep
#
# @param {string} variable name
# @param {string} contents of variable
#
# @return {string}
# -----------------------------------------------
function sedit
{
	path=$(echo $2 | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')
	sed "s/'\\\$$1'/$path/ig"
	# echo "s/'\\\$$1'/$path/ig"
}

# sedit 'shellExec' "$_shellExec"
# sedit 'shell' $_shell
# sedit 'code' $_code
# sedit 'acu' $_acu
# sedit 'docs' $_docs
# sedit 'home' $_home

# exit;
echo; echo;

grep alias $home/.bashrc | \
	sed "s/\\\$shellExec'/'$(echo $_shellExec | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')/ig" | \
	sedit 'shell' $_shell | \
	sedit 'code' $_code | \
	sedit 'acu' $_acu | \
	sedit 'docs' $_docs | \
	sedit 'home' $_home | \
	grep ';' | grep -v '^# \?alias' | \
	sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | \
	sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | \
	sed 's/;//g';

echo; echo;
