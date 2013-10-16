#!/bin/sh 

# run script to create/del tunnel
  TunnelMode=$(uci get mantun.general.TunnelMode)
  TunnelType=$(uci get mantun.general.TunnelType)
 
  #touch /tmp/test1

  /sbin/deletetunnel.sh

if [ $TunnelType -eq 2 ]; then
	   # create 6rd tunnel in static mode 
	   if [ $TunnelMode -eq 1 ]; then
		i6RDBr=$(uci -c /tmp/ get tunnel.overridetunnel.i6RDBr)
		WANip4addr=$(uci -c /tmp/ get tunnel.overridetunnel.WANip4addr)
		i6RDPrefix=$(uci -c /tmp/ get tunnel.overridetunnel.i6RDPrefix)
		i6RDPrefixLength=$(uci -c /tmp/ get tunnel.overridetunnel.i6RDPrefixLength)
		i6RDMTU=$(uci -c /tmp/ get tunnel.overridetunnel.i6RDMTU)
		IPv4MaskLength=$(uci -c /tmp/ get tunnel.overridetunnel.IPv4MaskLength)
	   else
		i6RDBr=$(uci -c /tmp/ get tunnel.static.i6RDBr)
		WANip4addr=$(uci -c /tmp/ get tunnel.static.WANip4addr)
		i6RDPrefix=$(uci -c /tmp/ get tunnel.static.i6RDPrefix)
		i6RDPrefixLength=$(uci -c /tmp/ get tunnel.static.i6RDPrefixLength)
		i6RDMTU=$(uci -c /tmp/ get tunnel.static.i6RDMTU)
		IPv4MaskLength=$(uci -c /tmp/ get tunnel.static.IPv4MaskLength)
	   fi
	  
	   echo "starting domain name resolution stuff"                      
           i6RDBr=$(uci get mantun.static.i6RDBr)
           echo "read value for i6RDBr =" ${i6RDBr}                                                                            
           echo "calling resolve by hostname"                                                                                  
           i6RDBr=$(/sbin/resolvehostbyname  ${i6RDBr})                                                                        
           echo "after resolution found value of i6RDBr =" ${i6RDBr} 
           
	   realprefix=$(/sbin/i6rdcalc  $i6RDPrefix::/$i6RDPrefixLength   $WANip4addr $IPv4MaskLength )
	   echo realprefix  $i6RDPrefix::/$i6RDPrefixLength   $WANip4addr $IPv4MaskLength 
	    
           echo $WANip4addr  $i6RDPrefix::/$i6RDPrefixLength   $i6RDBr Calculatedprefix=$realprefix
	   /sbin/create6rdtunnel.sh $WANip4addr  $realprefix   $i6RDBr
	   echo "Setting Tunnel mtu"
           if [ -z  $i6RDMTU ]; then
             ifconfig sit1 mtu 1280
           else
             ifconfig sit1 mtu $i6RDMTU
           fi
           
          #radvd
          ip_addr=${realprefix%::/*}  # everything before the slash
          ip_mask=${realprefix#*/} 
          /sbin/radvd.sh  $ip_addr::/64 $ip_addr:: $i6RDMTU 
          /sbin/lanendpoint.sh $ip_addr::/64 

fi
