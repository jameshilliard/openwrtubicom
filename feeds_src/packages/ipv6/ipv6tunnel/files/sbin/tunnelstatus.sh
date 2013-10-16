#!/bin/sh


if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then

awk -v IP=$1 '	function pinger(count,ip) {
		command = "/usr/bin/ping -c "count " -i 2 " ip		
		while (( command | getline res )> 0 ) {
			if ( res ~ /0 received|100% packet loss/ ) {
				close(command)
				return 100			 
			}
		}
	close(command)
	return 0
	}	
	BEGIN { 	
	if ( pinger(2,IP) == 100 ) {
		print "DOWN" 
	} else { print "UP" }
}'

else
        #echo "Tunnel does not exist!"
        echo "DOWN"
fi

