# delete existing tunnel
if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then
	ip -6 tunnel del sit1 
	if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then
		echo "Operation Failed!!!"
	else
		echo "Tunnel Successfully Deleted!!!"
	fi
else
	echo "Tunnel does not exist!!!"
fi  
