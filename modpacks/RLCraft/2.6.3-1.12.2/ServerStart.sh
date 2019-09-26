#!/bin/sh

if [ "${DEBUGGING:?}" = "true" ]; then
	set -o xtrace
fi

set -o errexit
set -o pipefail
set -o nounset

MCVER="1.12.2"
MCJAR="minecraft_server.${MCVER}.jar"
FORGEVER="14.23.5.2847"
FORGEINSTALLER="forge-${MCVER}-${FORGEVER}-installer.jar"
FORGEJAR="forge-${MCVER}-${FORGEVER}-universal.jar"
JAVACMD="java"

"forge-1.12.2-14.23.5.2847-installer.jar"

if [ -f "reinstall" ]; then
	rm -f "reinstall"
	REINSTALL=true
else
	REINSTALL=false
fi

if [ ! -f "${MY_VOLUME}/mods" ]; then
	echo "[ServerStart]Needing to move server files"
	mv -f "${MY_VOLUME}/RLCraft*/*" "${MY_VOLUME}"
fi

if [ ! -f "${MY_VOLUME}/${MCJAR}" ] || [ "$REINSTALL" == "true " ]; then
	wget -O "${MY_VOLUME}/${MCJAR}" "https://s3.amazonaws.com/Minecraft.Download/versions/${MCVER}/${MCJAR}"
fi
if [ ! -f "${MY_VOLUME}/${FORGEJAR}" ] || [ "$REINSTALL" == "true " ]; then
	wget -O "${MY_VOLUME}/$FORGEJAR" "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${MCVER}-${FORGEVER}/${FORGEINSTALLER}"
	java -jar "${MY_VOLUME}/$FORGEJAR" --installServer
	rm -f "${MY_VOLUME}/$FORGEINSTALLER"
fi

"$JAVACMD" -server DUMMY_REPLACED -jar "${MY_VOLUME}/${FORGEJAR}" nogui