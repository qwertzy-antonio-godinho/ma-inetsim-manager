#! /bin/bash

function main () {
	local value_data="$1"
	local value_conf="$2"
	local value_report="$3"
	local value_session="$4"

	# IRC
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 6667 -j REDIRECT --to-port 16667
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 6668 -j REDIRECT --to-port 16667
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 6669 -j REDIRECT --to-port 16667

	# https           443/tcp         http protocol over TLS/SSL
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to-port 10443 

	# smtps           465/tcp         smtp protocol over TLS/SSL 
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 465 -j REDIRECT --to-port 10465

	# imaps           993/tcp         imap4 protocol over TLS/SSL
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 993 -j REDIRECT --to-port 10993
	
	# pop3s           995/tcp         pop3 protocol over TLS/SSL
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 995 -j REDIRECT --to-port 10995

	# ftps            990/tcp         ftp, control, over TLS/SSL
	iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 990 -j REDIRECT --to-port 10990

	# ALL OTHER TRAFFIC
	iptables -t nat -A PREROUTING -i enp0s8 -j REDIRECT

	if (systemctl is-active ntp.service &>/dev/null) ; then
		systemctl stop ntp.service
	fi

	if (systemctl is-active systemd-resolved.service &>/dev/null) ; then
		systemctl stop systemd-resolved.service
	fi

	if ! (systemctl is-active PolarProxy.service &>/dev/null) ; then
		systemctl start PolarProxy.service
	fi

	if ! (systemctl is-active inspircd.service &>/dev/null) ; then
		systemctl start inspircd.service
	fi

	inetsim --data "$value_data" --conf "$value_conf" --report-dir "$value_report" --session "$value_session"
}

data="$1"
conf="$2"
report="$3"
session="$4"

main "$data" "$conf" "$report" "$session"
