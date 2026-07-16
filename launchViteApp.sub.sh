#!/bin/sh

repo="$1";
appName="$2";
startCode="$3";
delay="$4";
ffProfile="$5";
execCmd="$6";
rootRepo="$7";
doDebug="$8";

echo;
echo '# launchViteApp.sub.sh';
echo;

if [ "$doDebug" != '1' ]
then	doDebug=0;
# else	set -x;
fi

debug () {
	if [ $doDebug -eq 0 ]
	then	return;
	fi

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

debug 40 '1' "$1" 'force';
debug 41 '2' "$2" 'force';
debug 42 '3' "$3" 'force';
debug 43 '4' "$4" 'force';
debug 44 '5' "$5" 'force';
debug 45 '6' "$6" 'force';
debug 46 '7' "$7" 'force';
debug 47 '8' "$8" 'force';

if [[ "$startCode" == 'code' ||  "$startCode" == '1' ]]
then	startCode=1;
else    startCode=0;
fi

if [ "$ffProfile" == 'X' ]
then	ffProfile='';
fi

if [ -z "$delay" ]
then	delay=0;
fi

echo 'Inside launchViteApp.sub.sh';

deno="$HOME/.deno/bin/deno.exe";

lkFl=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-\+\|-\+$//g');
lkFl=${lkFl,,};

lockFile=$HOME'/.'$lkFl'.vite.lock';
browserLock='';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh '$repo' '$appName' '$startCode' '$delay' '$ffProfile' '$execCmd';";

chrome='/c/Program Files/Google/Chrome/Application/chrome.exe';
ff='/c/Program Files/Mozilla Firefox/firefox.exe';
ffDev='/c/Program Files/Mozilla Firefox Developer Edition/firefox.exe';
edge="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe";

debug 79 'deno' "$deno";
debug 80 'chrome' "$chrome";
debug 81 'ff' "$ff";
debug 82 'ffDev' "$ffDev";
debug 83 'edge' "$edge";
debug 84 'lkFl' "$lkFl";
debug 85 'lockFile' "$lockFile";
debug 86 'thisDir' "$thisDir";
debug 87 'launchThis' "$launchThis";
debug 88 'browserExe' "$browserExe";

debug 90 'repo' "$repo";
debug 91 'appName' "$appName" 'force';
debug 92 'startCode' "$startCode" 'force';
debug 93 'delay' "$delay" 'force';
debug 94 'ffProfile' "$ffProfile" 'force';
debug 95 'execCmd' "$execCmd" 'force';
debug 96 'rootRepo' "$rootRepo" 'force';
debug 97 'doDebug' "$doDebug" 'force';

# sleep 60;
# exit;

if [ -z "$repo" ]
then	echo;
	echo "No repo was specified.";
	echo;
	sleep 60
	exit;
elif [ ! -d "$repo" ]
then	echo;
	echo "The repo ($repo) does not exist.";
	echo;
	sleep 60
	exit;
fi

echo;
echo "Go to the repo's directory:"
echo "	$repo";
cd $repo

echo "Should be in the repo's directory:"
echo "	$repo";
echo "Current directory:"
echo "	$(pwd)";
echo;

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
	browserKey='';

	if [ -f "$ffDev" ]
	then	browserExe="$ffDev";
		browserKey='ff-dev';
		browserName='Firefox Developer Edition';
	elif [ -f "$ff" ]
	then	browserExe="$ff";
		browserKey='ff';
		browserName='Firefox';
	elif [ -f "$chrome" ]
	then	browserExe="$chrome";
		browserKey='chrome';
		browserName='Google Chrome';
	elif [ -f "$edge" ]
	then	browserExe="$edge";
		browserKey='edge';
		browserName='Microsoft Edge';
	fi

	browserLock=$HOME'/.'$browserKey'--'$ffProfile'.lock';
	# debug 158 'browserExe' "$browserExe";
	debug 159 'browserLock' "$browserLock";

	if [ ! -z "$browserExe" ]
	then	echo;
		if [ ! -f "$browserLock" ]
		then	touch "$browserLock";
			echo "Attempting to start $browserName profile: '$ffProfile'";
			echo "\t$browserExe --no-remote -P $ffProfile &"

			"$browserExe" --no-remote -P "$ffProfile" &
		else
			echo;
			echo "A $browserName instance of '$ffProfile' is already running.";
		fi
	else	echo 'Could not find browser executable.';
		debug 174 'ffDev' "$ffDev";
		debug 175 'ff' "$ff";
		debug 176 'chrome' "$chrome";
		debug 177 'edge' "$edge";
	fi
else 	echo;
	echo "No Firefox profile was specified.";
	echo 'Skipping attempt to start Firefox.';
	debug 150 'ffProfile' "$ffProfile";
fi

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
		then	echo "Running custom command: /c/Program\ Files/nodejs/$execCmd";
			/c/Program\ Files/nodejs/$execCmd;
		else	echo "Running default command: /c/Program\ Files/nodejs/npm run dev";
			/c/Program\ Files/nodejs/npm run dev
		fi
	else	echo 'Could not find Node or Deno!';
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
