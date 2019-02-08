#!/bin/sh

#thanks @ 
# jamietech@github: https://github.com/jamietech/MinecraftServerPing
# Valiano@stackoverflow: https://stackoverflow.com/questions/54572688/different-behaviour-of-grep-with-pipe-from-nc-on-alpine-vs-ubuntu

function debugMsg() {
	if [ -n "$debug" ]; then
		echo "$1"
	fi	
}

# Get length of first arg
function getLength() {
	# echo without \n, count 
	echo -e "$1\c" | wc -c
}

function intToHex() {
	# int to hex,, separate bytes 2 each line, add at beginning \x, delete whitespaces, delete \x\n or \n
	echo "16o $1 p" | dc | od -w2 -c -A n | sed 's/^/\\x/' | tr -d '\n ' | sed -E 's/(\\x)?\\n//'
}

function stringToHex() {
	# expand to 1 byte and dont show offset,, insert \x before, strip \x\n
	echo "$1" | od -t x1 -A n | sed 's/ /\\x/g' | sed 's/....$//g'
}

# find server properties
PROPERTIES="${MY_HOME}/"$(ls "$MY_HOME" | grep -io -e 'server.properties')

### MAIN:
## input
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

# process host
hostHex=$(stringToHex "$host")
hostLength=$(getLength $host)
hostLengthHex=$(intToHex $hostLength)
debugMsg "Host: $host($hostLength = $hostLengthHex) = $hostHex"

# process port
portHex=$(intToHex $port)
debugMsg "Port: $port = $portHex"

# create handshake
handshake="\x00\x04${hostLengthHex}${hostHex}${portHex}\x01"
handshakeLength=$(getLength "$handshake") # side effect, hex->byte before count
handshakeLengthHex=$(intToHex $handshakeLength)
debugMsg "Handshake: $handshake($handshakeLength = $handshakeLengthHex)"

# create request
request="${handshakeLengthHex}${handshake}\x01\x00"
echo "Request: $request"

set -e
# convert request, send, binary-to-text, check
echo -e "${request}" | nc  "$host" "$port" | od -a -A n | tr -d '\n ' | grep -q '"players"'
