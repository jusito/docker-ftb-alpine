FROM openjdk:8-slim-buster

EXPOSE 25565/tcp

ENV MY_GROUP_ID=10000 \
	MY_USER_ID=10000 \
	MY_NAME=docker \
	MY_HOME=/home/docker \
	MY_VOLUME=/home/docker \
	MY_FILE="FTBServer.zip" \
	MY_SERVER="" \
	MY_MD5="" \
	\
# for CI needed
	TEST_MODE="" \
	STARTUP_TIMEOUT=600 \
	\
# changeable by user
	HEALTH_URL="127.0.0.1" \
	HEALTH_PORT="" \
	FORCE_DOWNLOAD="false" \
	JAVA_PARAMETERS="-XX:+UseG1GC -Xms4G -Xmx4G -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M" \
	OVERWRITE_PROPERTIES="true" \
	ADMIN_NAME="" \
	DEBUGGING=false \
	\
# server.properties
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
		
COPY ["entrypoint.sh", "checkHealth.sh", "entrypointTestMode.sh", "addOp.sh", "/home/" ]

#ln -sv /bin/busybox /bin/wget && \
#ln -sv /bin/busybox /bin/unzip && \
RUN apt-get update && \
	apt-get install -y ca-certificates wget unzip && \
# create user
	addgroup --gid "${MY_GROUP_ID}" "${MY_NAME}" && \
	adduser --home "${MY_HOME}" --gecos "" --shell "/bin/false" --gid "${MY_GROUP_ID}" --disabled-password --uid "${MY_USER_ID}" "${MY_NAME}" && \
# add permissions to all in /home
	chown -R "${MY_NAME}:${MY_NAME}" "/home" && \
	chmod -R u=rwx,go= "/home" && \
# remove temp files
	apt-get autoremove -y

VOLUME "$MY_HOME"

ENTRYPOINT ["/home/entrypoint.sh"]

USER "${MY_USER_ID}:${MY_GROUP_ID}"

# retry default is 3
# check integrity of checkHealth.sh
# execute sh
HEALTHCHECK --interval=10s --timeout=610s CMD \
 sha3sum "/home/checkHealth.sh" | grep -Eq '^3c9b55e8afc047aa080046f65f174c522b8b3e4d3f01d9d399fe6aec\s' && \
 sh /home/checkHealth.sh 

LABEL com.github.jusito.docker-ftb-alpine.version="1.0.0" \
	com.github.jusito.docker-ftb-alpine.maintainer="docker@jusito.de"