ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2855" \
	JAVA_PARAMETERS="-Xms1024M -Xmx6048M"

CMD ["https://media.forgecdn.net/files/3074/836/DDSS_Serverfiles_8.0_R1.zip", "33fb9f5258c73d07625d8ac87ec245be"]
