#!/bin/bash

select_network() {
	networksOptions=()
	while read -r line; do
		networkOptions+=("$line")
	done < <(nmcli device wifi list) #use nmcli command output as the loop input
	PS3="Which entreprise WPA2 network would you like to connect to ?: "
	select network in "${networkOptions[@]:1}"; do
		read -r -a network_array <<<"$network"         #convert network string to an array
		echo "${network_array[0]} ${network_array[1]}" #return the ssid and bssid
		break
	done
}

create_selected_network_config() {
	local ssid_bssid=$(select_network)
	ssid_bssid_array=($ssid_bssid)
	bssid="${ssid_bssid_array[0]}"
	ssid="${ssid_bssid_array[1]}"

	read -r -p "Username for ${ssid}: " username
	read -r -p "Password for ${ssid}: " password

	NETWORK_CONFIG_NAME="$ssid.nmconnection"
	NETWORK_CONFIG_CONTENT="[wifi-security]
key-mgmt=wpa-eap

[connection]
id="$bssid"
uuid=$(uuidgen)
type=wifi

[ipv6]
method=auto

[wifi]
ssid="$ssid"
mode=infrastructure
security=802-11-wireless-security

[802-1x]
eap=peap
identity=$username
phase2-auth=mschapv2
password=$password

[ipv4]
method=auto"

	NETWORK_CONFIG_PATH="/etc/NetworkManager/system-connections/$NETWORK_CONFIG_NAME"
	echo "$NETWORK_CONFIG_CONTENT" >"$NETWORK_CONFIG_PATH"
	chown root "$NETWORK_CONFIG_PATH"
	chmod 600 "$NETWORK_CONFIG_PATH"
	echo "Created"
}

create_selected_network_config
