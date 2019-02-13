# Minecraft FTB meets alpine
This repository contains servers for: [Feed The Beast](https://www.feed-the-beast.com/)
[![Build Status](https://travis-ci.org/jusito/docker-ftb-alpine.svg?branch=master)](https://travis-ci.org/jusito/docker-ftb-alpine)

**By using this container you agree to the** [Minecraft Eula](https://help.mojang.com/customer/en/portal/articles/1590522-minecraft-commercial-use)

## Getting Started
1. Which server you want? Which version you want? Choose you _Tag_ below
2. Which Port? -p 25566:25565 means 25566 from internet, 25565 from inside of container
3. Do you want reddit jvm args? Yes go next, no see _Environment Variables_
4. Do you want persistent files? No go next, yes `-v minecraft_modded:/home/docker:rw`
5. Do you want your own server.properties? No go next, yes see use Environmental Variables _server.properties_ or see _Additional Informations_

### Example Skyfactor: 

```
docker run -d -p 25565:25565 -v minecraft:/home/docker:rw -e motd="Hello Docker" jusito/docker-ftb-alpine:FTBPresentsSkyfactory3-3.0.15-1.10.2
```

## Tags
[FTB Infinity Evolved MC 1.7.10](https://www.feed-the-beast.com/projects/ftb-infinity-evolved) 
* FTBInfinity-3.0.2-1.7.10

[FTB Presents SkyFactory 3 MC 1.10.2](https://www.feed-the-beast.com/projects/ftb-presents-skyfactory-3) 
* FTBPresentsSkyfactory3-3.0.15-1.10.2

[FTB Presents Direwolf20 MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-presents-direwolf20-1-12) 
* FTBPresentsDirewolf20-2.4.0-1.12.2

[FTB Continuum MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-continuum) 
* FTBContinuum-1.6.0-1.12.2

[FTB Revelation MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-revelation)
* FTBRevelation-2.7.0-1.12.2

[Vanilla MC 1.13.2](https://minecraft.net/de-de/download/server/)
* Vanilla-1.13.2

### no Tag found?
* Tag: FTBBase
* First argument: Link to server download
* Second argument: MD5 of server download
* You are done

Example:
`docker run [...] jusito/docker-ftb-alpine:FTBBase "https://media.forgecdn.net...server.zip" "*md5 of server*"`

## Environment Variables
Example:
`docker [...] -e JAVA_PARAMETERS="-Xms4G -Xmx4G" [...] jusito/docker-ftb-alpine:*TAG*`

### JAVA_PARAMETERS (JVM Arguments, Performance)
[Default value in container:](https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/ "Modded MC and memory usage, a history with a crappy graph") 
`-XX:+UseG1GC -Xmx4G -Xms4G -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M`

If you want default FTB values: JAVA_PARAMETERS=""

### Server Properties
https://minecraft-de.gamepedia.com/Server.properties

In general Propertyname = Variablename, just replace "-"&"." with "_"

<details><summary>All Available Properties (click me)</summary>
<p>

* allow_flight=false
* allow_nether=true
* broadcast\_console\_to_ops=true
* difficulty=1
* enable_query=false
* enable_rcon=false
* enable\_command_block=false
* enforce_whitelist=false
* force_gamemode=false
* gamemode=0
* generate_structures=true
* generator_settings=""
* hardcore=false
* level_name="world"
* level_seed=""
* level_type=DEFAULT
* max\_build_height=256
* max_players=20
* max\_tick_time=60000
* max\_world_size=29999984
* motd="A Minecraft Server"
* network\_compression_threshold=256
* online_mode=true
* op\_permission_level=4
* player\_idle_timeout=0
* prevent\_proxy_connections=false
* pvp=true
* query_port=25565
* rcon_password=""
* rcon_port=25575
* resource_pack=""
* resource\_pack_sha1=""
* server_ip=""
* server_port=25565
* snooper_enabled=true
* spawn_animals=true
* spawn_monsters=true
* spawn_npcs=true
* spawn_protection=16
* view_distance=10
* white_list=false

</p>
</details>

### Healthcheck
This container is using a health check default. It checks every 10s if the server status is available. If you don't want this use: `--no-healthcheck`
* HEALTH_URL 127.0.0.1, maybe you want to set this to external address
* HEALTH\_PORT _read from server.properties_

### additional config
* FORCE_RELOAD false, if true the container redownloads the file everytime

### Internal Used (don't change please)
* MY\_USER_ID 10000
* MY\_GROUP_ID 10000
* MY_NAME docker
* MY_HOME /home/docker
* MY_VOLUME /home/docker
* MY_FILE "FTBServer.zip"
* MY\_SERVER _*TagDependency*_
* MY\_MD5 _*TagDependency*_
* TEST_MODE "" (used for CI)
* STARTUP_TIMEOUT 300 timeout for TEST\_MODE

## Additional Informations
### Volumes
* /home/docker

### Useful File Locations
* /home/docker/config/ Mod configs
* /home/docker/logs/ FTB logs
* /home/docker/mods/ Mod folder
* /home/docker/server.properties
* /home/docker/config.sh your personal config

### Use your existing server.properties
1. start container one time until done, stop it
2. docker cp _"Your server.properties"_ _ContainerName_:/home/docker/server.properties

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
* /home/docker/config.sh, care because only alpine + busybox, no Bash, no PCRE

### Minecraft related
* [Set server image](https://www.spigotmc.org/threads/how-to-add-a-server-icon-to-your-server-1-7-1-8.6564/)
* [MOTD colors](https://www.minecraftforum.net/forums/support/server-support-and/1940468-how-to-add-colour-to-your-server-motd)

## Find Me
https://github.com/jusito/

## Contributing / Requesting
Git issue or comment here, I don't check everytime for newer version but I can easily push a new tag

## Acknowledgments
* [Feed The Beast Project](https://www.feed-the-beast.com "Feed The Beast Project")
* [PurpleBooth@github Docker Template](https://gist.github.com/PurpleBooth/ea518ae68a49029bae95 "Template-README-for-containers.md")
* [jamietech@github MC server status](https://github.com/jamietech/MinecraftServerPing)
* [Valiano@stackoverflow ash grep behaviour](https://stackoverflow.com/questions/54572688/different-behaviour-of-grep-with-pipe-from-nc-on-alpine-vs-ubuntu)