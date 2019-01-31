FROM openjdk:8-jre-alpine

EXPOSE 25565/tcp

ENV MY_GROUP_ID=10000 \
	MY_USER_ID=10000 \
	MY_NAME=docker \
	MY_HOME=/home/docker \
	MY_VOLUME=/home/docker/volume \
	MY_FILE="FTBServer.zip" \
	MY_SERVER="" \
	MY_MD5="" \
	\
	JAVA_PARAMETERS="-XX:+UseG1GC -Xms4G -Xmx4G -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M" \
	\
	allow_flight=false \
	allow_nether=true \
	broadcast_console_to_ops=true \
	difficulty=1 \
	enable_query=false \
	enable_rcon=false \
	enable_command_block=false \
	enforce_whitelist=false \
	force_gamemode=false \
	gamemode=0 \
	generate_structures=true \
	generator_settings="" \
	hardcore=false \
	level_name="world" \
	level_seed="" \
	level_type=DEFAULT \
	max_build_height=256 \
	max_players=20 \
	max_tick_time=60000 \
	max_world_size=29999984 \
	motd="A Minecraft Server" \
	network_compression_threshold=256 \
	online_mode=true \
	op_permission_level=4 \
	player_idle_timeout=0 \
	prevent_proxy_connections=false \
	pvp=true \
	query_port=25565 \
	rcon_password="" \
	rcon_port=25575 \
	resource_pack="" \
	resource_pack_sha1="" \
	server_ip="" \
	server_port=25565 \
	snooper_enabled=true \
	spawn_animals=true \
	spawn_monsters=true \
	spawn_npcs=true \
	spawn_protection=16 \
	view_distance=10 \
	white_list=false
	

VOLUME "${MY_SERVER}"

COPY ["entrypoint.sh", "${MY_HOME}/entrypoint.sh" ]

RUN apk update && \
	apk add --no-cache ca-certificates && \
	addgroup -g "${MY_GROUP_ID}" "${MY_NAME}" && \
	adduser -h "${MY_HOME}" -g "" -s "/bin/false" -G "${MY_NAME}" -D -u "${MY_USER_ID}" "${MY_NAME}" && \
	mkdir "${MY_VOLUME}" && \
	cd "${MY_HOME}" && \
	wget -O "${MY_FILE}" "${MY_SERVER}" && \
	echo "${MY_MD5}  ${MY_FILE}" | md5sum -s -c - && \
	chown -R "${MY_NAME}:${MY_NAME}" "${MY_HOME}" && \
	chmod -R u=rwx,go= "${MY_HOME}" && \
	apk del --quiet --no-cache --progress --purge && \
	rm -rf /var/cache/apk/*
	
ENTRYPOINT ["/home/docker/entrypoint.sh"]

USER "${MY_USER_ID}:${MY_GROUP_ID}"