#!/bin/sh

# =========================================================
# This script recreates two existing branches (DEV & UAT)
# in the ACU.Sitecore repo to ensure they are not poluted
# with unwanted (stale/experimental) code.
#
# It also deletes old branches
#
# It makes a few assumptions:
#
# 1. Branches that haven't received commits in $commitedInDays
#    days (currently 21 days) are stale and should not be
#    included in the replacement branch
#
# 2. Branches that have already been merged into a higher
#    commitedInDays branchshould not be included in the
#    replacement branch (toggled by $compareWithHigher)
#
# 3. Only branches that can be merged via fast-forward
#    should be included in the replacement branch
#
# @author  Evan Wills <evan.wills@acu.edu.au>
# @date    2021-04-30
# @version 0.0.1
# =========================================================



# =========================================================
# START: Initial setup



# -----------------------------------------------
# @var {integer} $compareWithHigher - Whether or
#               not to compare merged branches
#               with those merged into higher
#               the branch
#		1 = TRUE, 0 = FALSE
# -----------------------------------------------
compareWithHigher=1


# -----------------------------------------------
# @var {integer} $deleteOldBranches - Whether or
#               not to delete old branches
#		1 = TRUE, 0 = FALSE
# -----------------------------------------------
deleteOldBranches=1


# -----------------------------------------------
# @var {integer} $commitedInDays - The maximum number
#		of days since the last commit to
#               a branch used for filtering out
#               branches
# -----------------------------------------------
commitedInDays=21;


# -----------------------------------------------
# @var {integer} $maxBranchAge - The maximum number
#		of days since the last commit to
#               a branch used for choosing which
#               branches should be deleted
# -----------------------------------------------
maxBranchAge=365;


# -----------------------------------------------
# @var {array} $branches - List of all the branches
#		to be processed Start with the lowest
#		level branch
#
# NOTE: the final branch in the list doesn't ever
#	get proccessed. It's used for comparing
#	merges against the merges for the
#	preceeding branch
#
# NOTE ALSO: The last/highest branch in the list
#	should be 'master' or 'PROD' or equivalent
# -----------------------------------------------
branches=('DEV', 'UAT', 'master')


# -----------------------------------------------
# @var {string} $repoDir - The directory/folder
#               where the git repo is stored
# -----------------------------------------------
repoDir='/c/ACU.sitecore/'


# -----------------------------------------------
# @var {string} $mergedHigh - The file to store
#               the list of all the branches merged
#               into the higher branch
# -----------------------------------------------
mergedHigh='merged-into-high.txt'


# -----------------------------------------------
# @var {string} $mergableList - The file that
#               (temporarily) stores the list of
#               all the branches that should be
#               merged into the target branch
# -----------------------------------------------
mergableList='not-merged-to-target.txt'


# -----------------------------------------------
# @var {string} $canNotMerge - The file to log
#               the list of all the branches that
#               could not be merged into the
#               target branch
# -----------------------------------------------
canNotMerge='unmergable-branches.txt'


# -----------------------------------------------
# @var {integer} $maxAge - The maximum number of
#               seconds ago a commit was made to
#               a branch to make that branch
#               eligable for remerging
# -----------------------------------------------
maxAge=$((3600 * 24 * $commitedInDays))


# -----------------------------------------------
# @var {integer} $now - Timestamp for the current
#               time
# -----------------------------------------------
now=$(date '+%s')




#  END:  Initial setup
# =========================================================
# START: function declarations



# -----------------------------------------------
# @function iso8601date() Convert the string out of GNU date to
# ISO 8601 date format
#
# @param {string} date string
#
# @return {string} ISO 8601 formatted string
# -----------------------------------------------
function iso8601date () {
	date_="$1"

	# convert the string into rudimentary ISO 8601 format

	# -----------------------------------------------
	# @var {string} $_date - Rudimentary ISO 8601 format date
	#               string with a placeholder for month value
	# -----------------------------------------------
	_date=$(echo $date_ | sed 's/^[a-z]\+ \(\+[a-z]\+\) \+[0-9]\+ \+\([0-9]\+:[0-9]\+:[0-9]\+\) \+\([0-9]\+\) \++[0-9]\+/\3-###-\1 \2/i')

	# extract the month identifier

	# -----------------------------------------------
	# @var {string} $_month - Three letter string for month in
	#               date string (to be converted to a numeric
	#               string by case statement)
	# -----------------------------------------------
	_month=$(echo $date_ | sed 's/^[a-z]\+ \+\([a-z]\+\) \+[0-9]\+ \+[0-9]\+:[0-9]\+:[0-9]\+ \+[0-9]\+ \++[0-9]\+/\1/i')

	# Convert the month identifier to numeric string
	case "$_month" in
		'Jan')	m=01;
			;;

		'Feb')	m='02';
			;;

		'Mar')	m='03';
			;;

		'Apr')	m='04';
			;;

		'May')	m='05';
			;;

		'Jun')	m='06';
			;;

		'Jul')	m='07';
			;;

		'Aug')	m='08';
			;;

		'Sep')	m='09';
			;;

		'Oct')	m='10';
			;;

		'Nov')	m='11';
			;;

		'Dec')	m='12';
			;;
	esac

	# Merge the numeric month value into the ISO 8601 date string
	_date=$(echo $_date | sed 's/-###-/-'$m'-/')

	# Convert the date to a timestamp

	# -----------------------------------------------
	# @var {integer} $stamp - The Unix Timeestamp for the
	#               supplied date string
	# -----------------------------------------------
	stamp=$(date --date="$_date" +%s)

	# Return the difference (in seconds) between now and when
	# the branch last had a commit
	echo $(($now - $stamp))
}



# -----------------------------------------------
# @function getBranch() Make sure a branch is available locally
#
# @param {string} Name of a branch
#
# @return {integer} 1 if the branch could be fetched. 0 otherwise
# -----------------------------------------------
function getBranch () {
	branchName="$1"
	branchExists=$(git branch -a | grep "$branchName$")

	if [ ! -z $branchExists ]
	then	# The branch exists
		# Get the latest version
		git fetch origin $branchName
		echo 1
	else	# Could not find the branch
		echo 0
	fi
}



# -----------------------------------------------
# @function grepSafe() Clean a branch name so it can be used
#                 as a grep filter
#
# @param {string} Name of a branch
#
# @return {string}
# -----------------------------------------------
function grepSafe () {
	output=$(echo "$1" | sed 's/\([^a-z0-9-_]\)/\\\1/ig')
	echo '^\* '$output'$'
}

# -----------------------------------------------
# @function cleanBranchName() Trim a string
#
# @param {string} Name of a branch
#
# @return {string}
# -----------------------------------------------
function cleanBranchName () {
	echo $(echo $1  | sed 's/^\*\?[\t ]\+|[\t\ ]\+$//g')
}

# -----------------------------------------------
# @function fetchAndLog() Get a local copy or update the existing
#                 copy of a specified branch and increment a counter
#
# @param {string}  Name of a branch
# @param {integer} Number of branches already included
#
# @return {integer} Number of branches already included plus one
# -----------------------------------------------
function fetchAndLog () {
	branch="$1"
	count=$2

	# Add this branch to the list of
	# branches to add to the replacement
	# branch
	echo $branch >> $mergableList;

	# Grab the latest version
	git fetch origin $branch

	echo $(($count + 1))
}

# -----------------------------------------------
# @function createCleanBranch() Create new version of the current branch
#               from Master with only recent branch merged included
#
# 1. Find all the branches recently merged into the target branch
#    and record them in a file.
# 2. Delete the target branch, both locally and on the remote server
# 3. Create a new version of branch from `master`
# 4. Merge all the branches (recorded in step 1.)
# 5. Push the new copy of the target branch up to the remote server
#
# @param {string} Name of the target branch
# @param {string} Name of the higher which contains.
#                 All branches merged into both the target branch
#                 and the higher branch will be omitted from the new
#                 target branch
#
# @return void
# -----------------------------------------------
function createCleanBranch () {
	# -----------------------------------------------
	# @var {string} $targetBranch - The name of the target
	#                branch this function will work on
	# -----------------------------------------------
	targetBranch="$1"

	# -----------------------------------------------
	# @var {string} $highBranch - The name of the branch to
	#                compare merged branches with
	# -----------------------------------------------
	highBranch="$2"

	# -----------------------------------------------
	# @var {integer} $branchExists - Whether or not a branch
	#                exists
	#                1 = TRUE, 0 = FALSE
	# -----------------------------------------------
	branchExists=$(getBranch "$targetBranch")

	if [ $branchExists -eq 0 ]
	then	echo "Could not get branch: '$branchExists'.";
		return
	fi

	branchExists=$(getBranch "$highBranch")

	if [ $branchExists -eq 0 ]
	then	echo "Could not get branch: '$branchExists'.";
		return
	fi

	# Create a list of branches merged into the current branch
	if [ -f $mergableList ]
	then	rm $mergableList;
	fi
	touch $mergableList;


	if [ $compareWithHigher -eq 1 ]
	then	# Move to the higher branch
		git checkout $highBranch

		# Write the list of all the branches merged to the higher branch
		git branch -a --merged | grep -v $(grepSafe $highBranch) | sed 's/^[\t ]\+//g' > $mergedHigh
	fi

	# Switch to the target branch to get everything done.
	git checkout $targetBranch;

	# -----------------------------------------------
	# @var {array} $remergeCount - List of all branches that have
	#                ever been merged into target branch
	# -----------------------------------------------
	branchesMergedIn=($(git branch -a --merged | grep -v  $(grepSafe $targetBranch) | sed 's/^[\t ]\+//g'))


	# -----------------------------------------------
	# @var {integer} $remergeCount - The number of branches to be
	#                remerged into new branch
	# -----------------------------------------------
	remergeCount=0;

	for $branch in ${branchesMergedIn[@]}
	do	# Get the date of the last commit to this branch

		branch=$(cleanBranchName $branch)

		# -----------------------------------------------
		# @var {integer} $branchAge - The number of seconds
		#                since the last commit to this branch
		# -----------------------------------------------
		$branchAge=$(git log -n 1 $branch | grep Date | sed 's/Date: \+//')

		# convert that date to the number of seconds
		# since this script started
		$branchAge=$(iso8601date $branchAge)

		if [ $branchAge -lte $maxAge ]
		then	# This has received commits recently enough
			# to be included in the replacement version
			# of the branch

			if [ $compareWithHigher -eq 1 ]
			then	# Check if this branch has been
				# merged into the higher branch

				# -----------------------------------------------
				# @var {string} $alreadyInHigh - Whether or not this
				#                branch has already been merged into
				#                the higher branch
				#                Empty string if branch has not been
				#                merged into higher branch
				# -----------------------------------------------
				alreadyInHigh=$(grep "$branch" $mergedHigh)

				if [ -z "$alreadyInHigh" ]
				then	# This branch hasn't already been merged into $highBranch
					remergeCount=$(fetchAndLog $branch $remergeCount)
				fi
			else	# We don't care about other branches
				remergeCount=$(fetchAndLog $branch $remergeCount)
			fi
		fi
	done

	# Move to the master branch since that will be our base for
	# the replacement branch
	git checkout master

	# Delete the current version of this branch both locally
	# and in GitLab
	git branch -a -d -f $targetBranch

	# Create the new branch
	git checkout -b $targetBranch

	# -----------------------------------------------
	# @var {array} $toMerge - list of branches that are to be
	#                merged back into the new branch
	# -----------------------------------------------
	toMerge=($(grep * $mergableList))

	# -----------------------------------------------
	# @var {string} $unmergableLog - Name of file to log the
	#                names of unmergable branches
	# -----------------------------------------------
	unmergableLog=$(echo $canNotMerge | sed s'/\(\.txt\)/__'$targetBranch'\1/')


	if [ -f $tmpLog ]
	then	# Make sure log file is empty
		rm $unmergableLog
	fi

	touch $unmergableLog


	# -----------------------------------------------
	# @var {integer} $remergeCount - The number of branches to be
	#                remerged into new branch
	# -----------------------------------------------
	remergeCount=0;

	for $branch in ${branchesMergedIn[@]}
	do	# Only merge if fast forward is possible

		# -----------------------------------------------
		# @var {string} $msg - The output of a fatal merge
		#                attempt
		#                (Empty string if merge was successful)
		# -----------------------------------------------
		msg=$(git merge --ff-only $branch | grep 'fatal')

		if [ ! -z $msg ]
		then	# Merge failed! log the branch name
			echo $branch >> $unmergableLog

			remergeCount=$(($remergeCount + 1))
		fi
	done

	# Make sure the replacement branch is pushed back up to GitLab
	git push origin $targetBranch;

	if [ $remergeCount -eq 0 ]
	then	# No failed merges so delete the log file
		rm $unmergableLog;
	fi

	# We don't need the list of merged branches any more so
	# delete it
	rm $mergableList
}



#  END:  function declarations
# =========================================================
# START: Doin' tha do



cd $repoDir

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# START: recreating branches



# -----------------------------------------------
# @var {integer} $c - Total number of branches to be processed
# -----------------------------------------------
c=${#branches[@]}

if [ $c -gt 0 ]
	if [ $c -gt 1 ]
	then	# We're dealing with multiple branches
		# So loop through the branches
		for b in ${!branches[@]};
		do	if [ $b -gt 1 ]
			then	# -----------------------------------------------
				# @var {integer} $a - The index of the preceding
				#		branch
				# -----------------------------------------------
				a=$(($b - 1))

				# Clean previous branch and compare with current branch
				createCleanBranch ${branches[$a]} ${branches[$b]}
			fi
		done
	else	# We only have one branch to work with
		# Pass in a dummy string for second (higher) branch
		createCleanBranch ${branches[0]} 'XOXOXXOX'
	fi
fi



#  END:  recreating branches
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
# START: deleting old branches

if [ $deleteOldBranches -eq 1 ]
then	# It's OK to delete old branches

	# -----------------------------------------------
	# @var {array} $compareWithHigher - List of all
	#		the branches in the repo
	#		1 = TRUE, 0 = FALSE
	# -----------------------------------------------
	allBranches=($(git branch -a))

	# -----------------------------------------------
	# @var {integer} $oneYear - The number of seconds in a year
	# -----------------------------------------------
	oneYear=$((3600 * 24 * $maxBranchAge))

	for $branch in ${branchesMergedIn[@]}
	do	# -----------------------------------------------
		# @var {integer} $branchAge - The number of seconds
		#                since the last commit to this branch
		# -----------------------------------------------
		$branchAge=$(git log -n 1 $branch | grep Date | sed 's/Date: \+//')

		# convert that date to the number of seconds
		# since this script started
		$branchAge=$(iso8601date $branchAge)

		if [ $branchAge -gt $oneYear ]
		then	# This branch hasn't had commit in over a year
			# Delete it!!!
			git branch -d -f $branch
		fi
	done
fi

#  END:  deleting old branches
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-


#  END:  Doin' tha do
# =========================================================

