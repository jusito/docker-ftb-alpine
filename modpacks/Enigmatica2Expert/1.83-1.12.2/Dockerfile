ARG imageBase=8jre-alpine-hotspot
ARG imageSuffix=''

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION='ERROR_FILL_MANUALLY' \
	FORGE_VERSION='ERROR_FILL_MANUALLY' \
	JAVA_PARAMETERS='-Xmx5G'\
	 \
 	allow_flight='true' \
 	difficulty='2' \
 	level_type='BIOMESOP' \
 	max_tick_time='0' \
 	motd='Enigmatica 2\: Expert Server'

CMD ['https://media.forgecdn.net/files/3433/600/Enigmatica2ExpertServer-1.83.zip', 'dcb6ec0691bc0e4385590b9d19e489f2']
