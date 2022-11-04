#!/bin/bash


sshDir=$HOME'/.ssh/';
# sshDir='/home/evan/.ssh/';
sshConf=$sshDir'config';
thisDir=$(realpath "$0" | sed "s/[^/']\+$//");

userName=$(echo "$1" | sed 's/[ \t]\+//g');
host=$(echo "$2" | sed 's/[ \t]\+//g');
email=$(echo "$3" | sed 's/[ \t]\+//g');
keyName=$(echo "$4" | sed 's/[ \t]\+//g');
keyType=$(echo "$5" | sed 's/[ \t]\+//g');
bitLen=$(echo "$6" | sed 's/[ \t]\+//g');

_must='You must specify'
_param=' parameter for newKey.sh'
_eg='  $ /bin/sh '$thisDir'newKey.sh [username] [host] [email address] ?[key name] ?[key type] ?[RSA bit length]';

echo;
echo 'Create a new SSH key for a remote server';
echo;
echo $_eg;
echo;
echo 'NOTE: Key types can be either "ed25519" or "RSA" or "ecdsa"'

if [ -z "$userName" ]
then	echo "$_must username as the first $_param";
	echo;
	echo $_eg;
	echo;
	echo 'Please enter your username for the server this SSH key will';
	echo 'be used on:';
	echo;
	echo 'e.g. "joblogs"';
	echo;
	read userName;

	if [ ! -z "$userName" ]
	then	userName=$(echo $userName | sed 's/[ \t]\+//g');
	fi

	if [ -z "$userName" ]
	then	echo;
		echo 'You have not specified a username so I am going to end here';
		echo

		# !--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
		exit;
	fi
fi

if [ -z "$host" ]
then	echo "$_must host or server IP as the second $_param";
	echo;
	echo $_eg;
	echo;
	echo 'Please enter your host or IP address for the server this SSH';
	echo 'key will be used on:';
	echo 'e.g. "my.server.com.au" or "10.11.12.13"';
	echo;
	read host;

	if [ ! -z "$host" ]
	then	host=$(echo $host | sed 's/[ \t]\+//g');
	fi

	if [ -z "$host" ]
	then	echo;
		echo 'You have not specified a server host or IP so I am going to'
		echo ' end here';
		echo

		# !--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
		exit;
	fi
fi

if [ -z "$email" ]
then	echo "$_must an email address as the third $_param";
	echo;
	echo $_eg;
	echo;
	echo 'Please enter your email address this SSH key:';
	echo 'e.g. "jo.blogs@example.com"';
	echo;
	read email;

	if [ ! -z "$email" ]
	then	email=$(echo $email | sed 's/[ \t]\+//g');
	fi

	if [ -z "$email" ]
	then	echo;
		echo 'You have not specified an email address so I am going to'
		echo 'end here';
		echo

		# !--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
		exit;
	fi
fi

if [ -z "$keyName" ]
then	n1=$(echo $host | sed 's/^\([^.]\+\).*$/\1/');
	n2=$(echo $host | sed 's/^\([^.]\+\)\.\([^.]\+\).*$/\1-\2/');
	n3=$(echo $host | sed 's/\./-/g');
	n4='ID_ed25519'
	echo 'No key name was specified.';
	echo;
	echo 'The default options are:';
	echo '  1 - '$n1;
	echo '  2 - '$n2;
	echo '  3 - '$n3;
	echo '  4 - '$n4' (default if nothing is entered)';
	echo;
	echo 'enter the number matching the key name you prefer:'
	echo 'Otherwise just press enter.'
	read keyName;
	keyName=$(echo "$keyName" | sed 's/[ \t]\+//g');

	case $keyName in
		'1')	keyName=$n1;
			;;
		'2')	keyName=$n2;
			;;
		'3')	keyName=$n3;
			;;
		'4')	keyName=$n4;
			;;
	esac

	echo;
fi

if [ -z "$bitLen" ]
then	_bitLen=0;
else	_bitLen=$(echo $bitLen | sed 's/[^0-9]+//g')
	_bitLen=$((_bitLen * 1));
fi

if [ -z "$keyType" ]
then	keyType='ed25519';
else	_keyTYpe=$(echo $keyType | sed 's/^\([^ ]\+\).*$/\1/i');

	if [ "$_keyTYpe" == "ecdsa" ]
	then	keyType=$_keyType;
	else	if [ "$_keyTYpe" == "rsa" ]
		then	if [ $_bitLen -eq 0 ]
			then	$_bitLen = 4096;
			else	if [ $_bitLen -lt 2048 ]
				then	_bitLen=2048;
				fi
			fi

			keyType='rsa -b '$_bitLen;
		else	keyType='ed25519';
		fi
	fi
fi

if [ -z "$keyName" ]
then	keyName='ID_'$keyType
	echo 'Using default key name: "'$keyName'"';
fi

if [ -f "$sshDir$keyName" ]
then	echo;
	echo '*** WARNING! ***';
	echo;
	echo 'There is already an SSH key with the name "'$keyName'",';
	echo 'If you wish to over write it, enter either:';
	echo '    type "new" to enter a new key name';
	echo '  or';
	echo '    type "OVERWRITE" (in all caps) to overwrite the existing key';
	echo '  or';
	echo '    just press Enter to exit without creating a new SSH key'

	read _keyAction;

	if [ $_keyAction == 'new' ]
	then	a=0;
		while [ -f "$sshDir$keyName" ]
		do	echo;
			if [ $a -gt 4 ]
			then	echo 'It looks like you are having trouble finding a good key name.'
				echo 'I think you should try again later.'
				echo;
				echo $_eg;
				echo;

				# !--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
				exit;
			fi

			echo 'Please enter a new key name:';

			read keyName;
			a=$((a+1));
		done
	else	if [ $_keyAction == 'OVERWRITE' ]
		then	echo 'The existing key will be overwritten.';
		else	echo 'Ending here.';
			echo 'No key was created';

			# !--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!--!
			exit;
		fi
	fi
fi


remoteUser="$userName@$host";

if [ $keyType == 'rsa' ]
then	_sep='   ';
else	_sep='';
fi

echo;
echo 'Host:        '$_sep$host;
echo 'User name:   '$_sep$userName;
echo 'Email:       '$_sep$email;
echo 'Key name:    '$_sep$keyName;
echo 'Key type:    '$_sep$keyType;
if [ $keyType == 'rsa' ]
then
echo 'Key bit length: '$_bitLen;
fi
echo 'Remote user: '$_sep$remoteUser;
echo;

# ===================================================================
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
# Add key to ssh config file

echo >> $sshConf;
echo 'Host '$host >> $sshConf;
echo '	HostName	'$host >> $sshConf;
echo '	User		'$userName >> $sshConf;
echo '	AddKeysToAgent	yes' >> $sshConf;
echo '	IdentityFile	~/.ssh/'$keyName >> $sshConf;
echo >> $sshConf;

echo;
echo '========================================';
echo;

echo;
echo 'Look at the end of ssh config';
echo;
echo 'tail -n 7 '$sshConf;
echo '----------------------------------------';
tail -n 7 $sshConf

echo;
echo '========================================';
echo;

echo;
echo 'Test whether everything worked';
echo;

echo 'ssh '$remoteUser;
echo '----------------------------------------';
ssh $remoteUser;
