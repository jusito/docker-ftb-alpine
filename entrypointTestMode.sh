#!/bin/sh

set -e
isZip=$1
isJar=$2

cd "${MY_VOLUME}"
mkdir "${MY_VOLUME}/logs/" || true
latest="${MY_VOLUME}/logs/latest.log"
touch "$latest" || true
#run and pipe output
if [ "$isZip" == "true" ]; then
	chmod +x ServerStart.sh
	./ServerStart.sh &
	echo "process started, waiting on jar"
	
	running=true
	counter=0
	timeout=60
	found=false
	while [ "$running" == true ]; do
		counter=$((counter+1))
		
		if [ $(ls *.jar | grep -F 'minecraft_server' | wc -w) != 0 ]; then
			running=false
			found=true
			echo "jar found, sleep..."
			sleep 10s
			echo "... sleep ended"
		elif [ $counter -gt $timeout ]; then
			running=false
			found=false
			echo "timout"
			exit 1
		else
			sleep 1s
		fi
	done
	
elif [ "$isJar" == "true" ]; then
	java $JAVA_PARAMETERS -jar "${MY_FILE}" &
else
	echo "ERROR BUG unexpected file type [5]"
	exit 2
fi
	
#until not found
foundLogEntry=false
processExists=true
running=true

counter=0
timeout=120
while [ "$running" == true ]; do
	# Vanilla
	if [ $(grep -F "[Server thread/INFO]: Done" "$latest" | wc -l) -ge 1 ]; then
		foundLogEntry=true
		running=false
			
	#if process is closed before we find our entry, failed!
	elif [ $(ps -ef | grep "java" | grep -v 'grep' | wc -l) -lt "1" ]; then
		processExists=false
		running=false
	fi
		
	sleep 1s
	counter=$((counter+1))
	
	if [ $counter -gt $timeout ]; then
		running=false
	fi
done

if [ $processExists == false ]; then
	echo "Test failed, process closed before done"
	exit 3
elif [ $counter -gt $timeout ]; then
	echo "Test failed, timeout reached."
	pkill -15 'java'
	exit 4
else
	echo "Test ok!"
	pkill -15 'java'
	exit 0
fi
