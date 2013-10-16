TunnelMode=$(uci get mantun.general.TunnelMode)  
TunnelType=$(uci get mantun.general.TunnelType) 
if [ $TunnelType -eq 0 ]; then
	devicename=$(uci get mantun.general.dslitedevicename)
	if [ $TunnelMode -eq 0 ]; then
		smtu=$(uci get mantun.static.v4SMTU)
		if [ -z $smtu ]; then
			overridesmtu=0
		else
			overridesmtu=1
		fi
		ipv6smtu=$(uci get mantun.static.v6SMTU)
		if [ -z $smtu ]; then
			overrideipv6smtu=0
		else
			overrideipv6smtu=1
		fi
		toggle=$(uci get mantun.static.DFBitState)
	else
		smtu=$(uci get mantun.overridetunnel.v4SMTU)
		if [ -z $smtu ]; then
			overridesmtu=0
		else
			overridesmtu=1
		fi
		ipv6smtu=$(uci get mantun.overridetunnel.v6SMTU)
		if [ -z $smtu ]; then
			overrideipv6smtu=0
		else
			overrideipv6smtu=1
		fi
		toggle=$(uci get mantun.overridetunnel.DFBitState)
	fi  

	echo "writing to proc" $devicename $smtu $ipv6smtu $overrideipv6smtu $overridesmtu $toggle

	echo  $devicename > /proc/softwire/devicename
	echo  $smtu > /proc/softwire/smtu
	echo  $ipv6smtu > /proc/softwire/ipv6smtu
	echo  $overrideipv6smtu > /proc/softwire/overrideipv6smtu
	echo  $overridesmtu  > /proc/softwire/overridesmtu
	echo  $toggle > /proc/softwire/toggle

fi
