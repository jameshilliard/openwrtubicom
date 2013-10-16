TunnelMode=$(uci get mantun.general.TunnelMode)  
TunnelType=$(uci get mantun.general.TunnelType) 
if [ $TunnelType -eq 2 ]; then
	if [ $TunnelMode -eq 0 ]; then
		i6RDPrefix=$(uci get mantun.static.i6RDPrefix | grep '::/[0-9]\{1,2\}$')
		if [ -z $i6RDPrefix ]; then
			echo "No need to modify prefix"
		else
			i6RDPrefixHead=${i6RDPrefix%::/*}  # everything before the slash
			i6RDPrefixLen=${i6RDPrefix#*::/}  # everything after the slash
			uci set mantun.static.i6RDPrefix="$i6RDPrefixHead"
			uci set mantun.static.i6RDPrefixLength="$i6RDPrefixLen"
			uci commit mantun
		fi
	fi
fi
