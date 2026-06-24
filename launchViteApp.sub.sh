#!/bin/sh

repo="$1";
appName="$2";
startCode=$3;
delay=$4;
ffProfile="$5";
execCmd="$6";

echo;
echo '# launchViteApp.sub.sh';
echo;
echo '$repo:       '$repo;
echo '$appName:    '$appName;
echo '$startCode:  '$startCode;
echo '$delay:      '$delay;
echo '$ffProfile:  '$ffProfile;
echo '$execCmd:    '$execCmd;
echo;

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.sub.sh - Line: $1";
	echo "      \$$2: '$3'";
	echo '----------------------------------------';
	echo;
}

if [ -z "$startCode" ]
then	startCode=0;
else	if [ "$startCode" == "X" ]
	then	startCode=0;
	else	startCode=1;
	fi
fi

if [ -z "$delay" ]
then	delay=0;
fi

echo 'Inside launchViteApp.sub.sh';

lkFl=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/ig');

lockFile=$HOME'/.'$lkFl'.vite.lock';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh '$repo' '$appName' '$startCode' '$delay' '$ffProfile' '$execCmd';";

ffExe='"/c/Program Files/Firefox Developer Edition/firefox.exe"';
if [ ! -f "$ffExe" ]
then	ffExe='"/c/Program Files/Mozilla Firefox/firefox.exe"';
fi

# debug 52 '$lockFile' "$lockFile";
# debug 53 '$thisDir' "$thisDir";
# debug 54 '$launchThis' "$launchThis";


# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	echo 'Attempting to start VS Code in "'$repo'"'
	code -n $repo &
fi

if [ ! -z "$ffProfile" ]
then	echo;
	echo Attempting to start Firefox profile: "'$ffProfile'";
	echo "\t$ffExe -P $ffProfile &"
	"$ffExe" -P $ffProfile &
fi

if [ -d $repo ]
then 	echo;

	if [ ! -f "$lockFile" ]
	then	touch "$lockFile";
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

		if [ ! -z "$execCmd" ]
		then
			/c/Program\ Files/nodejs/$execCmd;
		else
			/c/Program\ Files/nodejs/npm run dev --host
		fi

		rm "$lockFile";

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