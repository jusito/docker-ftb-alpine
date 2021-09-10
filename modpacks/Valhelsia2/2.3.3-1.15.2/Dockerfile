ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.15.2" \
	FORGE_VERSION="31.2.50" \
	JAVA_PARAMETERS="-Xms5G -Xmx5G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AlwaysPreTouch"\
	\
 	allow_flight="true"\
 	difficulty="normal"\
 	gamemode="survival"\
 	level_type="biomesoplenty"\
 	motd="Valhelsia 2 Server"

CMD ["https://media.forgecdn.net/files/3283/29/Valhelsia_2-2.3.3-SERVER.zip", "c0556560538a3b564c673a6f7ae4b878"]
