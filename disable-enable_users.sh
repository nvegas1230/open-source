#!/bin/bash

#THIS SCRIPT REQUIRES THE USERS IN YOUR LDAP SYSTEM TO HAVE OBJECTCLASS SHADOWACCOUNT
#Check for arguments, if less than 2, exit and inform user
#Needs password and user to change
if [[ $# -lt 2 ]]; then
    #$0 provides the script name
    echo "You need to supply arguements in the form of: $0 <username> <enable | disable>"
    exit 1
fi

#Define variables
baseDn="dc=zoo,dc=local"
adminDn="cn=admin,$baseDn"
tempFile="enable-disable_users.ldif"
username=$1
userDn="uid=$username,$baseDn"

#Get ldap password from user
read -s -p "Please input your ldap password: " ldapPassword
echo

#Make file contents for modification
#Changing a login shell to /usr/sbin/nologin SHOULD prevent the user from logging in
#Above doesnt work, using shadowExpire cuz i actually tested it
if [[ $2 == "enable" ]]; then
fileContents=$(cat <<EOF
dn: $userDn
changetype: modify
delete: shadowExpire
EOF
)
else
fileContents=$(cat <<EOF
dn: $userDn
changetype: modify
add: shadowExpire
shadowExpire: 0
EOF
)
fi

#Make temp file for changing a password
touch $tempFile

#Write to file
echo -e "$fileContents" > "$tempFile"

#Apply the file
sudo ldapmodify -x -D $adminDn -w $ldapPassword -f $tempFile

#Remove the file that modifys passwords
rm $tempFile
