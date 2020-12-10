#! /bin/bash

function main () {
	local value_data="$1"
	local value_conf="$2"
	local value_report="$3"
	local value_session="$4"

	# IRC
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 6667 -j REDIRECT --to-port 16667
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 6668 -j REDIRECT --to-port 16667
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 6669 -j REDIRECT --to-port 16667

	# HTTPS
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 8443

	# SMTP
	iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 465 -j REDIRECT --to-port 8465

	# ALL OTHER TRAFFIC
	iptables -t nat -A PREROUTING -i eth1 -j REDIRECT

	if (systemctl is-active ntp.service &>/dev/null) ; then
		systemctl stop ntp.service
	fi

	if (systemctl is-active systemd-resolved.service &>/dev/null) ; then
		systemctl stop systemd-resolved.service
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
