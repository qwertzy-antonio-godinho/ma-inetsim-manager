#! /bin/bash

kill $(ps aux | grep "[i]netsim_main" | awk '{ print $2 }')

# IRC
iptables -t nat -D PREROUTING -i enp0s8 -p tcp --dport 6667 -j REDIRECT --to-port 16667
iptables -t nat -D PREROUTING -i enp0s8 -p tcp --dport 6668 -j REDIRECT --to-port 16667
iptables -t nat -D PREROUTING -i enp0s8 -p tcp --dport 6669 -j REDIRECT --to-port 16667

# HTTPS
iptables -t nat -D PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to-port 8443

# SMTP
iptables -t nat -D PREROUTING -i enp0s8 -p tcp --dport 465 -j REDIRECT --to-port 8465

# ALL OTHER TRAFFIC
iptables -t nat -D PREROUTING -i enp0s8 -j REDIRECT

if ! (systemctl is-active ntp.service &>/dev/null) ; then
	systemctl start ntp.service
fi

if ! (systemctl is-active systemd-resolved.service &>/dev/null) ; then
	systemctl start systemd-resolved.service
fi

if (systemctl is-active PolarProxy.service &>/dev/null) ; then
	systemctl stop PolarProxy.service
fi

if (systemctl is-active inspircd.service &>/dev/null) ; then
	systemctl stop inspircd.service
fi
