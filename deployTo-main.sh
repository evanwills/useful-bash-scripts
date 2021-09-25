#!/bin/sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This file is used to upload recently updated files to a given
# server based a runtime argument
#
# If "prod" or "production" is supplied as the first argument, the
# target environment will be the production server. Otherwise target
# server will the the Development server
#
# It depends on a PHP script (deploy-getRecentlyUpdatedFiles.php)
# to do the heavy lifting of working out which files out of all the
# eligible files should be deployed.
#
# Author:  Evan Wills <evan.wills@acu.edu.au>
# Created: 2021-09-23 15:08
# Updated: 2021-09-24 13:40
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



# ================================================
# START: Function declarations

function modTime()
{
    modISO=$(stat "$1" | grep Modify | sed 's/^Modify: //')
    echo $(date -d"$modISO" '+%s');
}

function makeSedSafe()
{
	echo $(echo $1 | sed 's/\([./]\)/\\\1/g')
}


#  END:  Function declarations
# ================================================
# START: Validate arguments

# ------------------------------------------------
# File system path to this script
#
# @var string
# ------------------------------------------------
thisDir="`( cd \"$MY_PATH\" && pwd )`";

if [ -z "$1" ]
then	echo 'You must specify which environment you want to deploy to';
	exit;
else	if [ "$1" == 'new' ]
	then	if [ $(pwd) != $thisDir ]
		then	conf=$(pwd)'/deployTo.sh';
			cp $thisDir'/deployTo.tmpl.sh' $conf;
			sed -i 's/\[\[PATH\]\]/'$(makeSedSafe $thisDir)'/i';
		fi
		exit;
	fi

	if [ -z "$2" ]
	then	echo 'You must specify domain for the production server';
		exit;
	else	if [ -z "$3" ]
		then	echo 'You must specify domain for the devleopment server';
			exit;
		else	if [ -z "$4" ]
			then	echo 'You must specify domain for the local VM server';
				exit;
			else	if [ -z "$5" ]
				then	echo 'You must specify the file system path to the application root';
					exit
				else	if [ -z "$6" ]
					then	echo 'You must specify a list of files and/or directorys eligible for deployment';
					fi
				fi
			fi
		fi
	fi
fi

#  END:  Validate arguments
# ================================================
# START: user maintained config

# ------------------------------------------------
# username to use to connect to remote server
#
# (Assumes SSH key authentication)
#
# @var string
# ------------------------------------------------
user="$2";

# ------------------------------------------------
# Host domain/IP for SCP destination Production
# server
#
# @var string
# ------------------------------------------------
hostProd="$3";

# ------------------------------------------------
# Host domain/IP for SCP destination Development
# server
#
# @var string
# -----------------------------------------------
hostDev="$4";

# ------------------------------------------------
# Host domain/IP for SCP destination Development
# server
#
# @var string
# -----------------------------------------------
hostLocal="$5";

# ------------------------------------------------
# Remote filesystem path to application root
#
# @var string
# -------------------------------------------------
remotePath="$6"

# ------------------------------------------------
# List of files and directories that are elegible
# for deployment if updated recently
#
# @var string
# ------------------------------------------------
srcList="$7";


#  END:  user maintained config
# ================================================
# START: script initialised config


# ------------------------------------------------
# Destination host (after user parameters have
# been tested)
#
# @var string
# ------------------------------------------------
dest=$hosttDev

# ------------------------------------------------
# Human friendly name of server files will be
# uploaded to
# (after user parameters have been tested)
#
# @var string
# ------------------------------------------------
env='Dev'


if [ ! -z $1 ]
then    tmp=$(echo $1 |grep -i 'prod\(uction\)\?');
	if [ ! -z $tmp ]
	then    dest=$hostProd;
		env='Prod';
	else	tmp=$(echo $1 |grep -i 'local');
		if [ ! -z $tmp ]
		then    dest=$hostLocal;
			env='Local';
		fi
	fi
fi



# ------------------------------------------------
# Full SCP path (including username, host & file
# system path) used as SCP destination prefix
#
# @var string
# ------------------------------------------------
dest=$user'@'$dest$remotePath;

# ------------------------------------------------
# File name used to get the last deployment
# timestamp
#
# @var string
# ------------------------------------------------
timeCheckFile=$(pwd)'/lastDeployment-'$env;


# ------------------------------------------------
# Unix timestamp for when deployment was last done
# for selected environment
#
# @var integer
# ------------------------------------------------
lastDeployed=$(modTime $timeCheckFile);

# ------------------------------------------------
# Regex safe representation of the target server
#
# @var string
# ------------------------------------------------
sedDest=$(makeSedSafe $dest)

# ------------------------------------------------
# Regex safe representation path to current
# workding directory
#
# @var string
# ------------------------------------------------
pwd=$(makeSedSafe $(pwd))'\/'


# ------------------------------------------------
# File name for list of files to be deployed
#
# @var string
# ------------------------------------------------
updated=$(php -f deploy-getRecent.php "$srcList" $lastDeployed);



echo;
echo 'About push files up to '$env' ('$dest')'
echo;

if [ ! -z "$updated" ]
then    echo '$updated: '$updated;
	if [ -f "$updated" ]
	then	# Loop through all the files eligible for upload and
		# SCP them up to the appropriate server

		while	read line
		do	# echo '$pwd: '$pwd;

			# Remove path to current working directory
			# to make it easier to read which files are
			# being uploaded
			line=$(echo $line | sed 's/'$pwd'//ig')
			# echo $line;

			# Replace the keyword "[[HOST]]" with the the
			# destination host string
			line=$(echo $line | sed 's/\[\[HOST\]\]/'$sedDest'/')
			# echo $line;

			# Tell the user what's about to happen
			echo;
			echo '--------------------------------';
			echo "scp $line";
			echo;

			# run the actual SCP command for this group
			# of files
			scp $line;
			echo;
			echo '--------------------------------';
		done < $updated

		# Delete upload list now that it's no longer useful
		rm $updated;

		# Record when this deployment completed
		touch $timeCheckFile;
	fi
fi


