#!/bin/sh    

      #copy original radvd.conf file before starting
      cp /etc/config/radvd.conf /tmp/radvd.conf

    # This is for setting MTU for LINK 
     if [ -z  $3 ]; then
       echo "Taking mtulink as default value"
     else
     	
     if [ $3 -ne 0 ]
      then
      	option12="AdvLinkMTU.*"
      	pmtu_size="$3;"
      	replace12="AdvLinkMTU "${pmtu_size}
      	sed "s/$option12/$replace12/g" /tmp/radvd.conf>/tmp/temp.conf
      	cp /tmp/temp.conf /tmp/radvd.conf
      fi
      fi

      option12="prefix.*"
      new_ip6=$(echo ${1}|sed 's/\//\\\//g')
      replace12="prefix "${new_ip6}

      sed "s/$option12/$replace12/g" /tmp/radvd.conf > /tmp/temp.conf
      cp /tmp/temp.conf /tmp/radvd.conf
      
      option13="RDNSS.*"
      new_ip6=$(echo ${2}|sed 's/\//\\\//g')
      replace13="RDNSS "${new_ip6}

      sed "/Adv/!s/$option13/$replace13/g" /tmp/radvd.conf>/tmp/temp.conf
      cp /tmp/temp.conf /tmp/radvd.conf
      
      #cp /tmp/temp.conf /etc/radvd.conf  # commented to save flash life
      
      RADVD_CONFIG_FILE=/tmp/radvd.conf
 
     #######################
     #call RADVD here now
 
     #enable IPv6 forwarding
     echo 1 > /proc/sys/net/ipv6/conf/all/forwarding 
     echo 0 > /proc/sys/net/ipv6/conf/eth1/forwarding 
      #sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null 2> /dev/null                                                                                
                                                                                                                                                        
      #radvd -C "$RADVD_CONFIG_FILE" -m stderr_syslog -p /var/run/radvd.pid  
      killall radvd    
     #if [ $(ifconfig | grep "radvd" | wc -l) -gt 0 ]; then
     #	kill -9 $(pidof radvd)     
     #else
	#radvd 
	radvd -C "$RADVD_CONFIG_FILE" -m stderr_syslog -p /var/run/radvd.pid  
     #fi
