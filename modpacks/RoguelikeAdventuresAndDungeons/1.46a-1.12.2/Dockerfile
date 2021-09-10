ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	ROOT_IN_MODPACK_ZIP="RAD-Serverpack-1.46a" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854" \
	JAVA_PARAMETERS="-Xms2048m -Xmx4096m -XX:PermSize=256m"\
	\
 	difficulty="2"\
 	level_name="Biome Bundle"\
 	level_type="OTG"\
 	max_tick_time="-1"\
 	view_distance="8"

CMD ["https://media.forgecdn.net/files/3376/563/RAD-Serverpack-1.46a.zip", "aa81c6cbfe13c0c164f7f753b6b78987"]
