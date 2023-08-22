#!/bin/sh

# ---------------------------------------------------------
# This script pushes the current branch up to all remote
# repositories this instance of the ropo knows about.
#
# If only one parameter is passed to the script, the script
# will execute a commit using the passed string as the
# message, before pushing the repo up to the remote
# servers.
# If more than one parameter is passed, it is assumed the
# user forgot to wrap their commit message in quotes. The
# first 9 parameters will be concatinated to form a single
# string which will be used as the commit message.
#
# This script was created because, even though I was
# commiting changes on a regular basis, I kept forgetting
# to push my changes up the the server and my colleagues
# kept asking me to do so.
#
# Author:  Evan Wills <evan.i.wills@gmail.com>
# Created: 2021-10-20
# Updated: 2023-06-05
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
remotes=$(git remote -v | grep -c fetch);

if [ $remotes -gt 1 ]
then	s='ies';
else	s='y';
fi

echo 'About to pull from '$remotes' repositor'$s;
echo;
echo;

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
	tmp=$(git remote -v | grep fetch | head -n $remotes | tail -n 1)

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

	echo 'Pulling '$branch' branch down from '$remote' ('$domain')';

	git pull $remote $branch;

	# decrement remotes count to get next remote
	remotes=$(($remotes - 1));

	echo;
	echo;
done

