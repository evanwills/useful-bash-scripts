#!/bin/sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This file is used to upload recently updated files to a given
# server based a runtime argument
#
# If "prod" or "production" is supplied as the first argument, the
# target environment will be the production server.
# If "local" is passed as the first argument, the target environment
# will the the local VM server.
# Otherwise target server will the the Development server
#
# This script depends on a PHP script (deploy-getRecent.php) to do
# the heavy lifting of working out which files out of all the
# eligible files should be deployed.
#
# NOTE: This file does not hold any of the required values for
#       uploading. Instead it requires all values to be passed as
#       arguments to this script
#
# NOTE ALSO: If you wish to initialise a deployment script for an
#       application, you can pass "new" as the first argument and
#       a  new deploytTo.sh script will be created in the current
#       working directoy.
#
# FINAL NOTE: There are times when you want to deploy all eligible
#       files regardless of when they were updated. You can do this
#       by passing "all" as the second argument to deployTo.sh
#       script in your current working directory
#
# Author:  Evan Wills <evan.wills@acu.edu.au>
# Created: 2021-09-23 15:08
# Updated: 2021-09-25 16:00
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



# ==========================================================
# START: Function declarations


# ------------------------------------------------
# Get the Unix timestamp for the modification time
# of the supplied file
#
# @param string $1 File system path to a file
#
# @return integer
# ------------------------------------------------
function modTime()
{
	if [ -f "$1" ]
	then	modISO=$(stat "$1" | grep Modify | sed 's/^Modify: //')
    		echo $(date -d"$modISO" '+%s');
	else	echo 0;
	fi
}

# ------------------------------------------------
# Make a string safe to use in a Sed Regular
# expression
#
# @param string $1 String to sanitised for a Sed
#                  regular expression
#
# @return string
# ------------------------------------------------
function sedSafe()
{
	echo $(echo $1 | sed 's/\([./]\)/\\\1/g')
}

# ------------------------------------------------
# Report how many groups of files will be uploaded
#
# @param string $1 File containing a list of files
#                  to be deployed
#
# @return void
# ------------------------------------------------
function reportOnUpload()
{
	c=$(grep -c "\n" $1)
	s=''

	if [ $c -gt 1 ]
	then	s='s'
	fi

	echo;
	echo "We have $c group$s of files to be uploaded";
	echo;
}


#  END:  Function declarations
# ==========================================================
# START: Validate arguments


# ------------------------------------------------
# File system path to this script
#
# @var string
# ------------------------------------------------
thisDir=$(realpath "$0" | sed "s/[^/']\+$//");


if [ -z "$1" ]
then	echo 'You must specify which environment you want to deploy to';
	exit;
else	if [ "$1" == 'new' ]
	then	if [ $(pwd) != $thisDir ]
		then	conf=$(pwd)'/deployTo.sh';
			cp $thisDir'/deployTo.tmpl.sh' $conf;
			sed -i 's/\[\[PATH\]\]/'$(sedSafe $thisDir)'/i';
		fi
		exit;
	fi

	if [ -z "$2" ]
	then	echo 'You must specify a username with which to connect to the remote server';
		exit;
	else	if [ -z "$3" ]
		then	echo 'You must specify domain for the production server';
			exit;
		else	if [ -z "$4" ]
			then	echo 'You must specify domain for the devleopment server';
				exit;
			else	if [ -z "$5" ]
				then	echo 'You must specify domain for the local VM server';
					exit;
				else	if [ -z "$6" ]
					then	echo 'You must specify the file system path to the application root';
						exit
					else	if [ -z "$7" ]
						then	echo 'You must specify a list of files and/or directorys eligible for deployment';
						else 	all=0;
							if [ ! -z "$8" ]
							then	tmp=$(echo "$8" | grep -i 'all');
								if [ ! -z $tmp ]
								then	all=1;
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	fi
fi

#  END:  Validate arguments
# ==========================================================
# START: user supplied config

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
# ==========================================================
# START: script initialised config


# ------------------------------------------------
# Destination host (after user parameters have
# been tested)
#
# @var string
# ------------------------------------------------
dest=$hostDev

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
dest=$user'@'$dest':'$remotePath;

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
lastDeployed=0

if [ $all -ne 1 ]
then	# Only upload recently updated files
	lastDeployed=$(modTime $timeCheckFile);

	# if [ $lastDeployed -eq 0 ]
	# then
	# fi
fi


#  END:  script initialised config
# ==========================================================
# START: Doin' tha do

# echo "php -f $thisDir""deployTo-getRecent.php '$srcList' $lastDeployed";

# ------------------------------------------------
# Custom shell script with SCP commands for each
# group of files to be uploded
#
# @var string
# ------------------------------------------------
updated=$(php -f $thisDir'/deployTo-getRecent.php' "$srcList" $lastDeployed $dest);



if [ ! -z "$updated" ]
then    updated=$(pwd)'/'$updated;
	if [ -f "$updated" ]
	then	# Execute custom shell script that was created by PHP
		/bin/sh $updated;

		# Delete upload custom shell script now that it's no
		# longer useful
		rm $updated;

		# Record when this deployment completed
		touch $timeCheckFile;
	fi
else	echo;
	echo;
	echo 'No files were eligible for uploading';
	echo;
	echo;
fi


#  END:  Doin' tha do
# ==========================================================
