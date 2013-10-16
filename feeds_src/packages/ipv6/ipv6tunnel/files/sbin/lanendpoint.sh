#!/bin/sh    
#script lines to replace prefix got /64 and add ::1 to the end to it or attach without adding ::1

# Working logic for putting ::/64 starts
#ipv6_prefix=$(cat /tmp/tunnel.conf | grep "option 'ip6_prefix'" | sed s/"option 'ip6_prefix'"//g | sed s/\'//g )
ipv6_prefix=$1
if [ -z $ipv6_prefix ];
then
  exit 0
else  
      ip_addr=${ipv6_prefix%/*}  # everything before the slash
      ip_mask=${ipv6_prefix#*/}  # everything after the slash
      #echo $ip_addr
      #echo $ip_mask

      
      new_ip_addr=$(echo ${ip_addr}"1/"${ip_mask}) # this was for ::1/
      #new_ip_addr=$(echo ${ip_addr}"/"${ip_mask}) # this is for ::/
      echo $new_ip_addr

      # use this new calculated ip address to attach it to lan interface

      # flush existing lan ip address. ( only remove ipv6 addresses of this interface.)
      ip -f inet6 addr flush dev br-lan scope global
      # add new ip address
      ip -6 addr add $new_ip_addr dev br-lan
      exit 0
fi
     

