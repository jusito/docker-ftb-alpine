FROM adoptopenjdk/openjdk8:alpine-jre

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
	JAVA_PARAMETERS="-Xms4G -Xmx4G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCGroupMemoryLimitForHeap" \
	OVERWRITE_PROPERTIES="true" \
	ADMIN_NAME="" \
	DEBUGGING=false \
	ROOT_IN_MODPACK_ZIP="" \
	MINECRAFT_VERSION="" \
	FORGE_VERSION="" \
	CLEANUP_PATHS="mods config scripts structures libraries resources" \
	PERSISTENT_PATHS="banned-ips.json banned-players.json config.sh ops.json server.properties usercache.json usernamecache.json whitelist.json" \
	\
# server.properties
	IGNORE_PROPERTY_ERRORS=false \
	allow_flight=false \
	allow_nether=true \
	broadcast_console_to_ops=true \
	difficulty=1 \
	enable_command_block=false \
	enable_jmx_monitoring=false \
	enable_query=false \
	enable_rcon=false \
	enable_status=true \
	enforce_whitelist=false \
	entity_broadcast_range_percentage=100 \
	force_gamemode=false \
	function_permission_level=2 \ 
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
	rate_limit=0 \
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
	sync_chunk_writes=true \
	view_distance=10 \
	white_list=false
		
COPY ["base/8jre/entrypoint.sh", "base/8jre/checkHealth.sh", "base/8jre/entrypointTestMode.sh", "base/8jre/addOp.sh", "base/8jre/serverQuery.sh", "/home/" ]

RUN apk update && \
	apk add --no-cache ca-certificates && \
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
 sha3sum "/home/checkHealth.sh" | grep -Eq '^54492d1bcb582c0247fa8f8fafa9d2d0bfe04c837e978d2f99d645e0\s' && \
 sh /home/checkHealth.sh 

LABEL version="2.0.0" \
	maintainer="docker@jusito.de"