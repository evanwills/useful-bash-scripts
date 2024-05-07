#!/bin/sh

repo="$1";
appName="$2";
startCode=$3;
delay=$4;

if [ -z "$startCode" ]
then	startCode=0;
else	startCode=1;
fi

if [ -z "$delay" ]
then	delay=0;
fi

echo 'Inside launchViteApp.sub.sh';

lkFl=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/g');

lockFile=$HOME'/.'$lkFl'.vite.lock';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh $repo;";

ffExe='"/c/Program Files/Firefox Developer Edition/firefox.exe"';
if [ ! -f "$ffExe" ]
then	ffExe='"/c/Program Files/Mozilla Firefox/firefox.exe"';
fi

echo;
echo '# launchViteApp.sub.sh'
echo '$repo:       '$repo;
echo '$appName:    '$appName;
echo '$startCode:  '$startCode;
echo '$delay:      '$delay;
echo '$lockFile:   '$lockFile;
echo '$thisDir:    '$thisDir;
echo '$launchThis: '$launchThis;


# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	echo 'Attempting to start VS Code in "'$repo'"'
	code -n $repo &
fi

if [ ! -z "$ffProfile" ]
then	echo;
	echo Attempting to start Firefox profile: "'$ffProfile'";
	echo "\t$ffExe --no-remote -P $ffProfile &"
	"$ffExe" --no-remote -P $ffProfile &
fi

if [ -d $repo ]
then 	echo;

	if [ ! -f $lockFile ]
	then	touch $lockFile;
		echo 'About to start '$appName'.';
		echo;
		echo "(NOTE: I've set $lockFile to prevent duplicate servers being started for this application.)";
		echo;

		if [ $delay -gt 0 ]
		then	echo;
			echo '============================================================';
			echo "We're waiting $delay seconds while other things are done "
			echo "before starting $appName"
			sleep $delay
			echo
			echo "We're done waiting.";
			echo '============================================================';

			echo; echo;
		fi

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