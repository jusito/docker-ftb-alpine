ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2855" \
	JAVA_PARAMETERS="-Xms2G -Xmx6G -XX:PermSize=256m -Dfml.read.Timeout=560" \
	\
 	enable_command_block="true" \
 	level_type="BIOMESOP" \
 	max_tick_time="-1" \
 	motd="Minecraft Eternal 1.4.4" \
 	spawn_protection="10"

CMD ["https://media.forgecdn.net/files/3305/944/Minecraft+Eternal+Server+1.4.4.zip", "38f23c652b14de4ead3a1eef17e2c7a8"]
