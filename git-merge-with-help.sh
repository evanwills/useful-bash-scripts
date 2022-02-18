#!/bin/sh


thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

# -----------------------------------------------
# @var {string} $noGit - Whether or not the
#                        current working directory
#                        is within a git
#                        repository
# -----------------------------------------------
noGit=$(git remote -v | grep fatal);

if [ ! -z $noGit ]
then	echo 'This directory is not part of a git repository';
	echo 'so we can not even attempt to merge';
	echo; echo;

	exit;
fi

echo;
echo;
echo $(pwd);
echo;

_mine=0;
_theirs=0;
_skipped=0;

# ------------------------------------------------
# Show Diff for file with merge conflict.
# Then ask the user what they want to do about the
# conflict.
# Then do what user wanted
# Finally, (if something was done), add the file to
# the next commit
#
# @param {string} Path to file with merge conflict
# ------------------------------------------------
checkoutAdd () {
	ok=0;
	file=$( echo "$1" | sed 's/^[ \t]*both modified:\?[ \t]*//ig');
	isCSS=$( echo $file | grep '\.\(css\|map\)$');

	echo;
	echo;

	if [ -z $isCSS ]
	then	git diff "$file";
		echo;
		echo;
	fi

	echo 'Which version of "'$file'" to you want to keep';
	echo 'Type "theirs" to keep the incoming version or';
	echo '     "ours"   to keep the current version.';
	echo '(Press enter to skip & deal with it later)';
	echo;
	read which</dev/tty

	if [ ! -z "$which" ]
	then	if [ $which == 'ours' ]
		then	echo 'You have chosen to keep your changes.';
			git checkout --ours "$file";
			ok=1;
			_mine=$(($_mine + 1))
		else	if [ $which == 'theirs' ]
			then	echo 'You have accept their changes.';
				git checkout --theirs "$file";
				ok=1;
				_theirs=$(($_theirs + 1))
			fi
		fi
	fi

	if [ $ok -eq 0 ]
	then	echo 'Skipping '$file' (you will have to merge that your self later)';
		_skipped=$(($_skipped + 1))
	else	git add "$file";
	fi
}





if [ ! -z "$1" ]
then	isBranch=$(git branch -v | grep "$1");

	if [ ! -z "$isBranch" ]
	then	# Clean up compiled CSS files before merging branch
		/bin/sh $thisDir'checkoutCss.sh';

		# Do the actual merging
		git merge "$1";

		# ------------------------------------------------
		# Random file name to use for temporary file
		#
		# @var string
		# ------------------------------------------------
		tmpFile='zIl9YNXsHRRTugRC7WcpLFWAFocTvSH7EldPfxa0cmOoHbhX8MJnkVaOcl6qsoI.txt';
		_c=0;


		# Get the current status and put the bits we need into a file
		git status | grep 'both modified' > $tmpFile;

		# Process each line of the file
		while IFS= read -r line
		do	# Show diff then ask what to do
			# echo '$line: '$line;
			checkoutAdd "$line"

			_c=$(($_c + 1));

		done < "$tmpFile"

		if [ $_c -eq 0 ]
		then	echo 'There were no files with merge conflicts';

		else	# Give a little report
			echo 'There were a total of '$_c' files with merge conflicts';
			echo 'Of those '$_c' files you:';
			echo '    kept your changes in '$_mine' files';
			echo '    accepted their changes in '$_theirs' files';
			echo '    left '$_skipped' files to be dealt with later';
		fi

		rm $tmpFile;

	else 	echo 'Could not find specified branch: "'$1'"';
		echo;
		echo 'Try fetching it from a remote server'
		echo 'e.g.'
		echo '   $ git fetch origin '$1;
	fi
fi
echo;
echo;
echo;
git status;

echo;
echo;
