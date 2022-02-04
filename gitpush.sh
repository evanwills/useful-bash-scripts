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
# This script was created because I was working late one
# night and committed my changes but forgot to push them
# up to the server because I was tired. The next day my
# laptop's drive died and I lost all the work I'd done the
# day before. I now use it all the time so that when I'm
# collaborating with colleagues, I know that my changes are
# always up on the repo.
#
# created: 2021-10-20
# by:      Evan Wills <evan.i.wills@gmail.com>
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

if [ ! -z "$2" ]
then	# Someone's a bozo and forgot to wrap
	# their comments in quotes.
	# Let's put it together for them.
	msg="$1 $2";

	if [ ! -z "$3" ]
	then	msg="$msg $3";

		if [ ! -z "$4" ]
		then	msg="$msg $4";

			if [ ! -z "$5" ]
			then	msg="$msg $5";

				if [ ! -z "$6" ]
				then	msg="$msg $6";

					if [ ! -z "$7" ]
					then	msg="$msg $7";

						if [ ! -z "$8" ]
						then	msg="$msg $8";

							if [ ! -z "$9" ]
							then	msg="$msg $9";
							fi
						fi
					fi
				fi
			fi
		fi
	fi
else	msg=$(echo $1 | sed 's/[\t ]\+/ /g');
fi

# Strip leading and trailing white space (if any)
msg=$(echo $msg | sed 's/^[\r\n\t ]\+|[\r\n\t ]\+$//g');

if [ ! -z "$msg" ]
then	echo 'Commiting all recent changes';
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
done

