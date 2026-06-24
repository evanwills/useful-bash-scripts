#!/bin/sh

# ---------------------------------------------------------
# This script transforms a config string into arguments for
# launchViteApp.sh
# ---------------------------------------------------------

input="$1";

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="$thisDir/launchViteApp.sh";

debug () {
	echo '----------------------------------------';
	echo "launchViteApp.pre.sh - Line: $1";
	echo "      \$$2: '$3'";
	echo '----------------------------------------';
	echo;
}

debug 37 'input' "$input";

declare -a appParts;

IFS='|' read -r -a appParts <<< "$input";

debug 27 'input' "$input";
debug 28 'appParts' "${appParts[@]}";

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
# stayOpen='; echo; read -n 1 -s -r -p \"Press any key to close...\"'

# debug 45 'repoLk' "$repoLk";
# debug 46 'tmpLock' "$tmpLock";
# debug 47 'base' "$base";
# debug 48 'repo' "$repo";
# debug 49 'label' "$label";
# debug 50 'code' "$code";
# debug 51 'profile' "$profile";
# debug 52 'sleeper' "$sleeper";
# debug 53 'customCmd' "$customCmd";

if [ -z "$repo" ]
then
	exit;
fi

if [ ! -f "$tmpLock" ]
then
	echo "Launching ViteJS:     $repo";

	debug 64 "$launchThis '$repo' '$label' $code $sleeper '$profile' '$customCmd'";

	$launchThis "$repo" "$label" "$code" "$sleeper" "$profile" "$customCmd";

else 	echo $a' has alrady started';
fi
