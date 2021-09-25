ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

# fixed forge version because mods required it
ENV	ROOT_IN_MODPACK_ZIP="EL2-Serverpack-1.07" \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.0" \
	JAVA_PARAMETERS="-Xmx4G" \
	\
 	allow_flight="true" \
 	difficulty="normal" \
 	gamemode="survival" \
 	level_type="realistic" \
 	max_players="5" \
 	motd="Engineers Life 2 Server" \
 	spawn_protection="8" \
 	view_distance="7"

CMD ["https://media.forgecdn.net/files/3422/423/EL2-Serverpack-1.07.zip", "1b6f48a36a129fd7a226542aeb10a426"]
