#!/bin/bash

# AUTHOR | ETHAN SHEARER
# DESCRIPTION | ALLOW SYSTEM ADMINISTRATORS TO EASILY ADD USERS.

usersfile=users.txt # This is where the users file is located on your system.

if [ `id -u` != 0 ]; then # Check to see if the the command id -u is equal to the uid of root's (0)
    echo `id -u` # If not we echo the current users uid to the terminal.
    echo Please run this script as root or using sudo
    exit
fi

while read -r uname fname lname pword; do # Read the file contents and assign variables for each column on each line.
    useradd -c "$fname $lname" $uname # Add them into the system.
    echo $uname "|" $fname $lname "has been added into the system." # We want to echo back to the terminal that they have been added.
    echo "$uname:$pword" | chpasswd # Change their password to what is listed in the file.
done < $usersfile # Finish the while loop and also tell the script what file to read input from.
exit # Exit. Simple :)