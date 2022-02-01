#!/bin/sh

# ===============================================
# Generate a text file that makes all the aliases
# in user's .bashrc file more human readable
# ===============================================



home=$HOME'/';
_docs=$home'Documents/';
_evan=$_docs'Evan/';
_code=$_evan'code/';
_shell=$_code'shell-scripts';
_acu=$docs'ACU/';
_dud='/c/ACU.sitecore/';
_static=$_dud'src/Project/ACUPublic/ACU.Static/';
_shellExec='/bin/sh '$_shell;
_shell=$_shell'/';
# _php='/c/Users/evwills/AppData/Local/Programs/php-7.3.25-nts-Win32-VC15-x64/php.exe';
_php='/c/php/php.exe';
_phpEx=$_php;
_php8Ex='/c/php8/php.exe';
_moz='/c/Program\ Files/Firefox\ Developer\ Edition/firefox.exe';
_npm='/c/Program\ Files/nodejs/npm';
_fp=$_moz' -P';
_viteGo=$_shellExec'launchViteApp.sh';
_vmware="/c/Program\ Files\ (x86)/VMware/VMware\ Workstation/vmware.exe";
_efPart='/opt/rh/rh-php73/root/usr/bin/php /var/www/html/db/artisan api:emergencyPush &';

# ----------------------------------------------
# Absolute file system path to the output file
# for this script
#
# @var string $output
# ----------------------------------------------
output=$home'aliases.txt';

# echo '$output: '$output;

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
}

function seditalt
{
	path=$(echo "$2" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig');
	sed "s/\\\$$1'/'$path/ig";
}

# sedit 'shellExec' "$_shellExec"
# sedit 'shell' $_shell
# sedit 'code' $_code
# sedit 'acu' $_acu
# sedit 'docs' $_docs
# sedit 'home' $_home

# exit;

# Delete the last version output by this script
rm $output;

echo; echo;

grep alias $home/.bashrc | \
	seditalt 'shellExec' "$_shellExec" | \
	# sed "s/\\\$shellExec'/'$(echo "$_shellExec" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')/ig" | \
	seditalt 'npm' "$_npm" | \
	# sed "s/\\\$npm'/'$(echo "$_npm" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')/ig" | \
	seditalt 'phpEx' "$_phpEx" | \
	# sed "s/\\\$phpEx'/'$(echo "$_phpEx" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')/ig" | \
	seditalt 'php8Ex' "$_php8Ex"| \
	# sed "s/\\\$php8Ex'/'$(echo "$_php8Ex" | sed 's/\(^\|[^\/]\)\(\/\)/\1\\\2/ig')/ig" | \
	sedit 'shellExec' "$_shellExec" | \
	sedit 'shell' "$_shell" | \
	sedit 'code' "$_code" | \
	sedit 'acu' "$_acu" | \
	sedit 'dud' "$_dud" | \
	sedit 'docs' "$_docs" | \
	sedit 'efPart' "$_efPart" | \
	sedit 'home' "$_home" | \
	sedit 'evan' "$_evan" | \
	sedit 'fp' "$_fp" | \
	sedit 'moz' "$_moz" | \
	sedit 'npm' "$_npm" | \
	sedit 'phpEx' "$_phpEx" | \
	sedit 'php8Ex' "$_php8Ex" | \
	sedit 'php' "$_php" | \
	sedit 'static' "$_static" | \
	sedit 'vmware' "$_vmware" | \
	grep ';' | grep -v '^# \?alias' | \
	sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | \
	sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | \
	sed 's/;//g' > $output;

echo; echo;

# echo '$output: '$output;
tail -n 150 $output;
# head -n 10 $output;

