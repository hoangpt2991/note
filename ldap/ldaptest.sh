#!/bin/sh
#https://stackoverflow.com/questions/16247552/easy-way-to-test-an-ldap-users-credentials
#input
#LDAP info
#search base
#user name
#password - encrypted?
#verify/search/list/add/delete ldap user 	
	
function usage(){
  echo "This script is used to verify/search/list/add/delete ldap user"
  echo "Usage: ldaptest [OPTIONS] [COMMAND] [COMMAND_INPUT]"
  echo ""
  echo "These are commands used in various situations:"
  echo "Search a User:"
  echo -e "\tsearch <username>"
  echo "List all Users:"
  echo -e "\tlist <output> \t\t\t\t\tPrint user list to file"
  echo -e "\tsearch \t\t\t\t\t\tProvide no param to print out all users"
  echo ""  
  echo "Verify login of a User:"
  echo -e "\tverify <username> <password> \t\t\tCheck login, print output to console"
  echo -e "\tbulkverify <filename> <output> \t\t\tCheck login, print output to filename"
  echo -e "\t\t\t\t\t\t\tInput file in type of <username> <password> on each line, separated by a white space"
  echo ""
  echo "Add a User:"
  echo -e "\tadd <username> \t\t\t\t\tWill prompt for password"
  echo -e "\tadd <username> <password>"
  echo "Delete a User:"
  echo -e "\tdelete <username1> <username2> <...> [-q] \tAdd -q flag to suppress confirmation"
  echo ""
  echo "options:"
  echo "  -h, --help                Print this message"
  echo "  -v, --verbose             Display verbose output"
}

function abort {
    echo "$(tput setaf 1)$1$(tput sgr0)"
    exit 1
}

function request_confirmation {
    read -p "$(tput setaf 4)$1 (y/n) $(tput sgr0)"
    [ "$REPLY" == "y" ] || abort "Aborted!"
}

function warn() {
  cat << EOF
    This script will need 1 config file (ldaptest.properties) placed at the same folder

    This file contains:
		* LDAP info
		* Search base
		* Bind account
		* Password
		* Encryption flag

EOF

  request_confirmation "Is this file available? "
}

function main() {

  warn

  if [ "${verbose}" == "true" ]; then
    set -x
  fi
  . ./ldaptest.properties
	declare -a newarg
	while shift
	do
		newarg+=("${1:-}")
	done
  case "$command" in
	(search) 
		search ${newarg[0]}
		;;
	(list)
		list ${newarg[@]}
		;;
	(verify)
		verify ${newarg[@]}
		;;
	(bulkverify)
		bulkverify ${newarg[@]}
		;;
	(add)
		add ${newarg[@]}
		;;
	(delete)
		delete ${newarg[@]}
		;;
	(*)
		>&2 echo "Error: Unknown command: ${command:-}"
		tput setaf 3
		usage
		exit 1
		;;
  esac
}

function search() {
	username="${1:-}"
	[ -z "${username}" ] && echo -e "INFO: No Username specified\n\nPrinting all users..." || username=cn\=$username
	#Ex: ldapsearch -xLLLH ldap://127.0.0.1:389 -D "cn=Manager,dc=example,dc=com" -W -b "ou=user,dc=dolphin,dc=com" "cn=underwr1" dn
	result=$(ldapsearch -xLLLH ldap://$hostname:$port \
	-D $bindUser -w $password \
	-b $basedn $username dn | sed -e "s|dn: cn=||" -e "s|,.*||")
	[ -z "${result}" ] && result='NOT FOUND!!'
	echo $result
}

function list() {
	filename="${1:-}"
	[[ -z "${filename}" ]] && >&2 echo "Error: list command needs Output file name" && exit 1
	search > $filename
}

function verify() {
	username="${1:-}"
	password="${2:-}"
	[ -z "${username}" ] || [ -z "${password}" ] && >&2 echo -e "Error: Please provide username and password!" && read -s password
	username=cn\=$username,$basedn
	# verify ldapsearch -xLLLH ldap://127.0.0.1:389 -D "cn=Manager,dc=example,dc=com" -W -b "ou=user,dc=dolphin,dc=com" "cn=underwr1" userPassword | grep -o userP.* | sed -e 's|.* ||' | base64 -d
	ldapwhoami -vvv -h $hostname -p $port -D $username -x -w $password
}

function bulkverify() {
	filename="${1:-}"
	output="${2:-}"
	[ -z "${filename}" ] && >&2 echo -e "Error: Please provide filename list of user to verify!" && exit 1
	[ -z "${output}" ] && echo "INFO: No output filename provided, printing to console..."
	while IFS='' read -r line || [[ -n "$line" ]]; do
	read username password <<< $line
	if [ -z "${output}" ]; then
		echo Verifying user $username
		verify $username $password
	else
		echo Verifying user $username >> $output
		verify $username $password >> $output
	fi
	done < $filename
	echo 'BULK VERIFY COMPLETED!!'
}

function add() {
	username="${1:-}"
	unencpassword="${2:-}"
	[ -z "${username}" ] && >&2 echo -e "Error: Please provide username!" && exit 1
	[ -z "${unencpassword}" ] && echo "INFO: No password provided, INPUT PASSWORD: " && read -s unencpassword
	echo -e $addtemplate > $username.ldif
	sed -e "s|username|$username|g" -e "s|unencpassword|$unencpassword|" -i $username.ldif
	ldapadd -h $hostname -p $port -D $bindUser -w $password -f $username.ldif
	rm $username.ldif
}

function delete() {
	username="${1:-}"
	[ -z "${username}" ] && >&2 echo -e "Error: Please provide username to delete!" && exit 1
	while :
	do
		echo -e $deltemplate > del_$username.ldif
		sed -i "s|username|$username|" del_$username.ldif
		ldapmodify -h $hostname -p $port -D $bindUser -w $password -f del_$username.ldif
		rm del_$username.ldif
		shift
		username="${1:-}"
		[ -z "${username}" ]  && exit 0	
	done
}

set -euo pipefail

declare verbose=false
while [ $# -gt 0 ]; do
    case "$1" in
        (-h|--help)
            usage
            exit 0
            ;;
        (-v|--verbose)
            verbose=true
            ;;
        (*)
            break
            ;;
    esac
    shift
done

declare command="${1:-}"

if [ -z "${command}" ]; then
  >&2 echo -e "Error: No Operation specified\n\n"
  tput setaf 3
  usage
  exit 1
fi

declare -a newarg=dummy
while shift
do
	newarg+=("${1:-}")
done

main ${newarg[@]}
