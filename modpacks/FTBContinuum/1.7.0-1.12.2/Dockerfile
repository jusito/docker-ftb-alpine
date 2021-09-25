ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MY_FILE="serverinstall_34_149" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2855" \
	JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx4096M -Xms3072M"

CMD ["https://api.modpacks.ch/public/modpack/34/149/server/linux", "b5eda1019ba99a06a813aa14b0f0b8ac"]
