#!/bin/sh

set -e

# define functions
doBackup() {
	file=$1
	cd "$MY_VOLUME"
	
	if [ ! -n "$file" ]; then
		echo "can't backup empty filename"
	elif [ ! -e "$file" ]; then
		echo "can't backup file which doesn't exists: $file"
	else
		mv -fv "$file" "${MY_HOME}/$file"
	fi
}

doRestore() {
	file=$1
	cd "$MY_VOLUME"
	
	if [ ! -n "$file" ]; then
		echo "can't restore empty filename"
	elif [ ! -e "${MY_HOME}/$file" ]; then
		echo "can't restore file which doesn't exists: ${MY_HOME}/$file"
	else
		mv -fv "${MY_HOME}/$file" "$file"
	fi
}


# main processing:

#backup files
doBackup "server.properties"
doBackup "banned-ips.json"
doBackup "banned-players.json"
doBackup "ops.json"
doBackup "usercache.json"
doBackup "usernamecache.json"
doBackup "whitelist.json"
doBackup "config.sh"

# copy zip into dir
cp -f "${MY_HOME}/${MY_FILE}" "${MY_VOLUME}/${MY_FILE}"

# set workdir to volume
cd "${MY_VOLUME}"

# unzip server files
unzip -q -o "${MY_FILE}"

# delete copied zip
rm -f "${MY_FILE}"

# set eula = accepted
if [ -e 'eula.txt' ]; then
	sed -i 's/eula=false/eula=true/g' 'eula.txt'
else
	echo 'eula=true' > 'eula.txt'
fi

#restore files
doRestore "server.properties"
doRestore "banned-ips.json"
doRestore "banned-players.json"
doRestore "ops.json"
doRestore "usercache.json"
doRestore "usernamecache.json"
doRestore "whitelist.json"
doRestore "config.sh"

#apply custom config
if [ -e "config.sh" ]; then
	sh config.sh
fi

#register SIGTERM trap => exit server securely
trap 'pkill -15 java' SIGTERM
	
# execute server
chmod +x ServerStart.sh
./ServerStart.sh "$@" &
wait "$!"