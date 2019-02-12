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
debug=$1

host=$HEALTH_URL
port=$HEALTH_PORT
# userdefined port?
if [ -z "$port" ]; then
	debugMsg "[checkHealth][DEBUG]no HEALTH_PORT given"
	#try to find in props
	port=$(grep -Eio -e 'server-port=.+' "$PROPERTIES" | grep -o -e '[^=]*$')
	#if not in, its default
	if [ -z "$port" ]; then
		debugMsg "[checkHealth][DEBUG]couldn't extract server port from $PROPERTIES, fallback to default"
		port=25565
	else
		debugMsg "[checkHealth][DEBUG]could extract server port: $port"
	fi
else
	debugMsg "[checkHealth][DEBUG]HEALTH_PORT given"
fi
set -e

# process host
hostHex=$(stringToHex "$host")
hostLength=$(getLength $host)
hostLengthHex=$(intToHex $hostLength)
debugMsg "[checkHealth][DEBUG]Host: $host($hostLength = $hostLengthHex) = $hostHex"

# process port
portHex=$(intToHex $port)
debugMsg "[checkHealth][DEBUG]Port: $port = $portHex"

# create handshake
handshake="\x00\x04${hostLengthHex}${hostHex}${portHex}\x01"
handshakeLength=$(getLength "$handshake") # side effect, hex->byte before count
handshakeLengthHex=$(intToHex $handshakeLength)
debugMsg "[checkHealth][DEBUG]Handshake: $handshake($handshakeLength = $handshakeLengthHex)"

# create request
request="${handshakeLengthHex}${handshake}\x01\x00"
echo "[checkHealth][INFO]Request: $request"

set -e
# convert request, send, binary-to-text
recv=$(echo -e "${request}" | nc  "$host" "$port" | od -a -A n | tr -d '\n ')
debugMsg $(echo -e "${request}" || echo $?)
debugMsg $(echo -e "${request}" | wc -c)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" || echo $?)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" | wc -c)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" | od -a -A n || echo $?)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" | od -a -A n | wc -c)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" | od -a -A n | tr -d '\n ' || echo $?)
debugMsg $(echo -e "${request}" | nc -v "$host" "$port" | od -a -A n | tr -d '\n ' | wc -c)
debugMsg "$recv"

# check
if [ $(echo "$recv" | grep -Fo '"players":' | wc -c) != "0" ]; then
	echo "[checkHealth][INFO]Status valid"
	exit 0
else
	echo "[checkHealth][ERROR]Status invalid"
	exit 1
fi