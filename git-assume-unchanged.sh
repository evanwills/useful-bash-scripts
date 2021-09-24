#!/bin/sh

notGit=$(git status | grep 'fatal: not a git repository')

echo; echo;
if [ -z $noGit ]
then	# This directory is part of a Git repo

	if [ ! -z "$1" ]
	then	# We have something to work with
		unchanged="$1";

		if [ -f $unchnaged ]
		then	# The supplied parameter is a file name
			# We can keep going

			isInRepo=$(git ls-files | grep "$uncahged")

			if [ ! -z "$isInRepo" ]
			then	# The file is definitely in the repo
			
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

				echo "git update-index $assume $unchanged"; echo; 

				# if [ $no -eq 1 ]
				# then	git update-index --no-assume-unchanged $unchanged;
				# else	git update-index --assume-unchanged $unchanged;
				# fi

				git update-index $assume $unchanged;
			else	echo 'Supplied file name "'$unchanged'" is not in the repo'; 
			fi
		else	echo '"'$unchanged'" is not a file'
		fi
	else	echo "Cannot update repo's index because no file is supplied"
	fi
else	echo 'This is not a repo'
fi

echo; echo;

