#!/bin/bash

#Define variables
ldap_base="dc=zoo,dc=local"
ldap_bind_dn="cn=admin,dc=zoo,dc=local"

#Get ldap admin pass for commands
read -p "Input ldap password: " -s ldap_password

#Get all dns excluding base and admin (this is chatgpted)
ldapsearch -x -D "$ldap_bind_dn" -w "$ldap_password" -b "$ldap_base" -LLL dn | \
  grep "^dn:" | \
  awk '{print $2}' | \
  grep -v -E "^$ldap_base$" | \
  grep -v -E "^$ldap_bind_dn$" | \
  awk '{ print length($0), $0 }' | sort -rn | cut -d' ' -f2- > entries_to_delete.ldif
rm -f delete.ldif

while read -r dn; do
  echo "dn: $dn" >> delete.ldif
  echo "changetype: delete" >> delete.ldif
  echo "" >> delete.ldif
done < entries_to_delete.ldif

if [ -s delete.ldif ]; then
  echo "Deleting entries..."
  ldapmodify -x -D "$ldap_bind_dn" -w "$ldap_password" -f delete.ldif
  echo "Cleanup complete."
else
  echo "No entries to delete."
fi

#Remove file after finished
rm -f entries_to_delete.ldif delete.ldif