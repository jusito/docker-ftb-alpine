ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	ROOT_IN_MODPACK_ZIP="Medieval Minecraft Server Pack [FORGE]" \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.4" \
	JAVA_PARAMETERS="-Xmx5G -Xms5G" \
	\
 	allow_flight="true" \
 	difficulty="normal" \
 	gamemode="survival" \
 	level_type="default" \
 	max_tick_time="-1" \
 	motd="Medieval Minecraft [FORGE]"

CMD ["https://media.forgecdn.net/files/3454/411/Medieval+Minecraft+Server+Pack+%5bFORGE%5d+v28.zip", "d1d5148cd9c0b0001065559398307069"]
