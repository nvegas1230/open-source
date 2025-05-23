#!/bin/bash

#Check for arguments, if less than 2, exit and inform user
#Needs password and user to change
if [[ $# -lt 2 ]]; then
    #$0 provides the script name
    echo "You need to supply arguements in the form of: $0 <username> <new password>"
    exit 1
fi

#Define variables
baseDn="dc=zoo,dc=local"
adminDn="cn=admin,$baseDn"
tempFile="reset_password.ldif"
username=$1
newPass=$(sudo slappasswd -s $2)
userDn="uid=$username,dc=zoo,dc=local"

#Get ldap password from user
read -s -p "Please input your ldap password: " ldapPassword
echo

#Make temp file for changing a password
touch $tempFile

#Make file contents for modification
fileContents=$(cat <<EOF
dn: $userDn
changetype: modify
replace: userPassword
userPassword: $newPass
EOF
)

#Write to file
echo -e "$fileContents" > "$tempFile"

#Apply the file
sudo ldapmodify -x -D $adminDn -w $ldapPassword -f $tempFile

#Remove the file that modifys passwords
rm $tempFile