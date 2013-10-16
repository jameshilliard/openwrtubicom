# usage setwanipnroute ip4address mask
# flush eth1 ipaddress
ip -f inet addr flush dev eth1

#attach a new forced ip address.
ip addr add $1/$2 dev eth1

ip route add default dev eth1

