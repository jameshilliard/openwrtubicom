#Syntax :: create6rdtunnel.sh wan-addrV4 6rd-prefix gateway

#Validation section starts
usage ()
{
    echo "Syntax  :: create6rdtunnel.sh wan-addrV4  6rd-calc_prefix   gateway_br     6rd-relay_prefix_v4"
    echo "Example :: create6rdtunnel.sh 4.3.2.1     2001:0:1000::/64   20.1.2.3        4.3.2.0/24"
    echo "Note:: the last prameter 6rd-relay_prefix_v4 is optional but recommended used for optimized routing."
}

if [ $# != 3 ] &&  [ $# != 4 ]; then
    echo "Some inputs are missing !!"
    usage
    exit
fi

wan_addrV4=$(echo $1 | egrep "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" )

if [ -z $wan_addrV4 ]; then
    echo "Invalid IPv4 wan address !!"
    usage
    exit
fi

tunnel_prefix=$(echo $2 | egrep "\b([0-9]|[a-e]|[A-E])([0-9]|[a-e]|[A-E]|:|)*\b" )

if [ -z $tunnel_prefix ]; then
    echo "Invalid prefix !!"
    usage
    exit
fi

wan_gateway=$(echo $3 | egrep "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" )

if [ -z $wan_gateway ]; then
    echo "Invalid IPv4 gateway address !!"
    usage
    exit
fi
#Validation section ends



# delete existing tunnel
if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then
	ip -6 tunnel del sit1 
fi
#now create new tunnel with parameters

ip tunnel add sit1 mode sit ttl 64 remote any local $1
ip link set dev sit1 up

#For routing optimization 

TunnelMode=$(uci get mantun.general.TunnelMode)
if [ $TunnelMode -eq 1 ]; then
	i6RDPrefix=$(uci -c /tmp/ get tunnel.static.i6RDPrefix)
	i6RDPrefixLength=$(uci -c /tmp/ get tunnel.static.i6RDPrefixLength)
else
	i6RDPrefix=$(uci -c /tmp/ get tunnel.static.i6RDPrefix)
	i6RDPrefixLength=$(uci -c /tmp/ get tunnel.static.i6RDPrefixLength)
fi

if [ -z $4 ]; then
	ip tunnel 6rd dev sit1 6rd-prefix $i6RDPrefix::/$i6RDPrefixLength # no optmized routing here
else
	IPv4MaskLength=$(uci -c /tmp/ get tunnel.static.IPv4MaskLength)
	ip tunnel 6rd dev sit1 6rd-prefix $i6RDPrefix::/$i6RDPrefixLength 6rd-relay_prefix $4/$IPv4MaskLength # enable optimized routing
fi

ip -6 route add ::$3 dev sit1 metric 1
ip -6 route add default via ::$3 dev sit1 metric 1
ModParam=$(echo $2 | sed -e "s/\:\/[0-9][0-9]*$//")
ip -6 addr add $ModParam:2/128 dev sit1 

echo "done with create6rdtunnelscript "






