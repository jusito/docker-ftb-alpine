ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.16.5" \
	FORGE_VERSION="36.2.2" \
	\
 	allow_flight="true"\
 	enable_command_block="true"\
 	level_type="biomesoplenty"

CMD ["https://media.forgecdn.net/files/3453/327/MnM+1.6.0+Normal+Serverpack.zip", "86f006b062aa9740b98670f738acb630"]
