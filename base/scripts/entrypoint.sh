#!/bin/bash

if [ "${DEBUGGING:?}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
#set -o pipefail

# get arguments
cacheOnly=CHECK_STYLE="$(grep -q 'cache-only' <<< "$@" && echo "true" || echo "false")"
set -o nounset #3 not always given
export MY_SERVER="$1"
export MY_MD5="$2"

# set local vars
FORGE_INSTALLER="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}-installer.jar"
FORGE_INSTALLER_LEGACY="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}-${MINECRAFT_VERSION}-installer.jar"
FORGE_JAR="forge-${MINECRAFT_VERSION}-${FORGE_VERSION}*.jar"
FORGE_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${FORGE_VERSION}/${FORGE_INSTALLER}"
FORGE_URL_LEGACY="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${FORGE_VERSION}-${MINECRAFT_VERSION}/${FORGE_INSTALLER_LEGACY}"

# setup server.properties
for script_file in /home/minecraft-properties/*; do
  # shellcheck disable=SC1090
  . "$script_file"
done



#region functions
download() {
	# using env $FORCE_DOWNLOAD
	target="$1"
	source="$2"
	md5="$3"
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
		echo "[entrypoint][INFO] downloading \"$source\""
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

writeServerProperties() {

	if [ "$OVERWRITE_PROPERTIES" = "true" ]; then
		echo "[entrypoint][INFO] OVERWRITE_PROPERTIES activated (default) overwriting properties."

		loadServerPropertyConfig "$MINECRAFT_VERSION"
		readServerProperties_fromEnvironment_toVariable
		writeServerProperties_toFile "server.properties"
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
#shellcheck disable=SC2034
isFTBInstaller="false"; isZip="false"; isJar="false"
fileEnding=$(echo "$MY_FILE" | grep -Eo -e '[^.]+$' | tr '[:upper:]' '[:lower:]')
if [ "$fileEnding" = "zip" ]; then
	isZip="true"

elif [ "$fileEnding" = "jar" ]; then
	isJar="true"

elif grep -q 'serverinstall_[0-9]*_[0-9]*' <<< "$MY_FILE"; then
  isFTBInstaller="true"

else
	echo "[entrypoint][ERROR] File doesn't look like jar / zip / FTB installer, can't handle it"
	exit 2
fi

#backup files
for path in $PERSISTENT_PATHS; do
	doBackup "$path"
done

# clean existing files, f.e. if mods are removed on update
for path in $CLEANUP_PATHS; do
  echo "[entrypoint][INFO] Cleaning existing folders $path"
  # shellcheck disable=SC2086
  rm -rf "$path" || true
done

# prepare server installation
# e.g. unzip server files
if "$isZip"; then
	unzip -q -o "${MY_FILE}"
	echo "[entrypoint][INFO] server files extracted"

	#move files from zip/xxx/* (volume/xxx/*) to volume/
	if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then
		echo "[entrypoint][INFO] moving all files from \"real\" zip root (zip/${ROOT_IN_MODPACK_ZIP}) to volume"
		mv -vf "${MY_VOLUME}/${ROOT_IN_MODPACK_ZIP}/"* "${MY_VOLUME}"
		echo "[entrypoint][INFO] done"
	fi

	rm -f "${MY_FILE}"
elif "$isFTBInstaller"; then
  chmod +x "${MY_FILE}"
fi

# install server
# e.g. install forge (TODO currently only forge?)
if "$isFTBInstaller"; then
  if ./"${MY_FILE}" --auto --integrityupdate --integrity; then
    echo "[entrypoint][INFO] FTB installer successful"
  else
    echo "[entrypoint][ERROR] FTB installer failed"
  fi
  TARGET_JAR="$FORGE_JAR"

elif [ -n "$FORGE_VERSION" ]; then
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

		if ! java -jar "${MY_VOLUME}/$FORGE_INSTALLER" --installServer; then
      echo "[entrypoint][WARN] failed online forge installation, trying offline"
      java -jar "${MY_VOLUME}/$FORGE_INSTALLER" --installServer --offline
		fi

		#cleanup forge installer
		rm -f "${MY_VOLUME}/$FORGE_INSTALLER"
	fi
	TARGET_JAR="$FORGE_JAR"

elif "$isJar"; then
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
java -server $JAVA_PARAMETERS -jar "$TARGET_JAR" <> "$SERVER_QUERY_PIPE" &
if [ "$TEST_MODE" = "true" ]; then
	sh /home/entrypointTestMode.sh
	exit $?

else
	wait $!
fi