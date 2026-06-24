#!/bin/sh

# ---------------------------------------------------------
# This is the primary script that launches ViteJS servers
#
# For better usability, this script causes a new terminal
# to be spawned each time a ViteJS dev server is launched
# so the developer can have one terminal for doing things
# (like running other scripts) while the server is running
#
# However, due to race conditions that were encountered
# when launching multiple dev servers in close succcession
# This script now generates a launch file (*.vite-serve)
# with a deterministic name. Then when a new terminal is
# launched the first launch file can be called then deleted.
#
# The actual launching of the server is done by done by
# another script (launchViteApp.sub.sh) which is called by
# the .bashrc file each time a terminal is opened.
# ---------------------------------------------------------

echo;
echo '# launchViteApp.sh';
echo;

# debug 52 '1' "$1";
# debug 53 '2' "$2";
# debug 54 '3' "$3";
# debug 55 '4' "$4";
# debug 56 '5' "$5";
# debug 57 '6' "$6";

repo="$1";
appName="$2";
startCode="$3";
sleeper="$4";
ffProfile="$5";
execCmd="$6";

noAutoClose=0;

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.sh - Line: $1";

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

# debug 68 'repo' "$repo";
# debug 69 'appName' "$appName";
# debug 70 'startCode' "$startCode";
# debug 71 'sleeper' "$sleeper";
# debug 72 'ffProfile' "$ffProfile";
# debug 73 'execCmd' "$execCmd";
# debug 74 'noAutoClose' "$noAutoClose";

if [ "$startCode" == 'code' ]
then	startCode=1;
else    if [ "$startCode" == '1' ]
	then	startCode=1;
	else    startCode=0;
	fi
fi

if [ ! -d "$repo" ]
then	if [ -d "$appName" ]
	then	# $appName is directory

		repo=$appName;
		isWc=$(echo $appName | grep web-component)
		if [ ! -z $isWc ]
		then	isWc='wc';
		else	isWc='';
		fi
		appName=$(echo $appName | sed 's/\/$//' | sed 's/^\([^\/]\+\/\)*\([^\/]\+\)$/\2/i')
	else	if [ ! -d "$repo" ]
		then	# Is normal $appName

			isWc=$(echo $repo | sed 's/^\(\(wc\|tsf|vue3\)-\)\?.*$/\2/i');

			if [ ! -z "$isWc" ]
			then 	if [ -z "$appName" ]
				then	appName=$(echo "$repo" | sed 's/^\(wc\|tsf|vue3\)-\(.*\)$/\2/i');
				else	if [ "$appName" == "$repo" ]
					then 	appName=$(echo "$repo" | sed 's/^\(wc\|tsf|vue3\)-\(.*\)$/\2/i');
					fi
				fi

				isWc=${$isWc,,};
			fi

			repo=$(echo $repo | sed 's/\([A-Z]\)/-\1/g')
			repo=${repo,,};
			case "$isWc" in
				'wc')	repo=$_code'/web-components/'$repo'/';
					;;
				'tsf')	repo=$HOME'/Documents/TSF-code/'$repo'/';
					;;
				'v3')	repo=$HOME'/Documents/Evan/code/family-portal--Vue3--component/'$repo'/';
					;;
				*)	repo=$_code'/'$repo'/';
					;;
			esac
		fi
	fi
	appName=$(echo $appName | sed 's/\/$//' | sed 's/^\([^\/]\+\/\)*\([^\/]\+\)$/\2/i')
fi

debug 149 'repo' "$repo";
debug 150 'appName' "$appName";

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

if [ ! -d "$repo" ]
then	echo 'Could not find repo for '$appName
	echo 'Target directory: '$repo;
	exit;
fi

lkAppName=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-\|-$//g');
lockFile=$HOME'/.'$lkAppName'.vite.lock';

launchThis="$thisDir/launchViteApp.sub.sh '$repo' '$appName' '$startCode' '$sleeper' '$ffProfile' '$execCmd';";

# debug 143 'startCode' "$startCode";
# debug 144 'sleeper' "$sleeper";
# debug 145 'ffProfile' "$ffProfile";
# debug 146 'execCmd' "$execCmd";
# debug 147 'lkAppName' "$lkAppName";
# debug 148 'lockFile' "$lockFile";
# debug 149 'launchThis' "$launchThis";

if [ ! -f $lockFile ]
then
	# Spawn a new terminal just for the Vite server

	if [ "$noAutoClose" == 1 ]
	then	mintty --hold always -e bash -lc "$launchThis" &
	else	mintty -e bash -lc "$launchThis" &
	fi

else	echo;
	echo "$appName Dev server is already running.";
	echo;
	echo "It may be that you need to remove the lock file and rerun this script.";
	echo;
	echo;
	echo '```';
	echo "	rm $lockFile;"
	echo "	/bin/sh $launchThis";
	echo;
	echo '```';
	echo;
	echo;
fi

