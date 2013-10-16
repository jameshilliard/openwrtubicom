#flush ipv4 wan address.
#ip address flush dev $wan #br-wan 
# $1 local IPv6 Addr
# $2 remote IPv6 Addr 

# delete existing tunnel
if [ $(ifconfig | grep "dslite" | wc -l) -gt 0 ]; then
	ip -6 tunnel del dslite 
fi
#now create new tunnel with parameters

ip -6 tunnel add dslite mode ipip6 local $1 remote $2
ip link set up dslite
ip route del default
ip route del default
ip route add default dev dslite 
if [ -z $3 ]; then # if B4 address is null then skip
	echo "skipping b4 endpoint v4 address."
else
	ip addr add $3 dev dslite
fi

#echo "done with createtunnelscript "
