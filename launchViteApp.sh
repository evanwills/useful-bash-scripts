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

# debug () {
# 	echo '----------------------------------------';
# 	echo "launchViteApp.sh - Line: $1";
# 	echo "      \$$2: '$3'";
# 	echo '----------------------------------------';
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

# debug 40 '1' "$1";
# debug 41 '2' "$2";
# debug 42 '3' "$3";
# debug 43 '4' "$4";
# debug 44 '5' "$5";

repo="$1";
appName="$2";
startCode="$3";
sleeper="$4";
ffProfile="$5";

# debug 52 'repo' "$repo";
# debug 53 'appName' "$appName";
# debug 54 'startCode' "$startCode";
# debug 55 'sleeper' "$sleeper";
# debug 56 'ffProfile' "$ffProfile";

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

# debug 101 'repo' "$repo";
# debug 102 'appName' "$appName";

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
# debug 131 'repo' "$repo";
# debug 132 'appName' "$appName";
# debug 133 'startCode' "$startCode";
# debug 134 'sleeper' "$sleeper";
# debug 135 'lkAppName' "$lkAppName";
# debug 135 'lockFile' "$lockFile";

if [ ! -f $lockFile ]
then	# touch $lockFile

	# Get a deterministic name for the server launch file
	# App name may not always be populated
	output="repo:$repo\napp:$appName\nstart:$startCode\nprofile:$ffProfile\ndelay:$sleeper";

	hash=$(echo $output | md5sum | cut -f1 -d" " | sed 's/^\([a-z0-9]\{8\}\).*$/\1/i');
	# debug 138 'hash' $hash;

	lk="$HOME/.$hash.vite-serve"

	if [ ! -f $lk ]
	then	# Write the launch file
		echo 'repo:'$repo > $lk;
		echo 'app:'$appName >> $lk;
		echo 'start:'$startCode >> $lk;
		echo 'delay:'$sleeper >> $lk;
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

