#!/bin/sh 

# run script to create/del tunnel
  TunnelMode=$(uci get mantun.general.TunnelMode)
  TunnelType=$(uci get mantun.general.TunnelType)
 
  /sbin/deletetunnel.sh

if [ $TunnelType -eq 0 ]; then
	
	# create DS-Lite tunnel
	if [ $TunnelMode -eq 0 ]; then
		localipv6address=$(uci -c /tmp/ get tunnel.static.Localip6addr)
		remoteipv6address=$(uci -c /tmp/ get tunnel.static.Remoteip6addr)
		lanip6addr=$(uci -c /tmp/ get tunnel.static.LANip6addr)
		PrefixDelegation=$(uci -c /tmp/ get tunnel.static.PrefixDelegation)
		B4v4Addr=$(uci -c /tmp/ get tunnel.static.B4v4Addr)
		Ipv6dns=$(uci -c /tmp/ get tunnel.static.Ipv6dns)
		Ipv6gate=$(uci -c /tmp/ get tunnel.static.Ipv6gate)
	else
		localipv6address=$(uci -c /tmp/ get tunnel.overridetunnel.Localip6addr)
		remoteipv6address=$(uci -c /tmp/ get tunnel.overridetunnel.remoteendpointipv6addr)
		PrefixDelegation=$(uci -c /tmp/ get tunnel.overridetunnel.ip6_prefix)
		B4v4Addr=$(uci -c /tmp/ get tunnel.static.B4v4Addr)
		Ipv6dns=$(uci get mantun.overridetunnel.Ipv6dns)
		if [ -z $Ipv6dns ]; then		
			Ipv6dns=$(uci -c /tmp/ get tunnel.overridetunnel.dhcp6_name_servers)
		fi
		Ipv6gate=$(uci get mantun.overridetunnel.ip6gateway)
		if [ -z $Ipv6gate ]; then
			Ipv6gate=$(uci -c /tmp/ get tunnel.overridetunnel.ip6gateway)
		fi
	fi
	ifaceWan=$(uci get network.wan.ifname)
	#iface error check
	ip -f inet6 addr flush dev ${ifaceWan} scope global
	ip -6 addr add ${localipv6address} dev ${ifaceWan}

	#
	ip -f inet addr flush dev ${ifaceWan}
	/etc/init.d/firewall stop
	createdslitetunnel.sh ${localipv6address} ${remoteipv6address} ${B4v4Addr}
	
	 #calculate if br-lan ip6 address is set by interface forcefully. if yes then apply that and not prefix::1
	 ip6_addr=${PrefixDelegation%/*}  # everything before the slash
	 ip6_mask=${PrefixDelegation#*/}  # everything after the slash
	 calc_ip6_addr=$(echo ${ip6_addr}"1/"${ip6_mask}) # this was for ::1/

	if [ -z $lanip6addr ]; then # if lan address forced is null then
		if [ $(uci get network.lan.type) == 'bridge' ]; then # if its bridged mode then set landside bridge name else interface itself
                 	iface='br-lan'
		 else
			iface=$(uci get network.lan.ifname)
		 fi
		
		#iface error check
		ip -f inet6 addr flush dev ${iface} scope global
		ip -6 addr add ${calc_ip6_addr} dev ${iface}

	else	# valid land address
		if [ $(uci get network.lan.type) == 'bridge' ]; then # if its bridged mode then set landside bridge name else interface itself
                 	iface='br-lan'
		 else
			iface=$(uci get network.lan.ifname)
		 fi
		#iface error check
		ip -f inet6 addr flush dev ${iface} scope global
		ip -6 addr add ${lanip6addr} dev ${iface}
	fi
	
	# radvd
	if [ -z $lanip6addr ]; then
		/sbin/radvd.sh ${PrefixDelegation%/*}/64 ${ip6_addr}1 1500 	#advertise calculated ip6_addr::1
	else
		/sbin/radvd.sh ${PrefixDelegation%/*}/64 ${lanip6addr%/*}   1500 #skip prefix part for rddns
	fi

	#setup DNS
	if [ -z $Ipv6dns ]; then
		echo "skipping forced dns as its null"
	else
		if [ -f /tmp/resolv.conf.auto ]; then
			echo "" > /tmp/resolv.conf.auto # Remove if old DNS to be include
		else
			ln -sf /tmp/resolv.conf.auto /tmp/resolv.conf
			echo "" > /tmp/resolv.conf.auto # Remove if old DNS to be include
		fi
		for dns in $Ipv6dns; do
			grep -qsF "nameserver $dns" /tmp/resolv.conf.auto || {                                               
				add="${add:+$add }$dns"                                                                      
			        echo "nameserver $dns" >> /tmp/resolv.conf.auto        
			}
		done
	fi
	
	# set v6 default route
	ip -6 route del default
	ip -6 route del default # repeat it as its a bug and sometimes it simply won't delete kernel bug.
	if [ -z Ipv6gate ]; then
		ip -6 route add default dev eth1	
	else
		ip -6 route add default via ${Ipv6gate} dev eth1
	fi

#	echo " Work pending for NAT-PMP, PortProxy - + disabling of NAT is pending"
#	echo "Starting DS-Lite Tunnelling in DHCP mode"
#	/sbin/dhclient -6 -d  cf /etc/dhcp6.conf  sf /sbin/dhclient6-script
	/sbin/proc_vars_init.sh
fi


