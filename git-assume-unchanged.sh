#!/bin/sh

echo 'About to try and update the index of a Git repo';
echo;
echo 'Expected syntax:';
echo;
echo '	$ unchanged [file name] [? | no | restore | revert]';
echo;
echo '	e.g.';
echo '		# To remove .gitignore from list of files that show up as changed.';
echo '	$ unchanged .gitignore;';
echo;
echo '  or';
echo '		# To # re-add .gitignore from list of files that show up as changed.';
echo '	$ unchanged .gitignore no;';
echo;



notGit=$(git status | grep 'fatal: not a git repository')

echo; echo;
if [ ! -z $noGit ]
then	echo 'This is not a repo';
	exit;
else	echo 'We are in a repo';
fi

# -----------------------------------------------
# This directory is part of a Git repo

if [ -z "$1" ]
then	echo "Cannot update repo's index because no file is supplied";
	exit;
else	echo 'We are have a potential file';
fi


# -----------------------------------------------
# We have something to work with


unchanged="$1";

if [ ! -f $unchnaged ]
then	echo '"'$unchanged'" is not a file'
else	echo 'We are have a confirmed file: "'$unchanged'"';
fi


# -----------------------------------------------
# The supplied parameter is a file name
	# We can keep going

isInRepo=$(git ls-files | grep "$uncahged")

if [ -z "$isInRepo" ]
then	echo 'Supplied file name "'$unchanged'" is not in the repo';
else	echo 'Supplied file name "'$unchanged'" is listed in the repo';
fi


# -----------------------------------------------
# The file is definitely in the repo

no=0;

if [ ! -z "$2" ]
then 	if [ "$2" == 'no' ]
	then	no=1;
	else	if [ "$2" == 'restore' ]
		then	no=1
		else	if [ "$2" = 'revert' ]
			then	no=1
			fi
		fi
	fi
fi

if [ $no -eq 1 ]
then	assume='--no-assume-unchanged';
	will='once more';
else	assume='--assume-unchanged';
	will='not';
fi
echo; echo;
echo 'Updating index so that "'$unchanged'" will '$will' show up as a changed file';
echo;
echo "git update-index $assume $unchanged"; echo;

# if [ $no -eq 1 ]
# then	git update-index --no-assume-unchanged $unchanged;
# else	git update-index --assume-unchanged $unchanged;
# fi

git update-index $assume $unchanged;



echo; echo;

