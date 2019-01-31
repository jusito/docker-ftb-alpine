#!/bin/sh

set -e

# get arguments
export MY_SERVER=$1
export MY_MD5=$2

# define functions
download() {
	target=$1
	source=$2
	md5=$3
	
	wget -O "${MY_FILE}" "${MY_SERVER}"
	echo "${MY_MD5}  ${MY_FILE}" | md5sum -s -c -
}

doBackup() {
	file=$1
	cd "${MY_VOLUME}"

	if [ ! -n "$file" ]; then
		echo "can't backup empty filename"
	elif [ ! -e "$file" ]; then
		echo "can't backup file which doesn't exists: $file"
	else
		mv -fv "$file" "/home/$file"
	fi
}

doRestore() {
	file=$1
	cd "${MY_VOLUME}"
	
	if [ ! -n "$file" ]; then
		echo "can't restore empty filename"
	elif [ ! -e "/home/$file" ]; then
		echo "can't restore file which doesn't exists: /home/$file"
	else
		mv -fv "/home/$file" "$file"
	fi
}

writeServerProperty() {
	name="$1"
	value="$2"
	pattern="$3"
	default="$4"
	target="${MY_VOLUME}/server.properties"
	
	set +e
	echo "$value" | grep -Eiq "$pattern"
	error=$?
	set -e
	if [ "1" == "$error" ]; then
		echo "illegal value($value) for $name, fallback to ($default), used regex pattern $pattern"
		value="$default"
	fi
	
	if [ "$value" == "$default" ]; then
		echo "Property: $name=$value (Default)"
	else
		echo "Property: $name=$value"
	fi
	echo "$name=$value" >> "$target"
}

writeServerProperties() {
	
	# prepare server.properties
	target="${MY_VOLUME}/server.properties"
	if [ -e "${target}" ]; then
		rm "${target}"
	fi
	touch "$target"
	
	# define const
	patternBoolean="^(true|false)$"
	
	# write properties
	writeServerProperty "allow-flight" "${allow_flight}" "$patternBoolean" "false"
	writeServerProperty "allow-nether" "${allow_nether}" "$patternBoolean" "true"
	writeServerProperty "broadcast-console-to-ops" "${broadcast_console_to_ops}" "$patternBoolean" "true"
	writeServerProperty "difficulty" "${difficulty}" "^[0-3]$" "1"
	writeServerProperty "enable-query" "${enable_query}" "$patternBoolean" "false"
	writeServerProperty "enable-rcon" "${enable_rcon}" "$patternBoolean" "false"
	writeServerProperty "enable-command-block" "${enable_command_block}" "$patternBoolean" "false"
	writeServerProperty "enforce-whitelist" "${enforce_whitelist}" "$patternBoolean" "false"
	writeServerProperty "force-gamemode" "${force_gamemode}" "$patternBoolean" "false"
	writeServerProperty "gamemode" "${gamemode}" "^[0-3]$" "0"
	writeServerProperty "generate-structures" "${generate_structures}" "$patternBoolean" "true"
	writeServerProperty "generator-settings" "${generator_settings}" "^.*$" "" #if user is setting this, he knows what he does
	writeServerProperty "hardcore" "${hardcore}" "$patternBoolean" "false"
	writeServerProperty "level-name" "${level_name}" "^[a-zA-Z0-9]([ a-zA-Z0-9]*[a-zA-Z0-9])?$" "world"
	writeServerProperty "level-seed" "${level_seed}" "^.*$" ""
	writeServerProperty "level-type" "${level_type}" "^(DEFAULT|FLAT|LARGEBIOMES|AMPLIFIED|BUFFET)$" "DEFAULT"
	writeServerProperty "max-build-height" "${max_build_height}" "^\d+$" "256"
	writeServerProperty "max-players" "${max_players}" "^[1-9][0-9]*$" "20"
	writeServerProperty "max-tick-time" "${max_tick_time}" "^\d+$" "60000" #yes 0 is allowed
	writeServerProperty "max-world-size" "${max_world_size}" "^\d+$" "29999984"
	writeServerProperty "motd" "${motd}" "^.*$" "A Minecraft Server"
	writeServerProperty "network-compression-threshold" "${network_compression_threshold}" "^\d+$" "256"
	writeServerProperty "online-mode" "${online_mode}" "$patternBoolean" "true"
	writeServerProperty "op-permission-level" "${op_permission_level}" "^[1-4]$" "4"
	writeServerProperty "player-idle-timeout" "${player_idle_timeout}" "^\d+$" "0"
	writeServerProperty "prevent-proxy-connections" "${prevent_proxy_connections}" "$patternBoolean" "false"
	writeServerProperty "pvp" "${pvp}" "$patternBoolean" "true"
	writeServerProperty "query.port" "${query_port}" "^[1-9][0-9]*$" "25565"
	writeServerProperty "rcon.password" "${rcon_password}" "^.*$" ""
	writeServerProperty "rcon.port" "${rcon_port}" "^[1-9][0-9]*$" "25575"
	writeServerProperty "resource-pack" "${resource_pack}" "^.*$" ""
	writeServerProperty "resource-pack-sha1" "${resource_pack_sha1}" "^.*$" "" #TODO correct pattern
	writeServerProperty "server-ip" "${server_ip}" "^.*$" "" #TODO correct pattern
	writeServerProperty "server-port" "${server_port}" "^[1-9][0-9]*$" "25565"
	writeServerProperty "snooper-enabled" "${snooper_enabled}" "$patternBoolean" "true"
	writeServerProperty "spawn-animals" "${spawn_animals}" "$patternBoolean" "true"
	writeServerProperty "spawn-monsters" "${spawn_monsters}" "$patternBoolean" "true"
	writeServerProperty "spawn-npcs" "${spawn_npcs}" "$patternBoolean" "true"
	writeServerProperty "spawn-protection" "${spawn_protection}" "^\d+$" "16"
	writeServerProperty "view-distance" "${view_distance}" "^([3-9]|1[0-5])$" "10"
	writeServerProperty "white-list" "${white_list}" "$patternBoolean" "false"
}

writeJVMArguments() {
	if [ -n "${JAVA_PARAMETERS}" ]; then
		echo "found custom jvm args (${JAVA_PARAMETERS})"
		if [ -e "${MY_VOLUME}/ServerStart.sh" ]; then
			echo "ServerStart.sh file found"

			startup=$(cat "${MY_VOLUME}/ServerStart.sh" | grep -Eoi -e '"\$JAVACMD" -server .+')
			startupEnd=$(echo "${startup}" | grep -Eoi -e '-jar .+')
			replaceStart='"$JAVACMD" -server '
			sed -i "s/${startup}/${replaceStart} ${JAVA_PARAMETERS} ${startupEnd}/g" "${MY_VOLUME}/ServerStart.sh"
		else
			echo "ServerStart.sh file NOT found"
		fi
		
	else
		echo "found NO custom jvm args"
	fi	
}
# set workdir to volume
cd "${MY_VOLUME}"

# main processing:
download "${MY_FILE}" "${MY_SERVER}" "${MY_MD5}"

#backup files
doBackup "server.properties"
doBackup "banned-ips.json"
doBackup "banned-players.json"
doBackup "ops.json"
doBackup "usercache.json"
doBackup "usernamecache.json"
doBackup "whitelist.json"
doBackup "config.sh"

# unzip server files
unzip -q -o "${MY_FILE}"
echo "server files extracted"

# delete copied zip
rm -f "${MY_FILE}"

# set eula = accepted
if [ -e 'eula.txt' ]; then
	sed -i 's/eula=false/eula=true/g' 'eula.txt'
else
	echo 'eula=true' > 'eula.txt'
fi
echo "eula accepted"

#restore files
doRestore "server.properties"
doRestore "banned-ips.json"
doRestore "banned-players.json"
doRestore "ops.json"
doRestore "usercache.json"
doRestore "usernamecache.json"
doRestore "whitelist.json"
doRestore "config.sh"

## apply config
writeServerProperties
writeJVMArguments
if [ -e "config.sh" ]; then
	sh config.sh
fi

#register SIGTERM trap => exit server securely
trap 'pkill -15 java' SIGTERM
	
# execute server
chmod +x ServerStart.sh
./ServerStart.sh &
wait "$!"