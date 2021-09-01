ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV allow-flight=true \
    level-type=biomesoplenty \
    motd="Valhelsia 3 Server" \
    \
	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.2"

CMD ["https://media.forgecdn.net/files/3432/276/Valhelsia+3-3.4.2a-SERVER.zip", "42c133d8c02c67d47506bc4b052cf9e0"]
