#!/bin/bash
PS3="Select a choice:"  # use this prompt instead of the default '#?'

check_if_operation_successful(){

	echo -e "\n"

	if [[ $? -eq 0 ]]			 # check the status of the last run command
	then 
		echo "$1 was added successfully."
		$2
	else 
		echo "There was an error adding $1"
	fi

	echo -e "\n"
}

create_group(){

	read -p "Enter Group Name:" groupname

	sudo groupadd "$groupname"

	cmd="tail -1 /etc/group"

	check_if_operation_successful "$groupname" "$cmd"
}

create_user(){

	read -p "Enter the username:" username
	read -p "Enter user group:" usergroup
	output="$(grep -w $username /etc/passwd)"  # check if the user already exist
	if [[ -n "$output" ]]
	then 
		echo "The username $username already exists"
	else
		if [[ -z "$usergroup" ]]
		then 
			sudo adduser --shell /bin/bash --home /home/"$username" "$username"	
		fi

		if [[ -n "$usergroup" ]]
		then
			sudo adduser --shell /bin/bash --ingroup "$usergroup" --home /home/"$username" "$username"
		fi

		cmd="tail -1 /etc/passwd" 

		check_if_operation_successful "$username" "$cmd"
	fi

}

adduser_togroup(){
	read -p "Enter the group name:" groupname
	read -p "Enter user to add to this group:" username

	sudo usermod -aG "$groupname" "$username"

	cmd="groups $username"

	check_if_operation_successful "$username" "$cmd"

}

listprocesses(){

	echo "Listing all Processes....."
	sleep 1
	ps -ef
}

killprocess(){

	read -p "Enter the process to kill:" process
	pkill $process
}

seeports(){

	#sudo netstat -tupan
	sudo ss -tupan
}

fileswhichopenTCPportsinLISTEN(){

	sudo lsof -iTCP -sTCP:LISTEN -nP
}

installapp(){

	read -p "Enter the program to install:" application
	sudo apt update
	sudo apt install $application
}

select ITEM in "Add New Group" "Add New User" "Add Existing User to a Group" "List All Processes" "Kill a Process" "Show ports and services listening for traffic on them" "Show files that opened TCP ports which are in the LISTEN state" "Install a Program" "Quit"
do
if [[ $REPLY -eq 1 ]] 
then 
	create_group

elif [[ $REPLY -eq 2 ]] 
then 
	create_user

elif [[ $REPLY -eq 3 ]] 
then 
	adduser_togroup
	
	
elif [[ $REPLY -eq 4 ]]	
then 
	listprocesses
	
	
elif [[ $REPLY -eq 5 ]]
then 
	killprocess

elif [[ $REPLY -eq 6 ]]
then 
	seeports

elif [[ $REPLY -eq 7 ]]
then 
	fileswhichopenTCPportsinLISTEN
	
	
elif [[ $REPLY -eq 8 ]]
then 
	installapp
	
	
elif [[ $REPLY -eq 9 ]]
then 
	echo "Quitting..."
	sleep 1
	exit
else 
	echo "Invalid option selected"
fi
	

done
