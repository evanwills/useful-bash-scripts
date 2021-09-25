#!/bin/sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This file is used to upload recently updated files to a given
# server based a runtime argument
#
# If "prod" or "production" is supplied as the first argument, the
# target environment will be the production server. Otherwise target
# server will the the Development server
#
# It depends on shared script (also called deployTo.sh) to do all
# the actual work selecting which files should be uploaded and then
# uploading them to the appropriate server.
#
# See `$deployScriptPath` below for the location of the main script
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
user='';

# ------------------------------------------------
# Host domain/IP for SCP destination Production
# server
#
# @var string
# ------------------------------------------------
prodHost='';

# ------------------------------------------------
# Host domain/IP for SCP destination Development
# server
#
# @var string
# -----------------------------------------------
devHost='';

# ------------------------------------------------
# Host domain/IP for SCP for your local development
# environment
#
# @var string
# -----------------------------------------------
localHost='localServer';

# ------------------------------------------------
# Remote filesystem path to application root
#
# @var string
# -------------------------------------------------
remotePath='';

# ------------------------------------------------
# List of files and directories that are elegible
# for deployment if updated recently
#
# @var string
# ------------------------------------------------
srcList='';


# ------------------------------------------------
# Local file system path to where the main
# deployTo script is stored
#
# @var string
# ------------------------------------------------
deployScriptPath='[[PATH]]/deployTo-main.sh';


#  END:  user maintained config
# ================================================
# START: Call the script that does all the work

/bin/sh $deployScriptPath "$1" "$user" "$prodHost" "$devHost" "$localHost" "$remotePath" "$srcList";

#  END:  Call the script that does all the work
# ================================================
