# Minecraft docker-ftb-alpine
This repository contains servers for: https://www.feed-the-beast.com/

## Getting Started
1. Which server you want? Which version you want? Choose you _Tag_ below
2. Do you want reddit jvm args? Yes go next, no see _Environment Variables_
3. Do you want persistent files? No go next, yes `-v minecraft_modded:/home/docker/volume:rw`
4. Do you want your own server.properties? No go next, yes see use Environmental Variables _server.properties_ or see _Additional Informations_
5. Combine all, here is an example with motd, persistend files and Skyfactor.
`docker run -d -v minecraft_modded:/home/docker/volume:rw -e motd="Hello Docker" jusito/docker-ftb-alpine:FTBPresentsSkyfactory3-3.0.15-1.10.2`

### Usage
#### Tags
[FTB Infinity Evolved MC 1.7.10](https://www.feed-the-beast.com/projects/ftb-infinity-evolved "FTB Infinity Evolved") 
* FTBInfinity-3.0.2-1.7.10

[FTB Presents SkyFactory 3 MC 1.10.2](https://www.feed-the-beast.com/projects/ftb-presents-skyfactory-3 "FTB Presents SkyFactory 3") 
* FTBPresentsSkyfactory3-3.0.15-1.10.2

[FTB Presents Direwolf20 MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-presents-direwolf20-1-12 "FTB Presents Direwolf20 1.12") 
* FTBPresentsDirewolf20-2.1.0-1.12.2

[FTB Continuum MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-continuum "FTB Continuum") 
* FTBContinuum-1.4.1-1.12.2
* FTBContinuum-1.5.2-1.12.2

[FTB Revelation MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-revelation "FTB Revelation")
* FTBRevelation-2.2.0-1.12.2
* FTBRevelation-2.3.0-1.12.2
* FTBRevelation-2.6.0-1.12.2

[Vanilla MC 1.13.2](https://minecraft.net/de-de/download/server/ "Lade den Minecraft: Java Edition-Server herunter")
* Vanilla-1.13.2-beta (I don't test this well)

#### Environment Variables
Example:
`docker [...] -e JAVA_PARAMETERS="-Xms4G -Xmx4G" [...] jusito/docker-ftb-alpine:*TAG*`

##### JAVA_PARAMETERS (JVM Arguments, Performance)
[Default value in container:](https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/ "Modded MC and memory usage, a history with a crappy graph") 
`-XX:+UseG1GC -Xmx4G -Xms4G -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M`

FTB using this in normal case:
`-XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=5 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10`
`-xmx=2G or -xmx=4G`

##### [server.properties](https://minecraft-de.gamepedia.com/Server.properties "https://minecraft-de.gamepedia.com/Server.properties") 
In general Propertyname = Variablename, just replace "-"&"." with "_"
* allow_flight=false
* allow_nether=true
* broadcast_console_to_ops=true
* difficulty=1
* enable_query=false
* enable_rcon=false
* enable_command_block=false
* enforce_whitelist=false
* force_gamemode=false
* gamemode=0
* generate_structures=true
* generator_settings=""
* hardcore=false
* level_name="world"
* level_seed=""
* level_type=DEFAULT
* max_build_height=256
* max_players=20
* max_tick_time=60000
* max_world_size=29999984
* motd="A Minecraft Server"
* network_compression_threshold=256
* online_mode=true
* op_permission_level=4
* player_idle_timeout=0
* prevent_proxy_connections=false
* pvp=true
* query_port=25565
* rcon_password=""
* rcon_port=25575
* resource_pack=""
* resource_pack_sha1=""
* server_ip=""
* server_port=25565
* snooper_enabled=true
* spawn_animals=true
* spawn_monsters=true
* spawn_npcs=true
* spawn_protection=16
* view_distance=10
* white_list=false

##### Internal Used (don't change please)
* MY\_USER_ID 10000
* MY\_GROUP_ID 10000
* MY_NAME docker
* MY_HOME /home/docker
* MY_VOLUME /home/docker/volume
* MY_FILE "FTBServer.zip"
* MY\_SERVER _*TagDependency*_
* MY\_MD5 _*TagDependency*_

#### Volumes
* /home/docker/volume

#### Useful File Locations
* /home/docker/volume/config/ Mod configs
* /home/docker/volume/logs/ FTB logs
* /home/docker/volume/mods/ Mod folder
* /home/docker/volume/server.properties
* /home/docker/volume/config.sh your personal config

## Additional Informations
### Use your existing server.properties
1. start container one time until done, stop it
2. docker cp _"Your server.properties"_ _ContainerName_:/home/docker/volume/server.properties

### persistent files on update
* banned-ips.json
* banned-players.json
* config.sh (if existing)
* ops.json
* server.properties
* usercache.json
* usernamecache.json
* whitelist.json

### Own Scripts
* /home/docker/volume/config.sh, care because only alpine + busybox, no Bash, no PCRE

## Find Us
https://github.com/jusito/docker-ftb-alpine

## Contributing / Requesting
Git issue or comment here
