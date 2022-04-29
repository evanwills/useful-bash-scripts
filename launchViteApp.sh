#!/bin/sh

if [ -d $HOME'/Documents/code' ]
then	_code=$HOME'/Documents/code';
else 	if [ -d $HOME'/Documents/Evan/code' ]
	then	_code=$HOME'/Documents/Evan/code';
	else	thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
		if [ -d $thisDir'../code' ]
		then	_code=$thisDir'/../code';
		fi
	fi
fi

appName="$1"

isWc=$(echo $appName | sed 's/^wc-.*$/wc/i');

if [ "$isWc" == "wc" ]
then 	appName=$(echo $appName | sed 's/^wc-\(.*\)$/\1/i');
else	isWc = '';
fi

repo=$(echo $appName | sed 's/\([A-Z]\)/-\1/g')
repo=${repo,,}
if [ "$isWc" == "wc" ]
then	repo=$_code'/web-components/'$repo'/';
else	repo=$_code'/'$repo'/';
fi

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

if [ ! -d $repo ]
then	echo 'Could not find repo for '$appName
	echo 'Target directory: '$repo;
	exit;
fi

lockFile=$HOME'/'$appName'.lock';

launchThis="/bin/sh $thisDir/launchViteApp.sh $appName;";
# echo '$thisDir: "'$thisDir'"';

if [ ! -f $lockFile ]
then	touch $lockFile

	cd $repo

	echo;
	echo 'About to start '$appName'.';
	echo;
	echo "(NOTE: I've set $lockFile to prevent duplicate servers being started for this application.)";
	echo;

	/c/Program\ Files/nodejs/npm run dev

	echo;

	rm $lockFile

	echo; echo;
	echo "I've removed the lock file ($lockFile) so you can start up next time.";
	echo; echo;
	echo "to restart, just run";
	echo "	$launchThis";
	echo; echo;
	exit;
else	echo;
	echo "Regex $appName Dev server is already running.";
	echo;
	echo "It may be that you need to remove the lock file and rerun this script.";
	echo;
	echo;
	echo '```';
	echo "	rm $lockFile; $launchThis";
	echo;
	echo '```';
	echo;
	echo;
fi

