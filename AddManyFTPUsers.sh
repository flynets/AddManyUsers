#!/bin/bash

#******************************************************************************#
# AddManyFTPUsers.sh Create many users in a GNU/Linux system using a text file #
#                   as argument (One user per line)			                   #
#									  									       # 
#  Copyright (C) 2015 written by Flynets <flynets@gmail.com>                   # 
#  AddManyFTPUsers  is free software: you can redistribute it and/or modify    # 
#  it under the terms of the GNU General Public License as published by        # 
#  the Free Software Foundation, either version 3 of the License, or           # 
#  any later version.						                                   # 
#      								               							   # 
#  AddManyFTPUsers is distributed in the hope that it will be useful,          # 
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              # 
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the	               # 
#  GNU General Public License for more details.			               		   # 
#						         								               # 
#  You should have received a copy of the GNU General Public License           #
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.       #
#******************************************************************************#

# CHANGE THIS PARAMETERS FOR A PARTICULAR USE
PERS_HOME="/home"
PERS_SH="/sbin/nologin"
NOW=$(date +"%Y%m%d")
LOGFILE="AddManyUsers_$NOW.log"
GROUP="sftp_users"

# Checks if you have the right privileges
if [ "$USER" = "root" ]; then

   # Checks if there is an argument
   [ $# -eq 0 ] && { echo >&2 ERROR: You may enter as an argument a text file containing users, one per line.; exit 1;}

   # checks if there a regular file
   [ -f $1 ] || { echo >&2 ERROR: The input file does not exists.; exit 1;}
   TMPIN=$(mktemp)
   
   # Remove blank lines and delete duplicates 
   sed '/^$/d' "$1"| sort -g | uniq > $TMPIN

   for NEWUSER in $(more $TMPIN); do
		# Checks if the user already exists.
		cut -d: -f1 /etc/passwd | grep $NEWUSER > /dev/null
			OUT=$?
		if [ $OUT -eq 0 ];then
			echo >&2 "ERROR: User account: \"$NEWUSER\" already exists." && echo >&2 "ERROR: User account: \"$NEWUSER\" already exists." >> $LOGFILE
		else
			# Create a new user
			PASS=$(pwgen 12 1 -Bsv)
			/usr/sbin/useradd $NEWUSER -d $PERS_HOME/$NEWUSER -s $PERS_SH -g $GROUP -m
			(echo $PASS; echo $PASS) | pure-pw useradd $NEWUSER -u $NEWUSER -g $GROUP -d $PERS_HOME/$NEWUSER -m
			# save user and PASSword in a file
			echo -e $NEWUSER"\t"$PASS >> $LOGFILE
		fi
   done
   rm -f $TMPIN
   systemctl restart pure-ftpd.service
   exit 0
else
   echo >&2 "ERROR: You must be a root user to execute this script."
   exit 1
fi
