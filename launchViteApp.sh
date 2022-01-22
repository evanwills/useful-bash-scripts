#!/bin/sh

appName="$1"

repo=$(echo $appName | sed 's/\([A-Z]\)/-\1/g')
repo=${repo,,}
repo=$HOME'/Documents/Evan/code/'$repo'/';

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
