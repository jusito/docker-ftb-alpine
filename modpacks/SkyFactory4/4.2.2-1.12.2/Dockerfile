ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV allow_flight=true \
	enable_command_block=true \
	generator_settings="{\"Topography-Preset\"\\:\"Sky Factory 4\"}" \
	motd="\u00A7d\u00A7oSkyFactory 4\: Server\u00A7r - \u00A74v4.2.2" \
	spawn_protection=0 \
	\
	ROOT_IN_MODPACK_ZIP="" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854"

CMD ["https://media.forgecdn.net/files/3012/800/SkyFactory-4_Server_4.2.2.zip", "a3a28d3947bd97db87bf3743708f22d8"]
