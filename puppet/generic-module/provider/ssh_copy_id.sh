#!/usr/bin/env expect

#############################
#
# Author : Kowshik Prakasam
#
# An expect script to automatically login to each host as a particular user and 
# install the user's public key using ssh-copy-id
#
# If successful, exits with zero (0) status 
# If unsuccessful, exits with non-zero status
#
# Usage : sshcopy.exp <user@host> <key_file> <password>
# Example : sshcopy.exp root@128.111.55.234 /home/appscale/.appscale/appscale joe
#
#############################

# Procedure to interact with ssh-copy-id command
# Parameter : password 
proc sshcopyid { password } {
  expect {
    # Send password at 'Password' prompt and tell expect to continue(i.e. exp_continue)
    -re "\[P|p]assword:" { exp_send "$password\r"
                           exp_continue }

    #Returning 1 as ssh-copy-id has failed
    -re "^\[P|p]ermission denied*" { return 1}
                           
    #Answering yes to ssh host 
    -nocase  "are you sure you want to continue connecting (yes/no)?" { exp_send "yes\r"
    	    	      	       	   	   	    	       		    exp_continue }
            
    # Tell expect stay in this 'expect' block and for each character that ssh-copy-id prints while doing the copy
    # Reset the timeout counter back to 0
    -re .                { exp_continue  }
    timeout              { return 1      }
    
    #Returning 0 as ssh-copy-id was successful
    eof                  { return 0      }
  }
}

#Parsing command-line arguments
set host [lrange $argv 0 0]
set key_file [lrange $argv 1 1]
set password [lrange $argv 2 2]

#Setting timeout to an arbitrary value of 3 that works well for ssh-copy-id
set timeout 3

# Execute ssh-copy-id command
eval spawn ssh-copy-id -i $key_file $host

#Get the result of ssh-copy-id
set sshcopyid_result [sshcopyid $password]

# If ssh-copy-id was successful
if { $sshcopyid_result == 0 } {
  #Exit with zero status
  exit 0
}

# Error attempting ssh-copy-id, so exit with non-zero status
exit 1
