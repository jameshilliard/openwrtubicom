#!/bin/sh   
   

#copy original radvd.conf file before starting
if [ ! -f "/tmp/radvd.conf" ]; then
      cp /etc/config/radvd.conf /tmp/
fi

RADVD_CONFIG_FILE=/tmp/radvd.conf

#######################
#call RADVD here now

#enable IPv6 forwarding
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo 0 > /proc/sys/net/ipv6/conf/eth1/forwarding
killall radvd   
#radvd
radvd -C "$RADVD_CONFIG_FILE" -m stderr_syslog -p /var/run/radvd.pid
