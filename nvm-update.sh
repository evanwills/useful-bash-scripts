#!/bin/sh

# ------------------------------------------------
# File system path to this script
#
# @var string
# ------------------------------------------------
thisDir=$(realpath "$0" | sed "s/[^/']\+$//");


# ------------------------------------------------
# All versions of node currently avaible to NVM
#
# @var string
# ------------------------------------------------
nvmAll=$(nvm list available | head -n 4 | tail -n 1)

# ------------------------------------------------
# Versions of Node installed on this machine
#
# @var string
# ------------------------------------------------
nvmInstalled=$(nvm list | grep '[0-9]\+\.[0-9]\+\.[0-9]\+')

# echo '$thisDir: '$thisDir;
# echo '$nvmAll: '$nvmAll;
# echo '$nvmInstalled: '$nvmInstalled ;

toInstall=$(/c/php/php.exe $thisDir/nvm-update.php "$nvmInstalled" "$nvmAll");
# echo '$toInstall: '$toInstall;

if [ ! -z "$toInstall" ]
then	installList=$(echo $toInstall | tr ";" "\n");
	# tmp2=$(echo $tmp1);

	# echo '$toInstall: '$toInstall ;
	for version in $installList
	do	nvm install $version 64;
	done
else    echo 'All up to date';
fi

echo;
