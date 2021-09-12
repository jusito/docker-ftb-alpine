ARG imageBase="11jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.2" \
	JAVA_PARAMETERS="-Xms1024M -Xmx6048M"

CMD ["https://media.forgecdn.net/files/3418/150/Explorico_mp_easy_3.2.zip", "93e37a59da8a1c66523d79a51a5c0db3"]
