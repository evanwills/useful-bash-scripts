#!/bin/sh

echo 'launchViteApp.sh';

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
# The actual launching of the server is done by another
# script (launchViteApp.sub.sh) which is called by the
# .bashrc file each time a terminal is opened.
# ---------------------------------------------------------

# ---------------------------------------------------------
# debug() renders the name of the file, the line debug was called from (passed as the first parameter) the
#
# ---------------------------------------------------------
# debug () {
# 	echo '----------------------------------------';
# 	echo "launchViteApp.sh - Line: $1";
# 	if [ ! -z "$2" ]
# 	then	if [ ! -z "$3" ]
# 			then	echo "      \$$2: '$3'";
# 			else	echo "$2";
# 			fi
# 			echo '----------------------------------------';
# 	fi;
# }

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

# debug 51 '1' "$1";
# debug 52 '2' "$2";
# debug 53 '3' "$3";
# debug 54 '4' "$4";
# debug 55 '5' "$5";
# debug 56 '6' "$6";

repo="$1";
appName="$2";
startCode="$3";
sleeper="$4";
# ffProfile="$5";
customCmd="$5";

# debug 65 'repo' "$repo";
# debug 66 'appName' "$appName";
# debug 67 'startCode' "$startCode";
# debug 68 'sleeper' "$sleeper";
# debug 70 'customCmd' "$customCmd";
# debug 69 'ffProfile' "$ffProfile";

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
fi

# debug 110 'repo' "$repo";
# debug 111 'appName' "$appName";

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

if [ ! -d "$repo" ]
then	echo 'Could not find repo for '$appName
	echo 'Target directory: '$repo;
	exit;
fi

lkAppName=$(echo "$appName" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-\|-$//g');
lockFile=$HOME'/.'$lkAppName'.vite.lock';

launchThis="/bin/sh $thisDir/launchViteApp.sh '$1' '$2' '$3' '$4';";

echo;
echo '# launchViteApp.sh';
# debug 141 'repo' "$repo";
# debug 142 'appName' "$appName";
# debug 143 'startCode' "$startCode";
# debug 144 'sleeper' "$sleeper";
# debug 145 'customCmd' "$customCmd";
# debug 146 'lkAppName' "$lkAppName";
# debug 147 'lockFile' "$lockFile";

if [ ! -f $lockFile ]
then	# touch $lockFile

	# Get a deterministic name for the server launch file
	# App name may not always be populated
	output="repo:$repo\napp:$appName\nstart:$startCode\nprofile:$ffProfile\ndelay:$sleeper\ncustomCmd:$customCmd";

	hash=$(echo $output | md5sum | cut -f1 -d" " | sed 's/^\([a-z0-9]\{8\}\).*$/\1/i');
	# debug 143 'hash' $hash;

	lk="$HOME/.$hash.vite-serve"

	if [ ! -f $lk ]
	then	# Write the launch file
		echo 'repo:'$repo > $lk;
		echo 'app:'$appName >> $lk;
		echo 'start:'$startCode >> $lk;
		echo 'delay:'$sleeper >> $lk;
		echo 'customCmd:'$customCmd >> $lk;
		# echo 'profile:'$ffProfile >> $lk;

		echo; echo; echo;
		echo '==================================================';
		tail "$lk";
		echo '==================================================';
		echo; echo; echo;
	fi

	# Spawn a new terminal just for the Vite server
	start mintty -

else	echo;
	echo "$appName Dev server is already running.";
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

