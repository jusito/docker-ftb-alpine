ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.2" \
	JAVA_PARAMETERS="-Xms4G -Xmx4G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AlwaysPreTouch"\
	\
 	allow_flight="true"\
 	difficulty="normal"\
 	gamemode="survival"\
 	level_type="biomesoplenty"\
 	motd="Valhelsia 3 Server"

CMD ["https://media.forgecdn.net/files/3432/276/Valhelsia+3-3.4.2a-SERVER.zip", "42c133d8c02c67d47506bc4b052cf9e0"]
