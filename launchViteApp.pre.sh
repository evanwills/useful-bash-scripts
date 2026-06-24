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

declare -a appParts;

IFS='|' read -r -a appParts <<< "$input";

debug 32 'input' "$input";
debug 33 'appParts' "${appParts[@]}";

repo="${appParts[0]}";
label="${appParts[1]}";
code="${appParts[2]}";
profile="${appParts[3]}";
sleeper="${appParts[4]}";
customCmd="${appParts[5]}";

if [ "$code" != "code" ]
then	code='X';
fi

if [ "$customCmd" == ',' ]
then	customCmd='';
fi

repoLk=$(echo "$label" | sed 's/[^a-z0-9]\+/-/ig' | sed 's/^-|-$//g');
tmpLock=$HOME'/.'$repoLk'.vite.lock';

# debug 53 'launchMain' "$launchMain";
# debug 54 'repoLk' "$repoLk";
# debug 55 'tmpLock' "$tmpLock";
# debug 56 'base' "$base";
# debug 57 'repo' "$repo";
# debug 58 'label' "$label";
# debug 59 'code' "$code";
# debug 60 'profile' "$profile";
# debug 61 'sleeper' "$sleeper";
# debug 62 'customCmd' "$customCmd";

if [ -z "$repo" ]
then
	exit;
fi

if [ ! -f "$tmpLock" ]
then
	echo "Launching ViteJS:     $repo";

	debug 75 "$launchMain '$repo' '$label' $code $sleeper '$profile' '$customCmd'";

	$launchMain "$repo" "$label" "$code" "$sleeper" "$profile" "$customCmd";

else 	echo $a' has alrady started';
fi
