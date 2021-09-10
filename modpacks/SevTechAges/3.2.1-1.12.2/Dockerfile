ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854" \
	JAVA_PARAMETERS="-Xms1024M -Xmx4096M -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180"\
	\
 	allow_flight="true"\
 	enable_command_block="true"\
 	enable_query="true"\
 	force_gamemode="true"\
 	level_type="quark_realistic"\
 	motd="\u00A7d\u00A7oSevTech\: Ages Server\u00A7r - \u00A74v3.2.1"\
 	snooper_enabled="false"

CMD ["https://media.forgecdn.net/files/3125/814/SevTech_Ages_Server_3.2.1.zip", "854a44548d78f675c9d77d261860254a"]
