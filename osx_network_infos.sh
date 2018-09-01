#!/bin/bash

services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')

while read line; do
    sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    #echo "Current service: $sname, $sdev, $currentservice"
    if [ -n "$sdev" ]; then
        ifout="$(ifconfig $sdev 2>/dev/null)"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            currentservice="$sname"
            currentdevice="$sdev"
            currentmac=$(echo "$ifout" | awk '/ether/{print $2}')
        fi
    fi
done <<< "$(echo "$services")"

if [ -n "$currentservice" ]; then
    echo "Current network device: $currentservice"
    #echo $currentdevice
    echo "MacAddress: $currentmac"

    # ---
	# Get Gateway ip
	# ---

	# Find the info
	#ipconfig getpacket en1 | grep server_identifier
	#ipconfig getpacket en1 | grep router

	# Grep the ip
	#grep -Eo '[0-9]{3}\.[0-9]{3}\.[0-9]{1}\.[0-9]{1,3}'

	# All together
	gateway_ip=$(ipconfig getpacket $currentdevice | grep router | cut -d ":" -f2 | grep -Eo '[0-9]{3}\.[0-9]{3}\.[0-9]{1}\.[0-9]{1,3}')
	echo "Gateway ip: $gateway_ip"

	# ---
	# Get Local ip
	# ---
	local_ip=$(ipconfig getifaddr $currentdevice)
	echo "LAN ip: $local_ip"

	# ---
	# Get MacAddress
	# ---
	#mac_address=$(ipconfig getpacket $currentdevice | grep chaddr | cut -d "=" -f2 | sed -e 's/^[ \t]*//') 
	#echo "MacAddress: $mac_address"

	# ---
	# Get Public ip
	# ---
	public_ip=$(curl -s ipinfo.io/ip)
	echo "WAN(public) ip: $public_ip"

else
    >&2 echo "Could not find current service"
    exit 1
fi