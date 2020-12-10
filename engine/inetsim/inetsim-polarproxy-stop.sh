#! /bin/bash

kill $(ps aux | grep "[i]netsim_main" | awk '{ print $2 }')

if [[ $(ps aux | grep "[n]c localhost 57012" | wc -l) -eq 1 ]] ; then
	kill $(ps aux | grep "[n]c localhost 57012" | awk '{ print $2 }')
fi

# IRC
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 6667 -j REDIRECT --to-port 16667
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 6668 -j REDIRECT --to-port 16667
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 6669 -j REDIRECT --to-port 16667

# https           443/tcp         http protocol over TLS/SSL
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 10443 

# smtps           465/tcp         smtp protocol over TLS/SSL 
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 465 -j REDIRECT --to-port 10465

# imaps           993/tcp         imap4 protocol over TLS/SSL
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 993 -j REDIRECT --to-port 10993

# pop3s           995/tcp         pop3 protocol over TLS/SSL
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 995 -j REDIRECT --to-port 10995

# ftps            990/tcp         ftp, control, over TLS/SSL
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 990 -j REDIRECT --to-port 10990

# ALL OTHER TRAFFIC
iptables -t nat -D PREROUTING -i eth1 -j REDIRECT

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
