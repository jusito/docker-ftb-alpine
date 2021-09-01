ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV force_gamemode=true \
	enable_query=true \
	snooper_enabled=false \
	level_type=quark_realistic \
	enable_command_block=true \
	allow_flight=true \
	motd="\u00A7d\u00A7oSevTech\: Ages Server\u00A7r - \u00A74v3.2.1" \
# not supported dc_preset=notSet
	\
	ROOT_IN_MODPACK_ZIP="" \
	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2854"

CMD ["https://media.forgecdn.net/files/3125/814/SevTech_Ages_Server_3.2.1.zip", "854a44548d78f675c9d77d261860254a"]
