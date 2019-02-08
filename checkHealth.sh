#!/bin/sh

#thanks @ 
# https://github.com/jamietech/MinecraftServerPing
# https://unix.stackexchange.com/questions/92447/bash-script-to-get-ascii-values-for-alphabet

# find server properties
PROPERTIES="${MY_HOME}/"$(ls "$MY_HOME" | grep -io -e 'server.properties')

### input
set +e
host=$HEALTH_URL
port=$HEALTH_PORT
# userdefined port?
if [ -z "$port" ]; then
	#try to find in props
	port=$(grep -Eio -e 'server-port=.+' "$PROPERTIES" | grep -o -e '[^=]*$')
	#if not in, its default
	if [ -z "$port" ]; then
		port=25565
	fi
fi

debug=$1
set -e


# ASCII to Character
function chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

# Character to ASCII
function ord() {
  printf '%d' "'$1"
}

# Get length of first arg
function getLength() {
	local in=$1
	local mode=$2
	
	local temp=$(echo "$in" | wc -m)
	if [ -n "$mode" ]; then
		temp=$((temp - 1))
	fi
	
	echo $temp
}

function intToHex() {
	local in="$1"
	local ret=""
	
	local hex=$(echo "16o $in p" | dc)
	local length=$(getLength $hex)
	
	for next in $(echo "$hex" | grep -Eo '[a-zA-Z0-9]{2}|[a-zA-Z0-9]')
	do	
		if [ "$(getLength $next nullTerminated)" == "1" ]; then
			next="0$next"
		fi
		ret="$ret\x${next}"
	done
	
	echo "$ret"
}

function stringToHex() {
	# expand to 1 byte and dont show offset, insert \x before, strip null terminate(string)
	echo "$1" | od -t x1 -A n | sed 's/ /\\x/g' | sed 's/....$//g'
}

### MAIN:
# process host
hostHex=$(stringToHex "$host")
hostLength=$(getLength $host true)
hostLengthHex=$(intToHex $hostLength)
if [ -n "$debug" ]; then
	echo "Host: $host($hostLength = $hostLengthHex) = $hostHex"
fi

# process port
portHex=$(intToHex $port)
if [ -n "$debug" ]; then
	echo "Port: $port = $portHex"
fi

# create handshake
handshake="\x00\x04${hostLengthHex}${hostHex}${portHex}\x01"
handshakeLength=$(getLength "$handshake")
handshakeLength=$((handshakeLength / 4))
handshakeLengthHex=$(intToHex $handshakeLength)
if [ -n "$debug" ]; then
	echo "Handshake: $handshake($handshakeLength = $handshakeLengthHex)"
fi

# create request
request="${handshakeLengthHex}${handshake}\x01\x00"
echo "Request1: $request"

set -e
# convert request, send, binary-to-text, check
echo -e "${request}" | nc  "$host" "$port" | od -a -A n | tr -d '\n ' | grep -q '"players"'
