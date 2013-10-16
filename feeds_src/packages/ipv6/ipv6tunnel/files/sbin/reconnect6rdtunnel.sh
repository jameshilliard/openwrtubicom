# This script is reconnect to createa a valid tunnel in cases of DHCP or static configuration of WAN.
physicalwanipaddr=$(ifconfig eth1 | grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}')
if [ -f /tmp/tunnel ]; then  
        TunnelMode=$(uci get mantun.general.TunnelMode)
        if [ $TunnelMode -eq 1 ]; then        
		WANip4addr=$(uci -c /tmp/ get tunnel.overridetunnel.WANip4addr)
	else
		WANip4addr=$(uci -c /tmp/ get tunnel.static.WANip4addr)
	fi
else
         echo "Error:for some reason /tmp/tunnel is missing" & 
         /sbin/delete6rdtunnel.sh    
         exit 0
fi

echo phyaddr  $physicalwanipaddr
echo configvalue $WANip4addr

# check if static or dhcp, if static then WAN has IP addr or not, if it has then just reconnect script.if not, but there is a config just call "ifup wan", again cal create6rdtuncalc
# in DHCP mode, wif no ip addr at wan, then dont do anything, otherwise reconnecttunn

	networkwanproto=$(uci get network.wan.proto)

	if [  $networkwanproto == 'static' ]; then	
		networkwanipaddr=$(uci get network.wan.ipaddr)  networkwannetmask=$(uci get network.wan.netmask)

		if [ -z $networkwanipaddr ] || [ -z  $networkwanproto ] || [ -z $networkwannetmask ]; then
		         echo "networkwanipaddr or networkwanproto or networkwanproto was null  hence exiting"
		         /sbin/delete6rdtunnel.sh
			 exit 0;
			 			  
		else
		if [ -f /tmp/tunnel ]; then
		if [ -z $physicalwanipaddr ] || [ -z $WANip4addr ]; then
	     		echo  " atleast one of  physicalwanipaddr or /tmp/tunnel->WANip4addr is null bad case: sad path"
	     		# bad!! this is a bad cause something went wrong which shoudnt have in first place. so rectifying the same.
			ifup wan		
			# now wan is up with valid config copy this to /tmp/tunnel
			uci -c /tmp/ set tunnel.static.WANip4addr="${networkwanipaddr}"
			uci -c /tmp/ commit tunnel
			              
			/sbin/create6rdtunnelcalc.sh	
			#/etc/init.d/tunnelscript start 
      			exit 0	
  		else
			echo "WAN IP addresses and tunnel ip address exists: "
			if [ $physicalwanipaddr == $WANip4addr ]; then
      						
	      		 	# everything looks fine, expecting the default route to be present blindly
      				echo "good case both values match re creating tunnel"
      				/sbin/create6rdtunnelcalc.sh # we create tunnel using the already got parameters
       		        else
			       # bad!! this is a bad cause something went wrong which shoudnt have in first place. so rectifying the same.
      	      			echo "bad case: both values dont match so start from scratch"
     	      			#/etc/init.d/tunnelscript start
				#/tmp/tunnel, copy wan ip4 addr from /etc/config/network into /tmp/tunnel
				uci -c /tmp/ set tunnel.static.WANip4addr="${networkwanipaddr}"
				uci -c /tmp/ commit tunnel

				ifup wan				
				/sbin/create6rdtunnelcalc.sh	
   			fi
		fi
		else
		   echo "Error:for some reason /tmp/tunnel is missing"
		   /sbin/delete6rdtunnel.sh  
		fi 
	fi
	else
	if [ -f /tmp/tunnel ]; then # if the tunnel configuration does not exist
	if [  $networkwanproto == 'dhcp' ]; then
		if [ -z $physicalwanipaddr ]; then
			echo "do nothing as dhcp & either config or wan ip addr set"
			/sbin/delete6rdtunnel.sh
			exit 0
  		else
	       	        if [ $physicalwanipaddr == $WANip4addr ]; then		
				echo "Goodcase:wan ipv4 is  matching in dhcp mode- recreating tunnel"
				/sbin/create6rdtunnelcalc.sh
			else
				# copy the physical wan ip addrr to the config file then recreate the tunnel
				uci -c /tmp/ set tunnel.overridetunnel.WANip4addr="${physicalwanipaddr}"
				uci -c /tmp/ commit tunnel
				/sbin/create6rdtunnelcalc.sh
				
			fi
		fi
	fi
	else
	  echo "Error:for some reason /tmp/tunnel is missing"                                                                                                        
	   /sbin/delete6rdtunnel.sh         
	fi
fi
