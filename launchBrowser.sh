echo 'Attempting to launch browser profile';

profile=$(echo $1 | sed 's/^\([^|]*\)|.*$/\1/');

if [ -z "$profile" ]
then	echo
	echo "No browser profile was specified.";
	echo;
	exit;
fi

chrome='/c/Program Files/Google/Chrome/Application/chrome.exe';
ff='/c/Program Files/Mozilla Firefox/firefox.exe';
ffDev='/c/Program Files/Mozilla Firefox Developer Edition/firefox.exe';
edge="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe";

browserExe='';
browserKey='';
ff=1;
doDebug=1;

# =========================================================

debug () {
	if [ $doDebug -ne 1 ]
	then	return;
	fi

	echo '----------------------------------------';
	echo "launchBrowser.sh - Line: $1";

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

# =========================================================

debug 45 'profile' "$profile";

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
	ff=0;
elif [ -f "$edge" ]
then	browserExe="$edge";
	browserKey='edge';
	browserName='Microsoft Edge';
	ff=0;
fi

if [ -z "$browserExe" ]
then	echo 'Could not find browser executable.';
	debug 69 'ffDev' "$ffDev";
	debug 70 'ff' "$ff";
	debug 71 'chrome' "$chrome";
	debug 72 'edge' "$edge";
	exit;
fi

browserLock=$HOME'/.'$browserKey'--'$ffProfile'.lock';
# debug 77 'browserExe' "$browserExe";
debug 78 'browserLock' "$browserLock";

if [ ! -f "$browserLock" ]
then	touch "$browserLock";

	if [ $ff -eq 1 ]
	then	echo;
		echo "Attempting to start $browserName profile: '$ffProfile'";
		echo "\t$browserExe --no-remote -P $ffProfile &"

		"$browserExe" --no-remote -P "$ffProfile" &
	else	echo;
		"$browserExe" &;
	fi
else
	echo;
	echo "A $browserName instance of '$ffProfile' is already running.";
fi