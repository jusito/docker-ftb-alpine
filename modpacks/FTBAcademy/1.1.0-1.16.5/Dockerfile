ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MY_FILE="serverinstall_88_2062" \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.1.4" \
	JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx6000M -Xms5000M"

CMD ["https://api.modpacks.ch/public/modpack/88/2062/server/linux", ""]
