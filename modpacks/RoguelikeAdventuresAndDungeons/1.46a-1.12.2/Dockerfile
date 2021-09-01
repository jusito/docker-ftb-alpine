ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV level_name="Biome Bundle" \
	allow_flight=false \
	level_type="OTG" \
	difficulty=2 \
	max_tick_time=-1 \
	view_distance=8 \
	player-idle-timeout=0 \
	\
	ROOT_IN_MODPACK_ZIP="RAD-Serverpack-1.46a" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854"

CMD ["https://media.forgecdn.net/files/3376/563/RAD-Serverpack-1.46a.zip", "aa81c6cbfe13c0c164f7f753b6b78987"]
