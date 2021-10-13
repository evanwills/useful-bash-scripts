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


env='dev';

if [ ! -z "$1" ]
then	env="$1";
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


# echo "php -f $thisDir""deploy-to.php "'"'$env'"'" "'"'$scriptName'"'" $2;";

# ------------------------------------------------
# Custom shell script with SCP commands for each
# group of files to be uploded
#
# @var string
# ------------------------------------------------
php -f $thisDir'deploy-to.php' "$env" "$scriptName" $2;


if [ -f "$scriptName" ]
then	# Make sure the new script is executable
	chmod u+x $scriptName;

	# Execute custom shell script that was created by PHP
	# /bin/sh $scriptName;
	echo; echo;
	tail -n 80 $scriptName;

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