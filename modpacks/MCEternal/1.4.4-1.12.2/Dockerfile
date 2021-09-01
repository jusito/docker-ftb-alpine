ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV enable_command_block=true \
	level_type=BIOMESOP \
	max_tick_time=-1 \
	motd="Minecraft Eternal 1.4.4" \
	spawn_protection=10 \
	\
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854"

CMD ["https://media.forgecdn.net/files/3305/944/Minecraft+Eternal+Server+1.4.4.zip", "38f23c652b14de4ead3a1eef17e2c7a8"]
