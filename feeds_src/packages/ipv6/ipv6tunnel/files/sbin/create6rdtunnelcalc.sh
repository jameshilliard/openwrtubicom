#!/bin/sh 

# run script to create/del tunnel
	TunnelMode=$(uci get mantun.general.TunnelMode)
	TunnelType=$(uci get mantun.general.TunnelType)
 
  #touch /tmp/test1

  /sbin/delete6rdtunnel.sh

if [ $TunnelType -eq 2 ]; then
	   # create 6rd tunnel in static mode 
	   if [ $TunnelMode -eq 1 ]; then
		i6RDBr=$(uci -c /tmp/ get tunnel.static.i6RDBr)
		WANip4addr=$(uci -c /tmp/ get tunnel.static.WANip4addr)
		i6RDPrefix=$(uci -c /tmp/ get tunnel.static.i6RDPrefix)
		i6RDPrefixLength=$(uci -c /tmp/ get tunnel.static.i6RDPrefixLength)
		i6rdMTU=$(uci -c /tmp/ get tunnel.overridetunnel.i6rdMTU)
		IPv4MaskLength=$(uci -c /tmp/ get tunnel.static.IPv4MaskLength)
	   else
		i6RDBr=$(uci -c /tmp/ get tunnel.static.i6RDBr)
		WANip4addr=$(uci -c /tmp/ get tunnel.static.WANip4addr)
		i6RDPrefix=$(uci -c /tmp/ get tunnel.static.i6RDPrefix)
		i6RDPrefixLength=$(uci -c /tmp/ get tunnel.static.i6RDPrefixLength)
		i6rdMTU=$(uci -c /tmp/ get tunnel.static.i6rdMTU )
		IPv4MaskLength=$(uci -c /tmp/ get tunnel.static.IPv4MaskLength)
	   fi
	     
	   echo "starting domain name resolution stuff"                      
	   i6RDBr=$(uci get mantun.static.i6RDBr)
           echo "read value for i6RDBr =" ${i6RDBr}                                                                            
           echo "calling resolve by hostname"                                                                                  
           i6RDBr=$(/sbin/resolvehostbyname  ${i6RDBr})                                                                        
           echo "after resolution found value of i6RDBr =" ${i6RDBr} 
	   echo "realprefix /sbin/i6rdcalc  $i6RDPrefix::/$i6RDPrefixLength   $WANip4addr $IPv4MaskLength"

	   realprefix=$(/sbin/i6rdcalc  $i6RDPrefix::/$i6RDPrefixLength   $WANip4addr $IPv4MaskLength )
	   networkaddress=$(/sbin/sipcalc $WANip4addr/$IPv4MaskLength | grep "Network address" | cut -d \- -f 2)
	   echo realprefix  $i6RDPrefix::/$i6RDPrefixLength   $WANip4addr $IPv4MaskLength 
    
           echo $WANip4addr  $i6RDPrefix::/$i6RDPrefixLength   $i6RDBr Calculatedprefix=$realprefix networkaddress=$networkaddress
	   echo /sbin/create6rdtunnel.sh $WANip4addr  $realprefix   $i6RDBr  $networkaddress
	   /sbin/create6rdtunnel.sh $WANip4addr  $realprefix   $i6RDBr  $networkaddress 
	   echo "Setting Tunnel mtu"
           if [ -z  $i6rdMTU ]; then
             ifconfig sit1 mtu 1280
           else
             ifconfig sit1 mtu $i6rdMTU
           fi
           
          #radvd
          ip_addr=${realprefix%::/*}  # everything before the slash
          ip_mask=${realprefix#*/} 
          /sbin/radvd.sh  $ip_addr::/64 $ip_addr::1 $i6rdMTU 
          echo radvd.sh  $ip_addr::/64 $ip_addr::1 $i6rdMTU  
          /sbin/lanendpoint.sh $ip_addr::/64 

fi
