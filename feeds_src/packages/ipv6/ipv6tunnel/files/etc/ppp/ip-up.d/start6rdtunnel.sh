#!/bin/sh 

# If tunnel type is 6rd (2), create 6rd tunnel after PPPoE connection is established.
TunnelType=$(uci get mantun.general.TunnelType)
TunnelMode=$(uci get mantun.general.TunnelMode)

if [ $TunnelType -eq 2 ]; then
	if [ $TunnelMode -eq 0 ]; then # if static 6rd tunnel
		/sbin/tunnellingscript cleanup
		networkwanipaddr=$4
		echo "PPPoE connection established. Create static 6rd tunnel with PPPoE WAN IP $networkwanipaddr"
		uci -c /tmp/ set tunnel.static.WANip4addr="${networkwanipaddr}"
		uci -c /tmp/ commit tunnel

		/sbin/create6rdtunnelcalc.sh
		tcpmssrewrite
	else
		# create 6rd tunnel in dhcp mode	
		echo "Wan is in PPPoE mode and 6rd tunneling is in DHCP mode"
		echo "Invalid to set 6rd to DHCP mode when WAN mode is PPPoE. Hence no tunnel will be created!"
		exit 1
	fi
fi

