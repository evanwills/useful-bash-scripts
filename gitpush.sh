#!/bin/sh

# ---------------------------------------------------------
# This file is a temporary bash script for uploading files
# to [[HOST]] ([[SERVER_NAME]])
#
# created: [[CREATED]]
# by:      [[USER]]
# ---------------------------------------------------------


echo; echo;

# -----------------------------------------------
# @var {string} $noGit - Whether or not the
#                        current working directory
#                        is within a git
#                        repository
# -----------------------------------------------
noGit=$(git remote -v | grep fatal);

if [ ! -z $noGit ]
then	echo 'This directory is not part of a git repository';
	echo 'so there is nothing to push';
	echo; echo;

	exit;
fi


# -----------------------------------------------
# @var {integer} $remotes - How many remote
#                           repositories can this
#                           repo be pushed to
# -----------------------------------------------
remotes=$(git remote -v | grep -c push);

if [ $remotes -gt 1 ]
then	s='ies';
else	s='y';
fi

echo 'About to push to '$remotes' repositor'$s;
echo;
echo;

msg=$(echo $1 | sed 's/[\t ]\+//g');

if [ ! -z "$msg" ]
then	echo 'Commiting all recent changes';
	echo
	echo "git commit -am '$1'";
	echo;
	git commit -am "$1";
	echo; echo;
fi

# -----------------------------------------------
# @var {string} $branch - The branch currently
#                         being worked on
# -----------------------------------------------
branch=$(git status | grep 'On branch ' | sed 's/on branch //i');

while [ $remotes -gt 0 ]
do	# -----------------------------------------------
	# @var {string} $tmp - Full remote listing for a
        #                      given repository
	# -----------------------------------------------
	tmp=$(git remote -v | grep push | head -n $remotes | tail -n 1)

	# -----------------------------------------------
	# @var {string} $remote - Name of the remote
	#                         repository being pushed
	#                         to
	# -----------------------------------------------
	remote=$(echo $tmp | sed 's/^\([^ ]\+\).*$/\1/');

	# -----------------------------------------------
	# @var {string} $domain - Domain of the remote
	#                         repository being pushed
	#                         to
	# -----------------------------------------------
	domain=$(echo $tmp | sed 's/^[^@]\+@\([^:]\+\):.*$/\1/')

	echo 'Pushing '$branch' branch up to '$remote' ('$domain')';

	git push $remote $branch;

	# decrement remotes count to get next remote
	remotes=$(($remotes - 1));

	echo;
	echo;
done

