# delete existing tunnel
if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then
	ip -6 tunnel del sit1 
	if [ $(ifconfig | grep "sit1" | wc -l) -gt 0 ]; then
		echo "6RD Operation Failed!!!"
	else
		echo "6RD Tunnel Successfully Deleted!!!"
	fi
else
	echo "6RD Tunnel does not exist!!!"
fi 

if [ $(ifconfig | grep "dslite" | wc -l) -gt 0 ]; then
	ip -6 tunnel del dslite
	if [ $(ifconfig | grep "dslite" | wc -l) -gt 0 ]; then
		echo "DS-Lite Operation Failed!!!"
	else
		echo "DS-Lite Tunnel Successfully Deleted!!!"
	fi
else
	echo "DS-Lite Tunnel does not exist!!!"
fi  
