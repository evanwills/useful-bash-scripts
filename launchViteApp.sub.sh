#!/bin/sh

repo="$1";
appName="$2";
startCode="$3";
delay="$4";
ffProfile="$5";
execCmd="$6";
rootRepo="$7";

echo;
echo '# launchViteApp.sub.sh';
echo;

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.sub.sh - Line: $1";

	if [ ! -z "$2" ]
	then
		if [[ ! -z "$3" || ! -z "$4" ]]
		then	echo "      \$$2: '$3'";
		else	echo "$2";
		fi
		echo '----------------------------------------';
		echo;
	fi
}

# debug 29 '1' "$1" 'force';
# debug 30 '2' "$2" 'force';
# debug 31 '3' "$3" 'force';
# debug 32 '4' "$4" 'force';
# debug 33 '5' "$5" 'force';
# debug 34 '6' "$6" 'force';
# debug 35 '7' "$7" 'force';

startCode=0;
if [ "$startCode" == 'code' ]
then	startCode=1;
elif [ "$startCode" == '1' ]
then	startCode=1;
fi

if [ "$ffProfile" == 'X' ]
then	ffProfile='';
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

chrome='/c/Program\ Files/Google/Chrome/Application/chrome.exe';
ff='/c/Program\ Files/Mozilla\ Firefox/firefox.exe';
ffDev='/c/Program\ Files/Firefox\ Developer\ Edition/firefox.exe';
edge="/c/Program\ Files\ \(x86\)/Microsoft/Edge/Application/msedge.exe"


# debug 68 'deno' "$deno";
# debug 69 'chrome' "$chrome";
# debug 70 'ff' "$ff";
# debug 71 'ffDev' "$ffDev";
# debug 72 'edge' "$edge";
# debug 73 'lkFl' "$lkFl";
# debug 74 'lockFile' "$lockFile";
# debug 75 'thisDir' "$thisDir";
# debug 76 'launchThis' "$launchThis";
# debug 77 'browserExe' "$browserExe";

# debug 79 'repo' "$repo";
# debug 80 'appName' "$appName" 'force';
# debug 81 'startCode' "$startCode" 'force';
# debug 82 'delay' "$delay" 'force';
# debug 83 'ffProfile' "$ffProfile" 'force';
# debug 84 'execCmd' "$execCmd" 'force';
# exit;

# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	if [ -d "$rootRepo" ]
	then	echo 'Attempting to start VS Code in "'$rootRepo'"'
		code -n $rootRepo &
	else	echo 'Attempting to start VS Code in "'$repo'"'
		code -n $repo &
	fi
fi

if [ ! -z "$ffProfile" ]
then	browserExe='';

	if [ -f "$ffDev" ]
	then	browserExe="$ffDev";
	elif [ -f "$ff" ]
	then	browserExe="$ff";
	elif [ -f "$chrome" ]
	then	browserExe="$chrome";
	elif [ -f "$edge" ]
	then	browserExe="$edge";
	fi

	# debug 97 'browserExe' "$browserExe";

	if [ ! -z "$browserExe" ]
	then	echo;
		echo Attempting to start Firefox profile: "'$ffProfile'";
		echo "\t$browserExe -P $ffProfile &"
		"$browserExe" -P $ffProfile &
	else	echo 'Could not find browser executable.';
		# debug 115 'ffDev' "$ffDev";
		# debug 116 'ff' "$ff";
		# debug 117 'chrome' "$chrome";
		# debug 118 'edge' "$edge";
	fi
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
