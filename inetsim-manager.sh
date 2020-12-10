#! /bin/bash

CWD=$"/lab/tools/inetsim/engine/inetsim"
NOW=$(date +"%Y%m%d%H%M%S")
REPORT="/lab/data"
CONFIG="/lab/tools/inetsim/inetsim-"

function service_manager () {
    local value_action=$1
    local value_service=$2
	local value_service_config_path="$CONFIG$value_service"
	service_status
	local status=$?
    case $value_action in
        "--start") 
            if [[ "$#" -gt 1 ]]; then
				if [ $status -eq 0 ] ; then
					printf "START : INetSim [$value_service] network simulation service...\n"
					tilix -e pkexec "$CWD/inetsim-$value_service-start.sh" "$value_service_config_path/data" "$value_service_config_path/inetsim.conf" "$REPORT" "malwarenet-network-inetsim-$value_service-log_$NOW"
					while [ $(ps aux | grep "[i]netsim_main" | wc -l) -eq 0 ]
					do
						printf "Waiting for INetSim to run...\n"
						sleep 5
					done
					case $value_service in
						"burp")
							printf "ATTENTION: Burp does not decrypt data, pcap file will not be created...\n"
							if [[ $(ps aux | grep "[b]urpsuite_community.jar" | wc -l) -eq 0 ]] ; then
								sh /lab/tools/burp/BurpSuiteCommunity --config-file=/lab/tools/burp/burp-analysis-w7-32b-8443-7443.json &
							fi
					    ;;
						"polarproxy")
							datastream="$REPORT/datastream.malwarenet-network-inetsim-$value_service-decrypted_$NOW.pcap"
							touch "$datastream"
							printf "Streaming decrypted session data to pcap file: $datastream\n"
							if [[ $(ps aux | grep "[n]c localhost 57012" | wc -l) -eq 0 ]] ; then
								nc localhost 57012 > "$datastream" &

								# Wireshark <- data from pipe
								#tail -f -c +0 "$datastream" | wireshark -k -i - &
							fi
					    ;;
						*) 
							printf "*** ERROR: - Undefined Start [value_service] _value_: \"$value_service\", exiting...\n" 
							exit 127
						;;
					esac
				else
					$0 "--status"
				fi
            else
                printf "*** ERROR: - Missing Start parameter, exiting...\n" 
				exit 127
            fi
        ;;
        "--stop") 
			if [ $status -gt 0 ] ; then
				printf "STOP : "
				if [ $status -eq 1 ] ; then
					printf "INetSim [polarproxy] shutdown...\n"
					pkexec "$CWD/inetsim-polarproxy-stop.sh"
				elif [ $status -eq 2 ] ; then
					printf "INetSim [burp] shutdown...\n"
					pkexec "$CWD/inetsim-burp-stop.sh"
				fi
			else
				printf "Network simulation service is not running...\n"
			fi
        ;;
        *) 
            printf "*** ERROR: - Undefined [service_manager] _value_: \"$value_action\", exiting...\n" 
			exit 127
        ;;
    esac
}

function service_status () {
	local status=""
	if [[ $(ps aux | grep "[i]netsim_main" | wc -l) -eq 1 ]] ; then
		if (systemctl is-active PolarProxy.service &>/dev/null) ; then
			status=1
		else
			status=2
		fi
	else
		status=0
	fi
	return $status
}

# Main
# ------------------------------

function main () {
    case $action in
        "--start")
            service_manager $action $parameters
        ;;
        "--stop")
            service_manager $action
        ;;
        "--status")
            service_status
			local status=$?
			local message=""
			if [ $status -eq 1 ] ; then
				message="* INetSim [polarproxy] network simulation service is running..."
			elif [ $status -eq 2 ] ; then
				message="* INetSim [burp] network simulation service is running..."
			elif [ $status -eq 0 ] ; then
				message="* Network simulation service not running..."
			else
				printf "*** ERROR: - Undefined INetSim [status] _value_: \"$status\", exiting...\n"
				exit 127
			fi
			printf "$message\n"
        ;;
        *)
            printf "$0 - Option \"$action\" was not recognized...\n"
            printf "\n  * Operations:\n"
            printf "    --start [ burp | polarproxy ] : Start network service\n"
            printf "    --stop                        : Stop network service\n"
            printf "    --status                      : Get network service status\n\n"
			exit 127
        ;;
    esac
}

action=$1
parameters=${*: 2}

main $action $parameters
