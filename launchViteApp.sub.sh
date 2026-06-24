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

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.sub.sh - Line: $1";

	if [ ! -z "$2" ]
	then
		if [ ! -z "$3" ]
		then	echo "      \$$2: '$3'";
		else	echo "$2";
		fi
		echo '----------------------------------------';
		echo;
	fi
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

deno="$HOME/.deno/bin/deno.exe";

lkFl=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-|-$//g');

lockFile=$HOME'/.'$lkFl'.vite.lock';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh '$repo' '$appName' '$startCode' '$delay' '$ffProfile' '$execCmd';";

browserExe='/c/Program\ Files/Firefox\ Developer\ Edition/firefox.exe';
if [ ! -f "$browserExe" ]
then	browserExe='/c/Program\ Files/Mozilla\ Firefox/firefox.exe';
elif [ ! -f "$browserExe" ]
then	browserExe='/c/Program\ Files/Google/Chrome/Application/chrome.exe';
fi

# debug 59 'deno' "$deno";
# debug 60 'lkFl' "$lkFl";
# debug 61 'lockFile' "$lockFile";
# debug 62 'thisDir' "$thisDir";
# debug 63 'launchThis' "$launchThis";
# debug 64 'browserExe' "$browserExe";

# debug 66 'repo' "$repo";
# debug 67 'appName' "$appName";
# debug 68 'startCode' "$startCode";
# debug 69 'delay' "$delay";
# debug 70 'ffProfile' "$ffProfile";
# debug 71 'execCmd' "$execCmd";

# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	echo 'Attempting to start VS Code in "'$repo'"'
	code -n $repo &
fi

if [ ! -z "$ffProfile" ]
then	echo;
	echo Attempting to start Firefox profile: "'$ffProfile'";
	echo "\t$browserExe --no-remote -P $ffProfile &"
	"$browserExe" --no-remote -P $ffProfile &
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

		if [ -f "$deno" ]
		then	if [ ! -z "$execCmd" ]
			then
				"$deno/$execCmd";
			else
				"$deno" task dev
			fi
		elif [ -d '/c/Program Files/nodejs/' ]
		then	if [ ! -z "$execCmd" ]
			then	/c/Program\ Files/nodejs/$execCmd;
			else	/c/Program\ Files/nodejs/npm run dev
			fi
		else	echo 'Deno & NPM not found';
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
