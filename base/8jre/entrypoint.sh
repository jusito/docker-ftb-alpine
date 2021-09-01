#!/bin/sh

if [ "${DEBUGGING:?}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
#set -o pipefail

# get arguments
cacheOnly=$3
set -o nounset #3 not always given
export MY_SERVER=$1
export MY_MD5=$2

# set local vars
FORGE_INSTALLER="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}-installer.jar"
FORGE_INSTALLER_LEGACY="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}-${MINECRAFT_VERSION}-installer.jar"
FORGE_JAR="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}*.jar"
FORGE_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${FORGE_VERSION}/${FORGE_INSTALLER}"
FORGE_URL_LEGACY="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${FORGE_VERSION}-${MINECRAFT_VERSION}/${FORGE_INSTALLER_LEGACY}"





#region functions
download() {
	# using env $FORCE_DOWNLOAD
	target=$1
	source=$2
	md5=$3
	skip="false"
	cache="/home/${MY_FILE}"
	
	# check if file already exists
	if [ -e "${cache}" ]; then
		echo "[entrypoint][INFO] found existing file ${cache}"
		
		# check md5
		md5current="$(md5sum "/home/$target" | grep -Eo -e '^\S+')"
		if [ "$md5current" = "$md5" ]; then 
			md5Matches="true"
		else
			md5Matches="false"
		fi
		
		# check user config
		if [ "$FORCE_DOWNLOAD" = "true" ]; then
			echo "[entrypoint][INFO] force reload activated"
			rm "$cache"
			skip="false"
			
		# check if md5 matches
		elif [ "$md5Matches" = "true" ]; then
			echo "[entrypoint][INFO] found existing file, no redownload: $md5"
			skip="true"
			
		# if md5 doesn't match
		else
			echo "[entrypoint][WARN] file doesn't match md5, redownloading: $md5"
			rm "$cache"
			skip="false"
		fi
	else
		echo "[entrypoint][INFO] found no cached download"
	fi
	
	if [ "$skip" = "false" ]; then
		echo "[entrypoint][INFO] downloading..."
		wget -O "$target" "$source"
		
		# check md5
		md5current="$(md5sum "$target" | grep -Eo -e '^\S+')"
		if [ "$md5current" = "$md5" ]; then 
			md5Matches="true"
		else
			md5Matches="false"
		fi

		if [ "$md5Matches" = "true" ]; then
			cp -vf "$target" "$cache"
			echo "[entrypoint][INFO] MD5 ok!"
		else
			rm -f "$target"
			echo "[entrypoint][ERROR] MD5 failed!"
			exit 5
		fi

	else
		echo "[entrypoint][INFO] download skipped, cp"
		cp -vf "${cache}" "$target"
	fi
}

doBackup() {
	file=$1
	cd "${MY_VOLUME}"

	if [ -z "$file" ]; then
		echo "[entrypoint][ERROR] can't backup empty filename"
	elif [ ! -e "$file" ]; then
		echo "[entrypoint][INFO] can't backup file which doesn't exists: $file"
	else
		mv -fv "$file" "/home/$file"
	fi
}

doRestore() {
	file=$1
	cd "${MY_VOLUME}"
	
	if [ -z "$file" ]; then
		echo "[entrypoint][ERROR] can't restore empty filename"
	elif [ ! -e "/home/$file" ]; then
		echo "[entrypoint][INFO] can't restore file which doesn't exists: /home/$file"
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
	if [ "1" = "$error" ]; then
		if [ "false" = "$IGNORE_PROPERTY_ERRORS" ]; then
			echo "[entrypoint][WARN] illegal value($value) for $name, fallback to ($default), used regex pattern $pattern"
			value="$default"
		else
			echo "[entrypoint][WARN] illegal value($value) for $name, fallback to ($default) disabled, used regex pattern $pattern"
		fi
	fi
	
	if [ "$value" = "$default" ]; then
		echo "[entrypoint][INFO] Property: $name=$value (Default)"
	else
		echo "[entrypoint][INFO] Property: $name=$value"
	fi
	echo "$name=$value" >> "$target"
}

writeServerProperties() {
	
	if [ "$OVERWRITE_PROPERTIES" = "true" ]; then
		echo "[entrypoint][INFO] OVERWRITE_PROPERTIES activated (default) overwriting properties."
		
		# prepare server.properties
		target="${MY_VOLUME}/server.properties"
		if [ -e "${target}" ]; then
			rm "${target}"
		fi
		touch "$target"
		
		# define const
		patternBoolean="^(true|false)$"
		
		# write properties
		writeServerProperty "allow-flight" "${allow_flight:?}" "$patternBoolean" "false"
		writeServerProperty "allow-nether" "${allow_nether:?}" "$patternBoolean" "true"
		writeServerProperty "broadcast-console-to-ops" "${broadcast_console_to_ops:?}" "$patternBoolean" "true"
		writeServerProperty "difficulty" "${difficulty:?}" "^([0-3]|peaceful|easy|normal|hard)$" "1"
		writeServerProperty "enable-command-block" "${enable_command_block:?}" "$patternBoolean" "false"
		writeServerProperty "enable-jmx-monitoring" "${enable_jmx_monitoring:?}" "$patternBoolean" "false"
		writeServerProperty "enable-query" "${enable_query:?}" "$patternBoolean" "false"
		writeServerProperty "enable-rcon" "${enable_rcon:?}" "$patternBoolean" "false"
		writeServerProperty "enable-status" "${enable_status:?}" "$patternBoolean" "true"
		writeServerProperty "entity-broadcast-range-percentage" "${entity_broadcast_range_percentage:?}" "^([0-9]|[1-9][0-9]|[1-4][0-9][0-9]|500)$" "100"
		writeServerProperty "enforce-whitelist" "${enforce_whitelist:?}" "$patternBoolean" "false"
		writeServerProperty "force-gamemode" "${force_gamemode:?}" "$patternBoolean" "false"
		writeServerProperty "function-permission-level" "${function_permission_level:?}" "^[1-4]$" "2"
		writeServerProperty "gamemode" "${gamemode:?}" "^([0-3]|survival|creative|adventure|spectator)$" "0"
		writeServerProperty "generate-structures" "${generate_structures:?}" "$patternBoolean" "true"
		# shellcheck disable=SC2154
		writeServerProperty "generator-settings" "${generator_settings}" "^.*$" "" #if user is setting this, he knows what he does
		writeServerProperty "hardcore" "${hardcore:?}" "$patternBoolean" "false"
		writeServerProperty "level-name" "${level_name:?}" "^[a-zA-Z0-9]([ a-zA-Z0-9]*[a-zA-Z0-9])?$" "world"
		# shellcheck disable=SC2154
		writeServerProperty "level-seed" "${level_seed}" "^.*$" ""
		writeServerProperty "level-type" "${level_type:?}" "^.+$" "DEFAULT" # not matching mod types: (DEFAULT|FLAT|LARGEBIOMES|AMPLIFIED|BUFFET)
		writeServerProperty "max-build-height" "${max_build_height:?}" "^[0-9]+$" "256"
		writeServerProperty "max-players" "${max_players:?}" "^[1-9][0-9]*$" "20"
		writeServerProperty "max-tick-time" "${max_tick_time:?}" "^(-1|[0-9]+)$" "60000"
		writeServerProperty "max-world-size" "${max_world_size:?}" "^[0-9]+$" "29999984"
		# shellcheck disable=SC2154
		writeServerProperty "motd" "${motd}" "^.*$" "A Minecraft Server"
		writeServerProperty "network-compression-threshold" "${network_compression_threshold:?}" "^(-1|[0-9]+)$" "256"
		writeServerProperty "online-mode" "${online_mode:?}" "$patternBoolean" "true"
		writeServerProperty "op-permission-level" "${op_permission_level:?}" "^[1-4]$" "4"
		writeServerProperty "player-idle-timeout" "${player_idle_timeout:?}" "^[0-9]+$" "0"
		writeServerProperty "prevent-proxy-connections" "${prevent_proxy_connections:?}" "$patternBoolean" "false"
		writeServerProperty "pvp" "${pvp:?}" "$patternBoolean" "true"
		writeServerProperty "query.port" "${query_port:?}" "^[1-9][0-9]*$" "25565"
		writeServerProperty "rate-limit" "${rate_limit:?}" "^[0-9]+$" ""
		# shellcheck disable=SC2154
		writeServerProperty "rcon.password" "${rcon_password}" "^.*$" ""
		writeServerProperty "rcon.port" "${rcon_port:?}" "^[1-9][0-9]*$" "25575"
		# shellcheck disable=SC2154
		writeServerProperty "resource-pack" "${resource_pack}" "^.*$" ""
		# shellcheck disable=SC2154
		writeServerProperty "resource-pack-sha1" "${resource_pack_sha1}" "^.*$" "" #TODO correct pattern
		# shellcheck disable=SC2154
		writeServerProperty "server-ip" "${server_ip}" "^.*$" "" #TODO correct pattern
		writeServerProperty "server-port" "${server_port:?}" "^[1-9][0-9]*$" "25565"
		writeServerProperty "snooper-enabled" "${snooper_enabled:?}" "$patternBoolean" "true"
		writeServerProperty "spawn-animals" "${spawn_animals:?}" "$patternBoolean" "true"
		writeServerProperty "spawn-monsters" "${spawn_monsters:?}" "$patternBoolean" "true"
		writeServerProperty "spawn-npcs" "${spawn_npcs:?}" "$patternBoolean" "true"
		writeServerProperty "spawn-protection" "${spawn_protection:?}" "^[0-9]+$" "16"
		writeServerProperty "sync-chunk-writes" "${sync_chunk_writes:?}" "$patternBoolean" "true"
		writeServerProperty "view-distance" "${view_distance:?}" "^([3-9]|1[0-5])$" "10"
		writeServerProperty "white-list" "${white_list:?}" "$patternBoolean" "false"
	else
		echo "[entrypoint][INFO]OVERWRITE_PROPERTIES deactivated, skipping properties."
	fi
}

writeOp() {
	if [ -z "$ADMIN_NAME" ]; then
		echo "[entrypoint][WARN] ADMIN_NAME unset, are you sure?"
	else
		echo "[entrypoint][INFO] ADMIN_NAME set, writing..."
		sh "/home/addOp.sh" "" "$ADMIN_NAME" "" ""
	fi
}

stopServer() {
	echo "[entrypoint][INFO] received SIGTERM"
	query stop
	wait "$(pidof java)"
	echo "[entrypoint][INFO] all java processes finished"
}
#region functions




#region main
# set workdir to volume
cd "${MY_VOLUME}"
download "${MY_FILE}" "${MY_SERVER}" "${MY_MD5}"
if [ "$cacheOnly" = "true" ]; then
	echo "[entrypoint][INFO] Cache only activated"
	rm "${MY_FILE}"
	exit 0
fi

# get file ending
fileEnding=$(echo "$MY_FILE" | grep -Eo -e '[^.]+$')
if [ "$fileEnding" = "zip" ]; then
	isZip="true"; isJar="false"

elif [ "$fileEnding" = "jar" ]; then
	isZip="false"; isJar="true"

else
	echo "[entrypoint][ERROR] File doesn't look like jar / zip, can't handle it"
	exit 2
fi

#backup files
for path in $PERSISTENT_PATHS; do
	doBackup "$path"
done

# clean existing files, f.e. if mods are removed on update
if [ "$isZip" = "true" ] || [ "$isJar" = "true" ]; then
	echo "[entrypoint][INFO] Cleaning existing folders mods/config/scripts/structures"
	# shellcheck disable=SC2086
	rm -rf $CLEANUP_PATHS || true
fi

# unzip server files
if [ "$isZip" = "true" ]; then
	unzip -q -o "${MY_FILE}"
	echo "[entrypoint][INFO] server files extracted"

	#move files from zip/xxx/* (volume/xxx/*) to volume/
	if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then 
		echo "[entrypoint][INFO] moving all files from \"real\" zip root (zip/${ROOT_IN_MODPACK_ZIP}) to volume"
		mv -vf "${MY_VOLUME}/${ROOT_IN_MODPACK_ZIP}/"* "${MY_VOLUME}"
		echo "[entrypoint][INFO] done"
	fi
	
	rm -f "${MY_FILE}"
fi

# install forge (TODO currently only forge?)
if [ -n "$FORGE_VERSION" ] ; then
	if [ ! -f "${MY_VOLUME}/${FORGE_JAR}" ]; then
		#remove existing forge
		rm -f forge-*.jar || true

		#install forge
		if wget -q --spider "$FORGE_URL"; then
			wget -O "${MY_VOLUME}/$FORGE_INSTALLER" "$FORGE_URL"

		# needed for e.g. 1.7.10
		elif wget -q --spider "$FORGE_URL_LEGACY"; then
			wget -O "${MY_VOLUME}/$FORGE_INSTALLER" "$FORGE_URL_LEGACY"
		else
			echo "[entrypoint][ERROR] Couldn't download forge installer tried: $FORGE_URL and $FORGE_URL_LEGACY"
			exit 3
		fi
		
		java -jar "${MY_VOLUME}/$FORGE_INSTALLER" --installServer
		
		#cleanup forge installer
		rm -f "${MY_VOLUME}/$FORGE_INSTALLER"
	fi
	TARGET_JAR="$FORGE_JAR"

else
	echo "[entrypoint][INFO] no forge version configured, expecting MY_FILE is TARGET_JAR"
	TARGET_JAR="$MY_FILE"
fi

# set eula = accepted
echo 'eula=true' > 'eula.txt'
echo "[entrypoint][INFO] You accepted the eula of Minecraft."

#restore files
for path in $PERSISTENT_PATHS; do
	doRestore "$path"
done


## apply config
writeServerProperties
writeOp
if [ -e "config.sh" ]; then sh config.sh; fi



# register SIGTERM trap => exit server securely
trap 'stopServer' 15
# create named pipe for query communication
if [ -e "$SERVER_QUERY_PIPE" ]; then rm "$SERVER_QUERY_PIPE"; fi
mkfifo "$SERVER_QUERY_PIPE"
# run and wait #dont "$TARGET_JAR" because * in it for forge....jar and -universal.jar(v1.12.2 e.g.)
# shellcheck disable=SC2086
java -server $JAVA_PARAMETERS -jar $TARGET_JAR <> "$SERVER_QUERY_PIPE" &
if [ "$TEST_MODE" = "true" ]; then
	sh /home/entrypointTestMode.sh
	exit $?

else
	wait $!
fi