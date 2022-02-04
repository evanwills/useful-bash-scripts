# `deploy-to`

`deploy-to.sh` allows you to quickly and easily deploy recently 
updated files to a chosen environment.

# Configuration

You need a `deploy-to.json` file in the root directory of the 
application you wish to deploy to an environment.




# Deployment

```bash
$ /bin/sh /home/username/deploy-to.sh
```

## Globally executable
It is recommended that you set up a global command alias 
(e.g. `deployto`) in your `.bashrc` file to allow you to deploy 
from any directory with a `deploy-to.json` config file


## Authentication

`deploy-to` expects you have passwordless SSH Key authetication
set up for each environment. Otherwise you will have to enter you 
password many times, which is tedious.

## Arguments

The script expects up to two arguments.

If no arguments are supplied recently updated files are deployed
to the dev environment.

If the first argument is "force", all eligible files will be
uploaded to the dev environment regardless of when they were
updated.

If the first argument matches the name of one of the deployment
targets, the files will be uploaded to that server.

If the second argument is "force", all eligible files will be
uploaded to the environment specified by the first argument,
regardless of when they were updated.

This script depends on a PHP script (deploy-to.php) to do the
heavy lifting of working out which files out of all the eligible
files should be deployed. deploy-to.php generates a Bash script
which this script then executes.

NOTE: This file does not hold any of the required values for
      uploading. Instead it extracts config data from the
      deploy-to.json file in the current working directory

NOTE ALSO: If you wish to initialise a deployment script for an
      application, you can pass "new" as the first argument and
      a new deployt-to.json file will be created in the current
      working directoy.

FINAL NOTE: There are times when you want to deploy all eligible
      files regardless of when they were updated. You can do this
      by passing "force" as the only argument, or the second to
      this script

Author:  Evan Wills <evan.wills@acu.edu.au>
Created: 2021-09-23 15:08
Updated: 2021-10-13 23:31
