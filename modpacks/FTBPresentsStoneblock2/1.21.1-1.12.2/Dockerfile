ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MY_FILE="serverinstall_4_153" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2855" \
	JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx6122M -Xms4096M"

CMD ["https://api.modpacks.ch/public/modpack/4/153/server/linux", ""]
