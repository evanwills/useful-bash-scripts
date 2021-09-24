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
# START: user maintained config

# ------------------------------------------------
# username to use to connect to remote server
#
# (Assumes SSH key authentication)
#
# @var string
# ------------------------------------------------
user='evwills';

# ------------------------------------------------
# Host domain/IP for SCP destination Production
# server
#
# @var string
# ------------------------------------------------
hosttProd='ethicsfinderdb.acu.edu.au';

# ------------------------------------------------
# Human fiendly name for Production server
#
# @var string
# ------------------------------------------------
envProd='prod';

# ------------------------------------------------
# Host domain/IP for SCP destination Development
# server
#
# @var string
# -----------------------------------------------
hostDev='fjnvduethics02.acu.edu.au';

# ------------------------------------------------
# Human fiendly name for Development server
#
# @var string
# -------------------------------------------------
envDev='dev';

# ------------------------------------------------
# Remote filesystem path to application root
#
# @var string
# -------------------------------------------------
remotePath=':/var/www/html/db/'

# ------------------------------------------------
# List of files and directories that are elegible
# for deployment if updated recently
#
# @var string
# ------------------------------------------------
srcList='server.php README.md webpack.mix.js .editorconfig composer* package*';
srcList=$srcList' app resources';
srcList=$srcList' public/css public/js';
# srcList=$srcList' publi';
srcList=$srcList' routes config';


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
env=$envDev


if [ ! -z $1 ]
then    tmp=$(echo $1 |grep 'prod\(uction\)\?');
	if [ ! -z $tmp ]
	then    dest=$hosttProd;
		env=$envProd;
	fi
fi


# ------------------------------------------------
# File name used to get the last deployment
# timestamp
#
# @var string
# ------------------------------------------------
timeCheckFile='lastDeployment-'$env;


# ------------------------------------------------
# Full SCP path (including username, host & file
# system path) used as SCP destination prefix
#
# @var string
# ------------------------------------------------
dest=$user'@'$dest$remotePath;

function modTime()
{
    modISO=$(stat "$1" | grep Modify | sed 's/^Modify: //')
    echo $(date -d"$modISO" '+%s');
}


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
sedDest=$(echo $dest | sed 's/\([./]\)/\\\1/g')

# ------------------------------------------------
# Regex safe representation path to current
# workding directory
#
# @var string
# ------------------------------------------------
pwd=$(echo $(pwd) | sed 's/\([./]\)/\\\1/g')'\/'


# ------------------------------------------------
# File name for list of files to be deployed
#
# @var string
# ------------------------------------------------
updated=$(php -f deploy-getRecentlyUpdatedFiles.php "$srcList" $lastDeployed);



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


