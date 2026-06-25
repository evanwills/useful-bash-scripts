#!/bin/sh

# ---------------------------------------------------------
# This script transforms a config string into arguments for
# launchViteApp.sh
# ---------------------------------------------------------

input="$1";

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchMain="$thisDir/launchViteApp.sh";

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.pre.sh - Line: $1";

	if [[ ! -z "$3" || ! -z "$4" ]]
	then
		if [ ! -z "$3" ]
		then	echo "      \$$2: '$3'";
		else	echo "$2";
		fi
		echo '----------------------------------------';
		echo;
	fi
}

declare -a appParts;

IFS='|' read -r -a appParts <<< "$input";

debug 31 'input' "$input";
debug 32 'appParts' "${appParts[@]}";

repo="${appParts[0]}";
label="${appParts[1]}";
code="${appParts[2]}";
profile="${appParts[3]}";
sleeper="${appParts[4]}";
customCmd="${appParts[5]}";
rootRepo="${appParts[6]}";

if [ "$code" != "code" ]
then	code='X';
fi

if [ "$customCmd" == ',' ]
then	customCmd='';
fi

repoLk=$(echo "$label" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-|-$//g');
tmpLock=$HOME'/.'$repoLk'.vite.lock';

# debug 54 'launchMain' "$launchMain";
# debug 55 'repoLk' "$repoLk";
# debug 56 'tmpLock' "$tmpLock";
# debug 57 'base' "$base";
# debug 58 'repo' "$repo";
# debug 59 'label' "$label" 'force';
# debug 60 'code' "$code" 'force';
# debug 61 'profile' "$profile" 'force';
# debug 62 'sleeper' "$sleeper" 'force';
# debug 63 'customCmd' "$customCmd" 'force';
# debug 64 'rootRepo' "$rootRepo" 'force';

if [ -z "$repo" ]
then
	exit;
fi

if [ ! -f "$tmpLock" ]
then
	echo "Launching ViteJS:     $repo";

	debug 75 "$launchMain '$repo' '$label' $code $sleeper '$profile' '$customCmd' '$rootRepo'";

	$launchMain "$repo" "$label" "$code" "$sleeper" "$profile" "$customCmd" "$rootRepo";

else 	echo $a' has alrady started';
fi
