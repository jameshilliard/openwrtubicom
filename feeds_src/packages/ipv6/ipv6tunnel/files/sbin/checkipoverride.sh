#!/bin/sh

#cp /etc/config/mantun /tmp/tunnel
echo "reading mantun..."


# case 7 Wan Ipv4 addr
p=$(uci get mantun.overridetunnel.WANip4addr)
echo Wan Ipv4 addr $p

if [ -z $p ];
then
	# take the manual stuff into
	echo "found option 'WANip4addr': no need to take from override."
else
	
       # now do actual write
       new_ip6=$(echo ${p}|sed 's/\//\\\//g')
       uci -c /tmp/ set tunnel.overridetunnel.WANip4addr="${new_ip6}"
       uci -c /tmp/ commit tunnel
fi

# case 8 6RD Br
p=$(uci get mantun.overridetunnel.i6RDBr)
echo 6RD Br $p

if [ -z $p ];
then
	# take the manual stuff into
	echo "found option 'i6RDBr': no need to take from override."
else
       # now do actual write
       i6rd_br=$(echo ${p}|sed 's/\//\\\//g')
       uci -c /tmp/ set tunnel.overridetunnel.i6RDBr="${i6rd_br}"
       uci -c /tmp/ commit tunnel
fi


# case 9 i6RDPrefix
p=$(uci get mantun.overridetunnel.i6RDPrefix)
echo i6RD Prefix $p

if [ -z $p ];
then
	# take the manual stuff into
	echo "found option 'i6RDPrefix': no need to take from override."
else
       # now do actual write
       i6rd_prefix=$(echo ${p}|sed 's/\//\\\//g')
       uci -c /tmp/ set tunnel.overridetunnel.i6RDPrefix="${i6rd_prefix}"
       uci -c /tmp/ commit tunnel
fi


# case 10 6RD Prefix len
p=$(uci get mantun.overridetunnel.i6RDPrefixLength)
echo 6RD Prefix len $p

if [ -z $p ];
then
	# take the manual stuff into
	echo "found option 'i6RDPrefixLength': no need to take from override."
else
       # now do actual write
       i6rd_PrefxLen=$(echo ${p}|sed 's/\//\\\//g')
       uci -c /tmp/ set tunnel.overridetunnel.i6RDPrefixLength="${i6rd_PrefxLen}"
       uci -c /tmp/ commit tunnel
fi


# case 11 ipv4 mask len
p=$(uci get mantun.overridetunnel.IPv4MaskLength)
echo ipv4 mask len $p

if [ -z $p ];
then
	# take the manual stuff into
	echo "found option 'i6RDBr': no need to take from override."
else
       # now do actual write
       ipv4_masklen=$(echo ${p}|sed 's/\//\\\//g')
       uci -c /tmp/ set tunnel.overridetunnel.IPv4MaskLength="${ipv4_masklen}"
       uci -c /tmp/ commit tunnel
fi

# DS-lite Cases
# case 12 dhcp6_name_servers to Ipv6dns
p=$(uci get mantun.overridetunnel.dhcp6_name_servers)
echo Ipv6 dns  $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'Ipv6dns': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	dhcp6_name_servers=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.Ipv6dns="${dhcp6_name_servers}"   
	uci -c /tmp/ commit tunnel                                                
fi


# case 13 remoteendpointipv6addr to Remoteip6addr
p=$(uci get mantun.overridetunnel.remoteendpointipv6addr)
echo Remoteip6addr  $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'Remoteip6addr': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	remoteendpointipv6addr=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.Remoteip6addr="${remoteendpointipv6addr}"   
	uci -c /tmp/ commit tunnel                                                
fi


# case 14 ip6gateway to Ipv6gate
p=$(uci get mantun.overridetunnel.ip6gateway)
echo Ipv6gate  $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'Ipv6gate': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	ip6gateway=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.Ipv6gate="${ip6gateway}"   
	uci -c /tmp/ commit tunnel                                                
fi

# case 15 DFBitState to DFBitState
p=$(uci get mantun.overridetunnel.DFBitState)
echo DFBitState $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'DFBitState': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	DFBitState=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.DFBitState="${DFBitState}"   
	uci -c /tmp/ commit tunnel                                                
fi


# case 16 v6SMTU to v6SMTU
p=$(uci get mantun.overridetunnel.v6SMTU)
echo v6SMTU $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'v6SMTU': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	v6SMTU=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.v6SMTU="${v6SMTU}"   
	uci -c /tmp/ commit tunnel                                                
fi

# case 17 v4SMTU to v4SMTU
p=$(uci get mantun.overridetunnel.v4SMTU)
echo v4SMTU $p
if [ -z $p ]; then 
	# take the manual stuff into                                             
	echo "found option 'v4SMTU': no need to take from override."             
else                                                                             
	# now do actual write                                                     
	v4SMTU=$(echo ${p}|sed 's/\//\\\//g')                               
	uci -c /tmp/ set tunnel.static.v4SMTU="${v4SMTU}"   
	uci -c /tmp/ commit tunnel                                                
fi
#exit 0
