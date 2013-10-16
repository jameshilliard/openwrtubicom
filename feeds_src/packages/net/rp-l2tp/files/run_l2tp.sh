#!/bin/sh

. /etc/functions.sh

while true; do
	#
	# If there is a running pppd daemon, this means that the router is already 
	# trying to connect to the server. So, we sleep 10sec and re-check the daemon.
	#
	P=`ps | grep "pppd sync" | grep -v grep`
	[ "$P" = "" ] && {
		#
		# If there is a running l2tpd daemon, first kill it.
		# This will also clean any zombie pppd processes.
		#
		service_kill l2tpd
	
		sleep 1
		l2tpd &
		sleep 1

		#
		# This is the daemon that starts the pppd process. After running this daemon
		# if there is a server which the router can connect, the pppd process is created.
		# After the disconnection this pppd process dies.
		# You will see a process on the process table like this:
		# 7522 root      1658 S    pppd sync nodetach noaccomp nobsdcomp nodeflate nopco
		#
		l2tp-control "start-session $1" >/dev/null 2>&1
	}
	sleep 10
done
