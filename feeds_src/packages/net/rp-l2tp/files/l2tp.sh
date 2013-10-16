find_gw() {
	route -n | awk '$1 == "0.0.0.0" { print $2; exit }'
}

scan_l2tp() {
        config_set "$1" device "l2tp-$1"
}

stop_interface_l2tp() {
        stop_interface_ppp "$1"
	service_kill run_l2tp.sh
	service_kill l2tpd
}

coldplug_interface_l2tp() {
        setup_interface_l2tp "l2tp-$1" "$1"
}

setup_interface_l2tp() {
	local iface
	local config="$2"
	
	for module in ppp_synctty n_hdlc; do
		/sbin/insmod $module 2>&- >&-
	done
	
	local device
        config_get device "$config" device

	local server
	config_get server "$config" server

	local username
	config_get username "$config" username

	local password
	config_get password "$config" password

	setup_interface "$device" "$config" "${ipproto:-dhcp}"	
	local gw="$(find_gw)"
	
        [ -n "$gw" ] && {
        	# insert resolveoip here :)
                [ "$gw" != 0.0.0.0 ] && route delete "$server" 2>/dev/null >/dev/null
		route add "$server" gw "$gw"
	}
	
	# fix up the netmask
        config_get netmask "$config" netmask
        [ -z "$netmask" -o -z "$device" ] || ifconfig $device netmask $netmask

	local dns
	config_get dns "$config" dns

	local peer_default=1
	[ -n "$dns" ] && {
		peer_default=0
	}

	local peerdns
	config_get_bool peerdns "$config" peerdns $peer_default

	[ "$peerdns" -eq 1 ] && {
		peerdns="usepeerdns"
	} || {
		peerdns=""
		add_dns "$config" $dns
	}

	l2tp_conf=/etc/l2tp.conf
	
	echo 'global' > $l2tp_conf
	echo 'load-handler "sync-pppd.so"' >> $l2tp_conf
	echo 'load-handler "cmd.so"' >> $l2tp_conf
	echo 'listen-port 1701' >> $l2tp_conf
	echo 'section sync-pppd' >> $l2tp_conf
	echo "lac-pppd-opts \"ifname l2tp-$config ipparam $config linkname l2tp-$config $peerdns user \\\"$username\\\" password \\\"$password\\\" file /etc/ppp/options.l2tp\"" >> $l2tp_conf
	echo 'section peer' >> $l2tp_conf
	echo "peer $server" >> $l2tp_conf
	echo 'port 1701' >> $l2tp_conf
	echo 'lac-handler sync-pppd' >> $l2tp_conf
	echo 'section cmd' >> $l2tp_conf
	
	for pid in `pidof l2tpd`; do
	   kill -TERM $pid
	   sleep 1
	done

	#
        # run_l2tp.sh script re-runs the l2tp daemons
        # if the connection attempts fail.
        #                                  
        R=`ps | grep "run_l2tp.sh" | grep -v grep`
        if [ "$R" != "" ]; then
                killall run_l2tp.sh
        fi         
        /etc/ppp/run_l2tp.sh "$server" &	
}
