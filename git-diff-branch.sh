#!/bin/sh

diffFile='diff-files-'$(date +%s%N | md5sum | sed 's/ .*$//')'.txt';

function decho () {
	echo;
	echo;
	echo $1;
	if [ ! -z "$2" ]
	then	echo $2;
		if [ ! -z "$3" ]
		then	echo $3;
			if [ ! -z "$4" ]
			then	echo $4;
			fi
		fi
	fi
	echo;
}

branch=$1;
if [ -z "$branch" ]
then	decho 'Please specify the branch you want to compare';
	git branch -v;

	exit;
fi


ok=$(git branch -v | grep "$branch");

if [ -z "$ok" ]
then	ok=$(git branch -v | grep 'fatal');

	if [ -z "$ok" ]
	then	decho 'Could not find branch to compare';
		git branch -v;
	else	decho 'Not within a Git repository';
	fi
	exit;
fi;

if [ ! -d .git ]
then	noGit=0;
	max=10;

	decho 'This is not the repo root.' "Let's look up the tree one level.";

	while [ $noGit -eq 0 ]
	do
		if [ -d .git ]
		then	break;
		else	cd '../';
			d=$(pwd);
			echo "Checking with if \"$d/\" is the git repo root";
		fi

		max=$(($max - 1));
		if [ $max -lt 0 ]
		then	break;
		fi
	done
fi

decho 'checking for differences between this branch and' "$branch";

git diff --name-only $branch > $diffFile;

while read -r line;
do 	action='r';
	doBreak=0;

	while [ $action == 'r' ]
	do	decho "Showing differences in file: '$line'"; # "git diff '$branch' '$line'";

		git diff "$branch" "$line";


		echo;
		echo '"q" to exit or "r" to diff the same file';
		echo 'Press enter for next file:';
		read action < /dev/tty;

		if [ $action == 'q' ]
		then	doBreak=1;
			break;
		else	if [ -z $action ]
			then	break;
			else	if [ $action  == 'n' ]
				then	break;
				fi;
			fi;
		fi;
	done

	clear;

	if [ $doBreak -eq 1 ]
	then	break;
	fi
done < $diffFile;

rm $diffFile;
