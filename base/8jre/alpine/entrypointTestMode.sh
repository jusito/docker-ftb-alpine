#!/bin/sh

if [ "${DEBUGGING:?}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
#set -o pipefail

TRACE=false

traceMsg() {
	if [ "$TRACE" = "true" ]; then
		echo "[entrypointTestMode][TRACE] $1"	
	fi
}

cd "${MY_VOLUME}"
mkdir "${MY_VOLUME}/logs/" || true
latest="${MY_VOLUME}/logs/latest.log"
touch "$latest" || true
	
#until not found
foundLogEntry=false
running=true

counter=0
timeout="${STARTUP_TIMEOUT:?}"
traceMsg "Run server loop starting"

while [ "$running" = "true" ]; do
	counter=$(( counter + 1 ))
	traceMsg "Run server loop $counter"

	# Vanilla
	logLinesServerDone="0"
	if [ -e "$latest" ]; then
		traceMsg "$latest exists"
		set +o errexit
		# shellcheck disable=SC2002
		logLinesServerDone=$(grep -Ec -e ':\s*Done\s*\([0-9.]+\w?\)!' "$latest")
		set -o errexit
	else
		traceMsg "$latest NOT exists"
	fi
	traceMsg "Found log entries: $logLinesServerDone"
	
	processesRunning=$( (pidof 'java' || echo "") | wc -w )
	traceMsg "Found java processes $processesRunning"
	if [ "$processesRunning" -lt 1 ]; then
		running=false
		
	elif [ "$logLinesServerDone" -ge 1 ]; then
		foundLogEntry=true
		running=false
	
	elif [ "$counter" -gt "$timeout" ]; then
		running=false
		
	else
		sleep 1s
	fi
done
traceMsg "loop ending"

if [ "$foundLogEntry" = "true" ]; then
	echo "[entrypointTestMode][INFO]Test ok! Needed sleeps: ${counter}/${timeout}"
	query stop
	#kill -15 "$(pidof java)"
	exit 0
	
elif [ "$counter" -gt "$timeout" ]; then
	echo "[entrypointTestMode][ERROR]Test failed, timeout reached."
	kill -15 "$(pidof java)"
	exit 4
	
else
	echo "[entrypointTestMode][ERROR]Test failed, process closed before done"
	exit 3
fi
