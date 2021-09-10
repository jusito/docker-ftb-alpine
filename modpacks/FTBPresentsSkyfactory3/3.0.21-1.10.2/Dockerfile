ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.10.2" \
	FORGE_VERSION="12.18.3.2511" \
	JAVA_PARAMETERS="-Xms1024M -Xmx4096M -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180"\
	\
 	motd="\u00A7d\u00A7oSky Factory\: 3 Server\u00A7r - \u00A74v3.0.21"

CMD ["https://media.forgecdn.net/files/3047/465/FTB_Presents_SkyFactory_3_Server_3_0_21.zip", "e8f12a32a3cdbb9b563862eab5481d4b"]
