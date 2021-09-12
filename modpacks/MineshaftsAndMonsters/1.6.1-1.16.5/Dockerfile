ARG imageBase=8jre-alpine-hotspot
ARG imageSuffix=''

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION='1.16.5' \
	FORGE_VERSION='36.2.2' \
	 \
 	allow_flight='true' \
 	enable_command_block='true' \
 	level_type='biomesoplenty'

CMD ["https://media.forgecdn.net/files/3455/962/MineshaftsnMonsters++(Normal_Serverpack).zip", "78d1e616daf044b8d6b32a93077be420"]
