#!/bin/sh

# ------------------------------------------------
# File system path to this script
#
# @var string
# ------------------------------------------------
thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

# ------------------------------------------------
# Versions of Node installed on this machine
#
# @var string
# ------------------------------------------------
nvmInstalled=$(nvm list | grep '[0-9]\+\.[0-9]\+\.[0-9]\+')

# echo '$thisDir: '$thisDir;
# echo '$nvmAll: '$nvmAll;
# echo '$nvmInstalled: '$nvmInstalled ;

which='current'
if [ "$1" = 'lts' ]
then	which='lts';
fi
version=$(/c/php/php.exe $thisDir/nvm-latest.php "$nvmInstalled" $which);
# echo '$toInstall: '$toInstall;

if [ ! -z "$version" ]
then	nvm use $version 64
fi

echo
