#!/bin/sh
currentDir=$(pwd)
root=$(git rev-parse --show-toplevel)
cd "$root"

mapfile -t files < <(
  git status --porcelain | grep -E '^ M' | awk '{print $2}'
)

count=${#files[@]}
current=0;
remaining=$count

function handle_single_file {
	local file="$1";
  	current=$((current+1));
  	remaining=$((count-current));

	clear;

	echo;
	echo '- - - - - - - - - - - - - - - - - - - - -';
	echo;
	echo "File $current of $count"
	echo "    (Remaining $remaining files)"
	echo;

	git diff -- "$file"

	echo;
	echo '- - - - - - - - - - - - - - - - - - - - -';
	echo;

	echo "Would you like to stage, revert, or skip this file?"
	echo "	$file";
	echo "	Options: ";
	echo "		a: add";
	echo "		c: checkout";
	echo "		e/q: exit";
	echo "		s: skip";

	read -p " (a, c, e/q, s): " answer

	echo; echo;
	case "$answer" in
	a|A)
		git add -- "$file"
		echo "Staged $file"
		;;
	c|C)
		git checkout -- "$file"
		echo "Reverted $file"
		;;
	e|E|q|Q)
		cd "$currentDir"
		git status;
		exit 0
		;;
	*)
		echo "Skipped $file"
		;;
	esac
}

for file in "${files[@]}"; do
  handle_single_file "$file"
done

git status;
cd "$currentDir"
