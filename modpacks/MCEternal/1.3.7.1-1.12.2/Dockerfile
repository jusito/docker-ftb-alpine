ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV enable_command_block=true \
	level_type=BIOMESOP \
	max_tick_time=-1 \
	motd="Minecraft Eternal 1.3.7.1" \
	spawn_protection=10 \
	\
	ROOT_IN_MODPACK_ZIP="Eternal (ServerPack 1.3.7)" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2847"

CMD ["https://media.forgecdn.net/files/3018/935/Eternal+(ServerPack+1.3.7.1).zip", "f1c41d2947c1d2db73defa1f6ed71e51"]
