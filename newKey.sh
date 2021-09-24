#!/bin/bash

echo;
echo 'Create a new SSH key for a remote server';
echo '$ ./newKey.sh [username] [host] [key name] ?[key type] ?[email address]';
echo;
echo 'NOTE: Key types can be either "RSA" or "ed25519" or "ecdsa"'

sshDir='/c/Users/[username]/.ssh/';
# sshDir='/home/[username]/.ssh/';
sshConf=$sshDir'config';

userName="$1";
host="$2";
keyName="$3";
keyType="$4";
email="$5";

if [ -z "$userName" ]
then	echo 'You must specify username as the first parameter for newKey.sh'
		echo 'e.g.';
		echo '$ ./newKey.sh [username] [host] [key name] ?[key type] ?[email address]';
		echo;
		exit;
fi

if [ -z "$host" ]
then	echo 'You must specify the host as the second parameter for newKey.sh'
		echo 'e.g.';
		echo '$ ./newKey.sh [username] [host] [key name] ?[key type] ?[email address]';
		echo;
		exit;
fi

if [ -z "$keyName" ]
then	echo 'You must specify keyName as the third parameter for newKey.sh'
		echo 'e.g.';
		echo '$ ./newKey.sh [username] [host] [key name] ?[key type] ?[email address]';
		echo;
		exit;
fi

if [ -z "$keyType" ]
then	keyType='rsa -b 4096';
else	if [ "$keyType" != "ed25519" ]
	then	if [ "$keyType" != "ecdsa" ]
		then keyType='rsa -b 4096';
		fi
	fi
fi

if [ -z "$email" ]
then	email='evan.wills@acu.edu.au';
fi

remoteUser=$userName"@"$host;

echo;
echo '$userName:  '$userName;
echo '$host:      '$host;
echo '$keyName:   '$keyName;
echo 'remoteUser: '$remoteUser;
echo;

# doing tha do

echo;
echo 'Generate the SSH key "'$keyName'" for '$email' at '$remoteUser;
echo;

echo 'ssh-keygen -t '$keyType' -C "'$email'" -f '$sshDir$keyName;

ssh-keygen -t $keyType -C $email -f $sshDir$keyName;

echo;
echo 'Upload '$keyName'.pub to '$host' for '$userName;
echo;
echo 'ssh-copy-id -i $sshDir/.ssh/'$keyName'.pub '$remoteUser;

ssh-copy-id -i $sshDir$keyName.pub $remoteUser;

echo;
echo 'Add key ('$keyName') for '$remoteUser' to SSH config.';
echo;


echo '----------------------------------------';
echo;
echo >> $sshConf;
echo 'Host '$host
echo 'Host '$host >> $sshConf;
echo '	HostName	'$host
echo '	HostName	'$host >> $sshConf;
echo '	User		'$userName
echo '	User		'$userName >> $sshConf;
echo '	AddKeysToAgent	yes'
echo '	AddKeysToAgent	yes' >> $sshConf;
echo '	IdentityFile	~/.ssh/'$keyName
echo '	IdentityFile	~/.ssh/'$keyName >> $sshConf;
echo
echo >> $sshConf;

echo;
echo '========================================';
echo;

echo;
echo 'Look at the end of ssh config';
echo;
echo 'tail '$sshConf;
echo '----------------------------------------';
tail $sshConf

echo;
echo '========================================';
echo;

echo;
echo 'Test whether everything worked';
echo;

echo 'ssh '$remoteUser;
echo '----------------------------------------';
ssh $remoteUser;
