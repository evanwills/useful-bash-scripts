#!/bin/sh

# ===============================================
# Make all the aliases in user's .bashrc file more human readable
# ===============================================


home=$HOME'/';
_docs=$home'Documents/';
_evan=$docs'Evan/';
_code=$evan'code/';
_shell=$code'shell-scripts';
_acu=$docs'ACU/';
_dud='/c/ACU.sitecore/';
_static=$dud'src/Project/ACUPublic/ACU.Static/';
_shellExec='/bin/sh '$shell;
_shell=$shell'/';
_php='/c/Users/evwills/AppData/Local/Programs/php-7.3.25-nts-Win32-VC15-x64/php.exe';
_moz='\/c\/Program\\ Files\/Firefox\\ Developer\\ Edition\/firefox.exe';
_fp=$moz' -P';
_vmware="/c/Program Files (x86)/VMware/VMware Workstation/vmware.exe";


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
	path=$(echo "$2" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')
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
	sedit 'shellExec' $_shellExec | \
	sedit 'shell' $_shell | \
	sedit 'code' $_code | \
	sedit 'acu' $_acu | \
	sedit 'docs' $_docs | \
	sedit 'home' $_home | \
	sedit 'evan' $_evan | \
	sedit 'static' $_static | \
	sedit 'dud' $_dud | \
	sedit 'php' $_php | \
	sedit 'moz' $_moz | \
	sedit 'fp' $_fp | \
	sedit 'vmware' $_vmware | \
	grep ';' | grep -v '^# \?alias' | \
	sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | \
	sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | \
	sed 's/;//g';

echo; echo;
