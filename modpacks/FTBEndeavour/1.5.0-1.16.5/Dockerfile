ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MY_FILE="serverinstall_80_2068" \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.2" \
	JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx6144M -Xms4096M"

CMD ["https://api.modpacks.ch/public/modpack/80/2068/server/linux", "b5eda1019ba99a06a813aa14b0f0b8ac"]
