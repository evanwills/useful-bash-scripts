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
# Updated: 2022-02-04
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
# @function Get a ticket ID from the branch name if possible
#
# @param {string} Branch name
#
# @return {string} if ticket ID could be found return ticket prefixed
#                  with "#" and suffixed with space (e.g. "#1234 ").
#                  Otherwise return empty string
# -----------------------------------------------
function branchName2TicketID () {
	_input="$1";
	_tmp1=$(echo $_input | sed 's/^\([^/]\+\/\)\+//');
	_output='';

	if [ "$_input" != "$_tmp1" ]
	then	_hasID=$(echo "$_tmp1" | grep '^[0-9]\{4,7\}[^/]\+$');

		if [ ! -z "$_hasID" ]
		then	_tmp2=$(echo "$_hasID" | sed 's/^\([0-9]\+\).*$/\1/');

			if [ "$_hasID" != "$_tmp2" ]
			then	_output="#$_tmp2 ";
			fi
		fi
	fi

	echo "$_output";
}

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

branch=$(git status | grep 'On branch ' | sed 's/on branch //i');

# Strip leading and trailing white space (if any)
msg=$(echo $@ | sed 's/^[\r\n\t ]\+|[\r\n\t ]\+$//g');

echo '$msg: '$msg

if [ ! -z "$msg" ]
then	ticketID=$(branchName2TicketID "$branch");

	msg="$ticketID$msg";

	echo 'Commiting all recent changes';
	echo
	echo "git commit -am '$msg'";
	echo;
	git commit -am "$msg";
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
	date '+%Y-%m-%d %H:%M:%S';
	echo;
done

