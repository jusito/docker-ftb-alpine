FROM alpine:3.11

EXPOSE 25565/tcp

ENV MY_GROUP_ID=10000 \
	MY_USER_ID=10000 \
	MY_NAME=docker \
	MY_HOME=/home/docker \
	MY_VOLUME=/home/docker \
	MY_FILE="Server.zip" \
	MY_SERVER="" \
	MY_MD5="" \
	SERVER_QUERY_PIPE="/home/query.pipe" \
	\
# for CI needed
	TEST_MODE="" \
	STARTUP_TIMEOUT=600 \
	\
# changeable by user
	HEALTH_URL="127.0.0.1" \
	HEALTH_PORT="" \
	FORCE_DOWNLOAD="false" \
	JAVA_PARAMETERS="-Xms4G -Xmx4G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseCGroupMemoryLimitForHeap -XX:ParallelGCThreads=4 -Dsun.rmi.dgc.server.gcInterval=3600000 -XX:MaxGCPauseMillis=50" \
	OVERWRITE_PROPERTIES="true" \
	ADMIN_NAME="" \
	DEBUGGING=false \
	ROOT_IN_MODPACK_ZIP="" \
	MINECRAFT_VERSION="" \
	FORGE_VERSION="" \
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
		
COPY ["base/8jre/alpine/entrypoint.sh", "base/8jre/alpine/checkHealth.sh", "base/8jre/alpine/entrypointTestMode.sh", "base/8jre/alpine/addOp.sh", "base/8jre/alpine/serverQuery.sh", "/home/" ]

RUN apk update && \
	apk add --no-cache ca-certificates openjdk8-jre && \
# create user
	addgroup -g "${MY_GROUP_ID}" "${MY_NAME}" && \
	adduser -h "${MY_HOME}" -g "" -s "/bin/false" -G "${MY_NAME}" -D -u "${MY_USER_ID}" "${MY_NAME}" && \
# add permissions to all in /home
	chown -R "${MY_NAME}:${MY_NAME}" "/home" && \
	chmod -R u=rwx,go= "/home" && \
# remove temp files
	apk del --quiet --no-cache --progress --purge && \
	rm -rf /var/cache/apk/* && \
# create symlinks for easy usage
	ln -s "/home/serverQuery.sh" "/usr/local/bin/query" && \
	ln -s "/home/addOp.sh" "/usr/local/bin/addop"

VOLUME "$MY_HOME"

ENTRYPOINT ["/home/entrypoint.sh"]

USER "${MY_USER_ID}:${MY_GROUP_ID}"

# retry default is 3
# check integrity of checkHealth.sh
# execute sh
HEALTHCHECK --interval=10s --timeout=610s CMD \
 sha3sum "/home/checkHealth.sh" | grep -Eq '^8651544c223472875e8f1e4ab336b51711d0638b8d2dfb5b46514a02\s' && \
 sh /home/checkHealth.sh 

LABEL com.github.jusito.docker-ftb-alpine.version="2.0.0" \
	com.github.jusito.docker-ftb-alpine.maintainer="docker@jusito.de"