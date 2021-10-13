#!/bin/sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This file is used to upload recently updated files to a given
# server based a data in the working directory's deploy-to.json
#
# The script expects up to two arguments.
#
# If no arguments are supplied recently updated files are deployed
# to the dev environment.
#
# If the first argument is "force", all eligible files will be
# uploaded to the dev environment regardless of when they were
# updated.
#
# If the first argument matches the name of one of the deployment
# targets, the files will be uploaded to that server.
#
# If the second argument is "force", all eligible files will be
# uploaded to the environment specified by the first argument,
# regardless of when they were updated.
#
# This script depends on a PHP script (deploy-to.php) to do the
# heavy lifting of working out which files out of all the eligible
# files should be deployed. deploy-to.php generates a Bash script
# which this script then executes.
#
# NOTE: This file does not hold any of the required values for
#       uploading. Instead it extracts config data from the
#       deploy-to.json file in the current working directory
#
# NOTE ALSO: If you wish to initialise a deployment script for an
#       application, you can pass "new" as the first argument and
#       a new deployt-to.json file will be created in the current
#       working directoy.
#
# FINAL NOTE: There are times when you want to deploy all eligible
#       files regardless of when they were updated. You can do this
#       by passing "force" as the only argument, or the second to
#       this script
#
# Author:  Evan Wills <evan.wills@acu.edu.au>
# Created: 2021-09-23 15:08
# Updated: 2021-10-13 23:31
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# ------------------------------------------------
# Name of the deployment target
#
# @var string
# ------------------------------------------------
env='dev';

# ------------------------------------------------
# Whether or not to force uploading all files,
# regardless of when they were updated
#
# @var string
# ------------------------------------------------
force="$2";

if [ ! -z "$1" ]
then	if [ $1 != 'force' ]
	then	env="$1";
	else	force='force';
	fi
fi


# ------------------------------------------------
# File system path to this script
#
# @var string
# ------------------------------------------------
thisDir=$(realpath "$0" | sed "s/[^/']\+$//");


# ------------------------------------------------
# File name of
#
# @var string
# ------------------------------------------------
scriptName='deployList__'$(date +'%Y-%m-%d--%H-%M-%S')'.sh';

# ==========================================================
# START: Doin' tha do

if [ $env == 'new' ]
then	file='deploy-to.json';
	if [ ! -f "$(pwd)/deploy-to.json" ]
	then	cp $thisDir$file $(pwd)'/';
		exit;
	fi;
fi


# echo "php -f $thisDir""deploy-to.php "'"'$env'"'" "'"'$scriptName'"'" $force;";

# ------------------------------------------------
# Generate the shell script with SCP commands for
# each group of files to be uploded

php -f $thisDir'deploy-to.php' "$env" "$scriptName" $force;

scriptName="$(pwd)/$scriptName";

# ------------------------------------------------

if [ -f "$scriptName" ]
then	# Make sure the new script is executable
	chmod u+x $scriptName;

	# Execute custom shell script that was created by PHP
	/bin/sh $scriptName;
	# echo; echo;
	# tail -n 80 $scriptName;

	# Delete upload custom shell script now that it's no
	# longer useful
	rm $scriptName;
else	echo;
	echo;
	echo 'No files were eligible for uploading';
	echo;
	echo;
fi


#  END:  Doin' tha do
# ==========================================================