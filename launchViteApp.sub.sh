#!/bin/sh

repo="$1";
appName="$2";
startCode=$3;

if [ -z "$startCode" ]
then	startCode=0;
fi

lockFile=$HOME'/.'$appName'.vite.lock';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh $repo;";
ffExe="/c/Program Files/Firefox\ Developer\ Edition/firefox.exe";

# echo;
# echo '# launchViteApp.sub.sh'
# echo '$repo:       '$repo;
# echo '$appName:    '$appName;
# echo '$startCode:  '$startCode;
# echo '$lockFile:      '$lockFile;
# echo '$thisDir:    '$thisDir;
# echo '$launchThis: '$launchThis;


# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	code -n $repo &
fi

if [ ! -z $ffProfile ]
then	"$ffExe" --no-remote -P $ffProfile &
fi

if [ -d $repo ]
then 	echo;

	if [ ! -f $lockFile ]
	then	touch $lockFile;
		echo 'About to start '$appName'.';
		echo;
		echo "(NOTE: I've set $lockFile to prevent duplicate servers being started for this application.)";
		echo;

		/c/Program\ Files/nodejs/npm run dev --host

		rm $lockFile;

		echo; echo;
		echo "I've removed the lock file ($lockFile) so you can start up next time.";
		echo; echo;
		echo "to restart, just run";
		echo "	$launchThis";
		echo;
		echo;
	fi
fi

# kill -9 $PPID;