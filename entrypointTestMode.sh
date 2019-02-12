#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail


isZip=$1
isJar=$2

cd "${MY_VOLUME}"
mkdir "${MY_VOLUME}/logs/" || true
latest="${MY_VOLUME}/logs/latest.log"
touch "$latest" || true
#run and pipe output
if [ "$isZip" = "true" ]; then
	chmod +x ServerStart.sh
	./ServerStart.sh &
	echo "[entrypointTestMode][INFO]process started, waiting on jar"

	running=true
	counter=0
	timeout=60
	echo "[entrypointTestMode][TRACE]Waiting on jar loop starting"
	while [ "$running" = "true" ]; do
		counter=$((counter+1))
		
		fileExisting=$(if [ "$(find . -maxdepth 1 -type f -iname 'minecraft_server*.jar' | wc -l)" != 0 ]; then echo true; else echo false; fi )
		wgetRunning=$(if [ "$( (pidof wget || echo "") | wc -w)" != 0 ]; then echo true; else echo false; fi )

		if [ "$fileExisting" = "true" ] && [ "$wgetRunning" = "false" ]; then
			running=false
			echo "[entrypointTestMode][INFO]looks like the jar download is fine..."

		elif [ $counter -gt $timeout ]; then
			running=false
			echo "[entrypointTestMode][ERROR]timout"
			exit 1
		else
			sleep 1s
		fi
	done
	echo "[entrypointTestMode][TRACE]Waiting on jar loop ended"
	
elif [ "$isJar" = "true" ]; then
	#TODO unsafe
	# shellcheck disable=SC2086
	java $JAVA_PARAMETERS -jar "${MY_FILE}" &
else
	echo "[entrypointTestMode][ERROR]unexpected file type [5]"
	exit 2
fi
	
#until not found
foundLogEntry=false
running=true

counter=0
timeout=300
echo "[entrypointTestMode][TRACE]Run server loop starting"

while [ "$running" = "true" ]; do
	counter=$((counter+1))
	echo "[entrypointTestMode][TRACE]Run server loop $counter"

	# Vanilla
	logLinesServerDone="0"
	if [ -e "$latest" ]; then
		echo "[entrypointTestMode][TRACE]$latest exists"
		set +o errexit
		# shellcheck disable=SC2002
		logLinesServerDone=$(grep -Ec -e ':\s*Done\s*\([0-9.]+\w?\)!' "$latest")
		set -o errexit
	else
		echo "[entrypointTestMode][TRACE]$latest NOT exists"
	fi
	echo "[entrypointTestMode][TRACE]Found log entries: $logLinesServerDone"
	
	processesRunning=$( (pidof 'java' || echo "") | wc -w )
	echo "[entrypointTestMode][TRACE]Found java processes $processesRunning"
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
echo "[entrypointTestMode][TRACE] loop ending"

if [ "$foundLogEntry" = "true" ]; then
	echo "[entrypointTestMode][INFO]Test ok! Needed sleeps: ${counter}/${timeout}"
	pkill -15 'java'
	exit 0
	
elif [ $counter -gt $timeout ]; then
	echo "[entrypointTestMode][ERROR]Test failed, timeout reached."
	pkill -15 'java'
	exit 4
	
else
	echo "[entrypointTestMode][ERROR]Test failed, process closed before done"
	exit 3
fi
