ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

# forge version updated because mods requested it
ENV	ROOT_IN_MODPACK_ZIP="LITV2-Serverpack-1.25" \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.0" \
	JAVA_PARAMETERS="-Xmx4G"\
	\
 	allow_flight="true"\
 	difficulty="normal"\
 	gamemode="survival"\
 	level_type="realistic"\
 	max_players="5"\
 	max_tick_time="-1"\
 	motd="Life in the Village 2 Server"\
 	spawn_protection="8"\
 	view_distance="7"

CMD ["https://media.forgecdn.net/files/3422/233/LITV2-Serverpack-1.25.zip", "ae389f419c2c2c4007efce1ea6aff632"]
