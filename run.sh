#!/bin/bash
#===============================================================================
#
#          FILE:  run.sh
# 
#         USAGE:  ./run.sh 
# 
#   DESCRIPTION:  Script to setup prerequisites on the desktop and run the
#		  Ansible playbooy
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Luis Cacho, luiscachog@gmail.com
#       VERSION:  0.1
#       CREATED:  2017/10/22 11:23 PM CDT
#     CHANGELOG:  Initial version of the script
#===============================================================================

#===============================================================================
#				USER VARIABLES
#===============================================================================	 			
SCRIPTVER="0.1"
# Set to 1 to enable debugging, printing of variables.
# Can be overridden in config file.
DEBUG=0

#===============================================================================
#				NO EDITS BELOW THIS LINE
#===============================================================================
GIT=/usr/bin/git
REPOURL=https://github.com/k4ch0/ansible-mint-desktop.git
REPODIR="/home/$(whoami)/repos/personal-stuff/"
REPONAME="ansible-mint-desktop"

#===============================================================================
#				FUNCTIONS
#===============================================================================


#=====  FUNCTION  ==============================================================
#          NAME: debug ( msg )
#   DESCRIPTION: Prints standard debug message to stderr
#		 Only print if debugging is enabled
#    PARAMETERS: msg
#       RETURNS:
#===============================================================================
function debug() {
  if [ "$DEBUG" -ne 1 ]
  then
    return
  fi
  echo "$(date +%T) " "$@" > /dev/stderr
}
# ----------  end of function debug  ----------

#=====  FUNCTION  ==============================================================
#          NAME: usage
#   DESCRIPTION: Print a basic usage statement for user to understand program use
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function usage() {
	cat << eof
Usage:
	$SCRIPTVER
	$0
	$(basename "${0}")
eof
}
# ----------  end of function usage  ----------

#=====  FUNCTION  ==============================================================
#          NAME: fail ( failcode, msg )
#   DESCRIPTION: Gracefully exit from program in failure state
#    PARAMETERS: failcode, msg
#       RETURNS:
#===============================================================================
function fail() {
	if [ -n "$2" ]
	then
		echo "$2" > /dev/stderr
	fi
	exit "${1:-1}"

}
# ----------  end of function fail  ----------

#=====  FUNCTION  ==============================================================
#          NAME: succeed
#   DESCRIPTION: Gracefully exit from program successfully
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function succeed() {
	cleanup
	exit 0

}
# ----------  end of function succeed  ----------

#=====  FUNCTION  ==============================================================
#          NAME: cleanup
#   DESCRIPTION: Clean up log/lock files etc
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function cleanup() {
	return
}
# ----------  end of function cleanup  ----------

#=====  FUNCTION  ==============================================================
#          NAME: install_os_deps
#   DESCRIPTION: Install OS dependencies using aptitude
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function install_os_deps() {
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get -qq update
	sudo aptitude -qq install libssl-dev libffi-dev python-dev python-setuptools python-jinja2  python-yaml python-paramiko python-crypto git ansible -y
	debug "install_osdeps= $?"
	return $?
}
# ----------  end of function install_osdeps  ----------

#=====  FUNCTION  ==============================================================
#          NAME: install_ansible_galaxy_packages
#   DESCRIPTION: Install ansible galacy packages
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function install_ansible_galaxy_packages() {
	sudo ansible-galaxy install alzadude.firefox-addon
	debug "install_ansible_galaxy_packages= $?"
	return $?
}
# ----------  end of function install_ansible_galaxy_packages  ----------

#=====  FUNCTION  ==============================================================
#          NAME: clone_repo
#   DESCRIPTION: Clone GIT repository
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function clone_repo() {
	mkdir -p "$REPODIR"
	cd "$REPODIR"
	#$GIT clone "$REPO $REPONAME"
	return $?
}
# ----------  end of function clone_repo  ----------

#
# validateIP(IP)
#  - Validate an IP
#
function validateIP() {
	local ip=$1
	local stat=1
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}
# ----------  end of function validateIP  ----------

#=====  FUNCTION  ==============================================================
#          NAME: install_keys
#   DESCRIPTION: Install ssh keys on desktop
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function install_keys() {
	local stat=1
	echo -n "Enter server IP to install SSH keys: "
	read SERVERIP
	if validateIP "$SERVERIP"
	then
		echo "$SERVERIP is a Perfect IP Address"
		#ssh-copy-id -f -i "$REPODIR/$REPONAME/resources/ansible_rsa.pub luis7238@$SERVERIP"
		stat=$?
	else
		fail 11 "Invalid IP Address ($SERVERIP)"
	fi

	return $stat
}
# ----------  end of function install_keys  ----------

#=====  FUNCTION  ==============================================================
#          NAME: run_ansible_playbook
#   DESCRIPTION: Run the downloaded Ansible Playbook
#    PARAMETERS:
#       RETURNS:
#===============================================================================
function run_ansible_playbook() {
	cd "$REPODIR/$REPONAME"
	ansible-playbook desktop.yml -K --flush-cache 
	return $?
}
# ----------  end of function run_ansible_playbook  ----------

########################		 			
####	MAIN CODE 	####
########################		 			

run_ansible_playbook
# if install_osdeps 
# then
#	if install_ansible_galaxy_packages
#	then
# 		if install_pydeps
#	 	then
# 			if install_pipdeps
# 			then
# 				if clone_repo
#	 			then
# 					if install_keys
# 					then
# 						if run_playbook
# 						then
# 							succeed
#	 					else 
# 							fail 10 "ERROR: Can't run Ansible Playbook"
# 						fi
# 					else
# 						fail 9 "ERROR: Can't install ssh keys"
#	 				fi
# 				else
# 					fail 8 "ERROR: Can't clone $REPO "
# 				fi
#	 		else
# 				fail 7 "ERROR: Can't install PIP dependencies"
# 			fi
#	 	else
# 			fail 6 "ERROR: Can't install Python dependencies"
# 		fi
#	else
#		fail 5 "ERROR: Can't install Ansible Galaxy Packages"
#	fi
# else
# 	fail 6 "ERROR: Can't install OS dependencies"
# fi

