#!/bin/bash

PS3="Select your choice:"  # use this prompt instead of the default '#?'

check_if_operation_successful(){

	echo -e "\n"

	if [[ $? -eq 0 ]]                                                 
    then
        	echo "$1 was $2 successfully."
    else
        	echo "There was an error $3 $1"
    fi

	echo -e "\n"
}

scpy(){

	read -p "Supply the ssh key file:" sshkey
    read -p "Path+name of file to be copied:" filename
    read -p "Provide a user@ip:" user_ip
    read -p "Provide destination directory:" destdir

    if [[ $1 -eq 1 ]]
	then

		if [[ -e "$filename" ]]		# check if file exists
		then
			if [[ -f "$filename" ]]	# check if it is a regular file. 
			then
				echo "copying the file $filename..."
				sleep 1
					# a sudo password will only be asked in case of privilege escalation
				sudo scp -i "$sshkey" "$filename" "$user_ip":"$destdir"
							

			elif [[ -d "$filename" ]]	# check if it is a directory
			then
				echo "copying the directory $filename..."
				sleep 1
				sudo scp -r -i "$sshkey" "$filename" "$user_ip":"$destdir"
							
			fi
		else
			echo "The filename does not exist"
		fi
	fi

	if [[ $1 -eq 2 ]] # it is not possible to check if the file exist on the remote host in this case
	then
		echo "copying $filename..."
		sleep 1
		sudo scp -r -i "$sshkey" "$user_ip":"$filename" "$destdir"
	fi

}

cpy(){

	read -p "Path+name of file to be copied:" filename
	read -p "Path to the destination:" dest

 # cp a file or folder to a given location 

    if [[ $1 -eq 4 ]]
	then
		echo "copying $filename..." 
		sleep 1
		cp -r "$filename" "$dest"

		check_if_operation_successful "$filename" copied copying
		

# cp files in a directory to a given location

	elif [[ $1 -eq 5 ]]
	then
		for file in "$filename"/*
        do
             if [[ -f "$file" ]]; then  # Check if it's a file
             echo "copying $file..."
             cp "$file" "$dest"  # Copy the file
             fi
        done
	fi
}

rsyncpy(){

	if [[ $1 -eq 6 ]]
	then

		read -p "Directory whose content you want to sync:" dir
		read -p "Path to the destination directory:" dest
		echo "Add any option and option values: --delete, --exclude or enter-key for non"
		read -p ":" opval

		echo "syncing $dir..." 
		sleep 1
		opvallen=${#opval} #obtain the length of opval
		if [[ $opvallen -gt 1 ]] # execute command with opval if it was typed by user
		then
			rsync -av $opval "$dir"/ "$dest"      # Notice: $opval here has no quotes. 
													# pass exclude at cmd line without
													# quotes. e.g. --exclude=*.png 
		else 								# execute cmd without opval
			rsync -av "$dir"/ "$dest"		# enter-key gives an opval value of 0.
		fi

		check_if_operation_successful "$dir" synced syncing
	
	fi

	if [[ $1 -eq 7 || $1 -eq 8 ]]
	then
		read -p "Supply the ssh key file:" sshkey
    	read -p "Path+name of directory to be synced:" dir
    	read -p "Provide a user@ip:" user_ip
    	read -p "Provide destination directory:" destdir

		if [[ $1 -eq 7 ]]	# syncing from local to remote host over ssh
		then 
			echo "syncing $dir to $destdir on $user_ip"
			sleep 1
			sudo rsync -av -e "ssh -i $sshkey" "$dir" "$user_ip":"$destdir"

		elif [[ $1 -eq 8 ]] # syncing from remote to local host over ssh
		then
			echo "syncing $dir from $user_ip to $destdir"
			sleep 1
			sudo rsync -av -e "ssh -i $sshkey" "$user_ip":"$dir" "$destdir"
		fi

		check_if_operation_successful "$dir" synced syncing

     #sudo rsync -av -e ssh dp2@165.227.224.55:/etc/ ~/etc-backup
	#sudo rsync -av -e 'ssh -i key_droplet2' /etc/ dp2@165.227.224.55:~/etc-backup
	fi
}

tarcpy(){

	if [[ $1 -eq 9 ]]
	then
		read -p "Directory/file(s) that you want to archive:" dir
		read -p "Destination path + name of archive:" dest
		echo "Add any option and option values: e.g --exclude or enter-key for non"
		read -p ":" opval

		echo "archiving $dir..." 
		sleep 1
		opvallen=${#opval} #obtain the length of opval
		if [[ $opvallen -gt 1 ]] # execute command with opval if it was typed by user
		then
			tar $opval -czvf "$dest"-$(date +%F).tar.gz $dir        
													 											 
		else 								
			tar -czvf "$dest"-$(date +%F).tar.gz $dir		 
		fi
		sleep 1
		check_if_operation_successful "$dir" archived archiving

	fi
# tar -czvf etc-$(date +%F).tar.gz /etc/

	if [[ $1 -eq 10 ]]
	then
		read -p "Path+name of archive to extract:" dir
		read -p "Destination directory:" dest
		
		echo "extracting $dir..." 
		sleep 1
		tar -xzvf "$dir" -C $dest/
		check_if_operation_successful "$dir" extracted extracting

# tar -xzvf Downloads/mybundle.tar.gz -C newContainer/
	fi
}

findfile(){

	if [[ $1 -eq 11 ]]
	then
		read -p "Name or partial name (use * for part name) of file/directory or to find:" dir
		read -p "Specify the location(s) to find:" loc

		echo "finding $dir..." 
		sleep 1
		sudo find $loc -iname "$dir"
		
		#sudo find myfiles/ -iname V
	fi


}


select ITEM in "scp to remote machine" "scp from remote machine" "scp between remote machines" "cp a file/folder" "cp files in a directory" "rsync files on local machine" "rsync- local to remote " "rsync- remote to local" "Create an archive with gzip" "Extract an archive with gzip" "Find a file(s)" "Quit"
do
if [[ $REPLY -eq 1 ]] 
then
	scpy 1
        
elif [[ $REPLY -eq 2 ]]
then
	scpy 2

elif [[ $REPLY -eq 3 ]]
then
	scpy 3


elif [[ $REPLY -eq 4 ]]
then
	cpy 4

elif [[ $REPLY -eq 5 ]]
then
	cpy 5

elif [[ $REPLY -eq 6 ]]
then
	rsyncpy 6

elif [[ $REPLY -eq 7 ]]
then
	rsyncpy 7

elif [[ $REPLY -eq 8 ]]
then
	rsyncpy 8

elif [[ $REPLY -eq 9 ]]
then
	tarcpy 9

elif [[ $REPLY -eq 10 ]]
then
	tarcpy 10

elif [[ $REPLY -eq 11 ]]
then
	findfile 11

elif [[ $REPLY -eq 12 ]]
then
        echo "Quitting..."
        sleep 1
        exit
else 
	echo "Invalid option selected"
fi
done