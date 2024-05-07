#!/bin/sh

rev=0
src='';

if [ ! -z "$1" ]
then	if [ "$1" == 'rev' ]
	then	rev=1;
		src="$2";
		relPath="$3";
	else	src="$1";
		relPath="$2";
	fi
else	src='';
	relPath='';
fi

postAction='BUILD_FIX_ACTION.sh';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

cd $(pwd);

if [ -f "$postAction" ]
then	rm "$postAction";
fi
echo
echo 'Running BuildFix';
echo

if [ $rev -eq 1 ]
then	echo 'Reversing build fix'
	# gitAll='BUILD_FIX_TMP-all.txt';
	gitChange='BUILD_FIX_TMP-changed.txt';
	gitUntracked='BUILD_FIX_TMP-untracked.txt';

	# git ls-files > "$gitAll";
	git ls-files --others --exclude-standard > "$gitUntracked";

	if [ ! -z "$relPath" ]
	then	relPath=$(echo "$relPath" | sed 's/\//\\\//g');
		relPath=$(echo "$relPath" | sed 's/^\(.*\)$/s\/\1\/\//');

		git ls-files --modified | sed "$relPath" > "$gitChange";
	else	git ls-files --modified > "$gitChange";
	fi

	node $thisDir'build-fix__REV.mjs' "$src";

	# rm "$gitAll" "$gitChange";
	rm "$gitChange" "$gitUntracked";
else	echo 'Fixing build';
	node $thisDir'build-fix__FWD.mjs' "$src";
fi

if [ -f "$postAction" ]
then	# less "$postAction";
	"./$postAction";
	rm "$postAction";
fi

git status;
