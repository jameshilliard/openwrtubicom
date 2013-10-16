ip -6 addr add 2023::2/64 dev eth1
ip -6 tunnel add softwire mode ipip6 local 2023::2 remote 2023::1
ip link set up softwire
ip route del default
ip route del default # run this command two times bcoz sometimes there are issues.
ip route add default dev softwire
ip addr add 192.168.4.12/24 dev softwire


