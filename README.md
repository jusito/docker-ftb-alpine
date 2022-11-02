# Minecraft modpacks meet alpine
This repository contains servers for minecraft modpacks like FTB:
[![Build Status](https://travis-ci.org/jusito/docker-ftb-alpine.svg?branch=master)](https://travis-ci.org/jusito/docker-ftb-alpine)

**By using this container you agree to the** [Minecraft Eula](https://help.mojang.com/customer/en/portal/articles/1590522-minecraft-commercial-use)

## Getting Started
1. Which server you want? Which version you want? Choose you _Tag_ below like `DungeonsDragonsAndSpaceShuttles-7.4a-1.12.2`
2. Which Port? `-p 25566:25565` means 25566 from internet, 25565 from inside of container
3. Do you want default jvm arguments / RAM usage and so on? Yes go next, no see _Environment Variables_
4. Should I enter an operator level 4? He would be also whitelisted. No go next, yes use `-e ADMIN_NAME="YourNameHere"`
5. Do you want your own server.properties? No go next, yes see _Environmental Variables_, _server.properties_ or see _Additional Informations_

### Example Dungeons Dragons And Space Shuttles: 

```
docker run -d -p 25565:25565 -v minecraft:/home/docker:rw -e ADMIN_NAME="YourNameHere" -e motd="Hello Docker" jusito/docker-ftb-alpine:DungeonsDragonsAndSpaceShuttles-7.4a-1.12.2
```

## Tags

There are two different base images which provides different java virtual machine. The alpine images are amd64/x86 with Hotspot jvm as default (like expected) and openj9 is an option, multiarch isn't supported. I test every modpack with openj9 but if it doesn't even start the server, I will not push a tag with it. (forge with 1.15+ will throw unsupported virtual machine for openj9) Every tag is tested before push but this tags are more example configurations of the base images. Every provided tag will use the recommended server properties and forge version from modpack creator - if not its a bug and please report it. If you want to use the nightly images append "-develop" to the tag.

### most recent
* [Explorico 1.16.5](https://www.curseforge.com/minecraft/modpacks/explorico-1-16-5) `Explorico-3.2-1.16.5`
* [MC Eternal MC 1.12.2](https://www.curseforge.com/minecraft/modpacks/minecraft-eternal) `MCEternal-1.4.4-1.12.2`
* [RoguelikeAdventuresAndDungeons MC 1.12.2](https://www.curseforge.com/minecraft/modpacks/roguelike-adventures-and-dungeons) `RoguelikeAdventuresAndDungeons-1.46a-1.12.2`
* [SevTechAges MC 1.12.2](https://www.curseforge.com/minecraft/modpacks/sevtech-ages) `SevTechAges-3.2.1-1.12.2`
* [Valhelsia 2 MC 1.15.2](https://www.curseforge.com/minecraft/modpacks/valhelsia-2) `Valhelsia2-2.3.3-1.15.2`
* [Valhelsia 3 MC 1.16.5](https://www.curseforge.com/minecraft/modpacks/valhelsia-3) `Valhelsia3-3.4.2a-1.16.5`
* [Vanilla Minecraft](https://minecraft.net/de-de/download/server/) `Vanilla-1.17.1`
* [DungeonsDragonsAndSpaceShuttles MC 1.12.2](https://www.curseforge.com/minecraft/modpacks/dungeons-dragons-and-space-shuttles) `DungeonsDragonsAndSpaceShuttles-8.0r1-1.12.2`

 ### other
* [FTB Continuum MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-continuum) `FTBContinuum-1.6.0-1.12.2` `FTBContinuum-1.6.0-1.12.2-openj9`
* [FTB Presents Direwolf20 MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-presents-direwolf20-1-12)  `FTBPresentsDirewolf20-2.5.0-1.12.2` `FTBPresentsDirewolf20-2.5.0-1.12.2-openj9`
* [FTB Presents SkyFactory 3 MC 1.10.2](https://www.feed-the-beast.com/projects/ftb-presents-skyfactory-3)  `FTBPresentsSkyfactory3-3.0.21-1.10.2` `FTBPresentsSkyfactory3-3.0.21-1.10.2-openj9`
* [FTB Presents Stoneblock 2](https://www.feed-the-beast.com/projects/ftb-presents-stoneblock-2) `FTBPresentsStoneblock2-1.16.0-1.12.2` `FTBPresentsStoneblock2-1.16.0-1.12.2-openj9`
* [FTB Revelation MC 1.12.2](https://www.feed-the-beast.com/projects/ftb-revelation) `FTBRevelation-3.2.0-1.12.2` `FTBRevelation-3.2.0-1.12.2-openj9`
* [FTB Ultimate Reloaded](https://www.feed-the-beast.com/projects/ftb-ultimate-reloaded) `FTBUltimateReloaded-1.9.0-1.12.2` `FTBUltimateReloaded-1.9.0-1.12.2-openj9`
* [RLCraft](https://www.curseforge.com/minecraft/modpacks/rlcraft) `RLCraft-2.8.2-1.12.2` `RLCraft-2.8.2-1.12.2-openj9`
* [SkyFactory 4 MC 1.12.2](https://www.curseforge.com/minecraft/modpacks/skyfactory-4) `SkyFactory4-4.2.2-1.12.2`


### no Tag found?
* Tag: 8jre-alpine-hotspot or 8jre-alpine-openj9 (unsure -> pick hotspot!)
* First argument: Link to server download
* Second argument: MD5 of server download
* You are done

Example:
`docker run [...] jusito/docker-ftb-alpine:8jre-alpine-hotspot "https://media.forgecdn.net...server.zip" "*md5 of server*"`

## Environment Variables
Example:
`docker [...] -e JAVA_PARAMETERS="-Xms4G -Xmx4G" [...] jusito/docker-ftb-alpine:*TAG*`

### JAVA_PARAMETERS (JVM Arguments, Performance)
* default for hotspot `-Xms4G -Xmx4G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCGroupMemoryLimitForHeap`
* default for openj9 `-Xms4096M -Xmx4096M -Xmns2048M -Xmnx3276M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -Xtune:virtualized`
* [reddit suggestion, good for clients](https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/)  `-XX:+UseG1GC -Xmx4G -Xms4G -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M`
* aikar suggestion: [link](https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/)
* Iam using for DDSS server: `-Xms8192M -Xmx8192M -XX:+UseStringDeduplication -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true`

### Server Properties
Because you may want to use many environment variables, [you may find --env-file helpful](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file).
The values of this environment variables are written on every restart. If you don't set them, default value is written.

|Name|Default|Description|
|----|-------|-----------|
|OVERWRITE\_PROPERTIES|true|server.properties are deleted and rewritten at each restart. Unused variables remain on default. Unknown properties are deleted.|

In general Propertyname = Variablename, lowercase and replace "-"&"." with "_". See below for details.
<details><summary>All Available Properties (click me)</summary>
<p>

|Name|Default|Name in server.properties|
|----|-------|-------------------------|
|allow\_flight|false|allow-flight|
|allow\_nether|true|allow-nether|
|broadcast\_console\_to\_ops|true|broadcast-console-to-ops|
|difficulty|1|difficulty|
|enable\_command\_block|false|enable-command-block|
|enable\_jmx\_monitoring|false|enable-jmx-monitoring=false|
|enable\_query|false|enable-query|
|enable\_rcon|false|enable-rcon|
|enable\_status|true|enable-status|
|enforce\_whitelist|false|enforce-whitelist|
|entity\_broadcast\_range\_percentage|100|entity-broadcast-range-percentage|
|force\_gamemode|false|force-gamemode|
|function\_permission\_level|2|function-permission-level|
|gamemode|0|gamemode|
|generate\_structures|true|generate-structures|
|generator\_settings||generator-settings|
|hardcore|false|hardcore|
|level\_name|world|level-name|
|level\_seed||level-seed|
|level\_type|DEFAULT|level-type|
|max\_build\_height|256|max-build-height|
|max\_players|20|max-players|
|max\_tick\_time|60000|max-tick-time|
|max\_world\_size|29999984|max-world-size|
|motd|A Minecraft Server||
|network\_compression\_threshold|256|network-compression-threshold|
|online\_mode|true|online-mode|
|op\_permission\_level|4|op-permission-level|
|player\_idle\_timeout|0|player-idle-timeout|
|prevent\_proxy\_connections|false|prevent-proxy-connections|
|pvp|true|pvp|
|query\_port|25565|query.port|
|rate\_limit|0|rate-limit|
|rcon\_password||rcon.password|
|rcon\_port|25575|rcon.port|
|resource\_pack||resource-pack|
|resource\_pack\_sha1||resource-pack-sha1|
|server\_ip||server-ip|
|server\_port|25565|server-port|
|snooper\_enabled|true|snooper-enabled|
|spawn\_animals|true|spawn-animals|
|spawn\_monsters|true|spawn-monsters|
|spawn\_npcs|true|spawn-npcs|
|spawn\_protection|16|spawn-protection|
|sync\_chunk\_writes|true|sync-chunk-writes|
|view\_distance|10|view-distance|
|white\_list|false|white-list|

</p>
</details>

### access server console
`docker exec -it CONTAINER query`
* show - view last 50 log lines
* end - end query
* help - call help in serverquery
* stop - call stop in serverquery
* \*every other serverquery command\*

### Healthcheck
This container is using a health check default. It checks every 10s if the server status is available. If you don't want this use: `--no-healthcheck`

|Name|Default|Description|
|-|-|-|
|HEALTH\_URL|127.0.0.1|Target address for healthcheck. Maybe you want to add your external address.|
|HEALTH\_PORT|_read from server.properties_|Target port for healthcheck.|

### additional config

|Name|Default|Description|
|----|-------|-----------|
|FORCE\_DOWNLOAD|false|Whether the server should be downloaded every time it is restarted.|
|ADMIN\_NAME||Set here your first admin level 4 name. This will allow you to change config ingame.|
|DEBUGGING|false|If true xtrace is set in every script. Very verbose!|
|FORGE_VERSION||Force forge version because this images always ignore the shipped forge jars (if not exact vesion configured for the image).|

### Internal Used (don't change please)
<details><summary>(click me)</summary>
<p>

|Name|Default|Description|
|-|-|-|
|MY\_USER_ID|10000||
|MY\_GROUP_ID|10000||
|MY\_NAME|docker||
|MY\_HOME|/home/docker||
|MY\_VOLUME|/home/docker||
|MY\_FILE|_*TagDependency*_|Name of the server file.|
|MY\_SERVER|_*TagDependency*_|Download link of the server.|
|MY\_MD5|_*TagDependency*_|MD5 of Download.|
|TEST\_MODE||used for CI|
|STARTUP\_TIMEOUT|600|timeout for TEST\_MODE|

</p>
</details>

## Additional Informations
### Volumes
* /home/docker

### Useful File Locations
* /home/docker/config/ Mod configs
* /home/docker/logs/ FTB logs
* /home/docker/mods/ Mod folder
* /home/docker/server.properties
* /home/docker/config.sh your personal config
* /home/addOp.sh script you can use for adding op.

### add Operator
You can use the ingame command, if you don't like it:
`docker exec "CONTAINER" /home/addOp.sh "uuid" "name" "level" "bypassesPlayerLimit"`
* uuid can be empty, will be resolved
* name is needed
* level if unset 4
* bypassesPlayerLimit if unset true
* docker restart CONTAINER needed

### Use your existing server.properties
0. Step 1 & 2 can be done with copyToVolume.sh from tools section on git.
1. Create a volume where "server.properties" is at root location.
2. Set uid gid permissions on 10000.
3. start container with volume and `-e OVERWRITE_PROPERTIES=false`


### persistent files on update
* banned-ips.json
* banned-players.json
* config.sh (if existing)
* ops.json
* server.properties
* usercache.json
* usernamecache.json
* whitelist.json

### cleared on update
* mods/\*
* config/\*
* scripts/\*
* structures/\*

### migrate server
You can use copyToVolume.sh from tools section on git. Examples below will result in a ready to go volume named "NewMCVolume". Download copyToVolume.sh, script is ash / bash compatible and only needs docker, no bind mount perm. needed.

|Migration current status|Needed|Command|Result|
|-|-|-|-|
|Existing volume with your server files. Files are at VOLUME/server.properties|Name of the volume, MyMCVolume.|`bash copyToVolume.sh MyMCVolume volume NewMCVolume 10000 10000`|NewMCVolume is ready to go|
|Existing folder at host. Files are at FOLDER/server.properties|Path to the folder, /home/jusito/MCServer/server.properties.|`bash copyToVolume.sh '/home/jusito/MCServer/*' path NewMCVolume 10000 10000`|NewMCVolume is ready to go|

### Own Scripts
* /home/docker/config.sh, care because only alpine + busybox, no Bash, no PCRE

### Minecraft related
* [Set server image](https://www.spigotmc.org/threads/how-to-add-a-server-icon-to-your-server-1-7-1-8.6564/)
* [MOTD colors](https://www.minecraftforum.net/forums/support/server-support-and/1940468-how-to-add-colour-to-your-server-motd)
* [Whitelist usage ingame](https://minecraft.gamepedia.com/Commands/whitelist)
* [Op usage ingame](https://minecraft.gamepedia.com/Commands/op)

### Resources needed / Problem resolve
4GB RAM and 4 CPUs with lower priority should be enough on a small server. In general you should set a container limit for CPU / RAM. `--memory="4096m" --cpu-shares=1024 --cpus=4 --blkio-weight 125` If you use this, with the help of OpenJDK you can replace options like `-Xmx4G -XX:ParallelGCThreads=5 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10` with `-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap` [OpenJDK Make JVM respect CPU and RAM limits](https://hub.docker.com/_/openjdk) OpenJDK will then make optimal use of the resources.

To understand whats wrong with your performance, you should know that the Garbage Collector (GC) in Java 8 stops everything if working. Thats because the default GC is for throughput not low latency, the default one in Java 8 is using only one thread for this. For example if you see lags ingame, like Mobs stopping for a second and are instant at your location, your problem is the GC. [Java Low Latency](https://themindstorms.wordpress.com/2009/01/21/advanced-jvm-tuning-for-low-pause/) If the lag occures like every second, you need more RAM `-Xms -Xmx`. If the lag isn't every second but very long, you want better multithreading for GC `-XX:+UseParNewGC` (FTB recommends this) or `-XX:+UseG1GC` (Oracle recommends this [Oracle](https://docs.oracle.com/cd/E40972_01/doc.70/e40973/cnf_jvmgc.htm#autoId2)). This is basic stuff ofc there is a lot more, just search for "jvm low latency".


## Is this working?
The label at the top of this document updates every week. If you want to test it on your own:
1. Clone Repository & install shellcheck
2. Navigate to root dir of repo
3. [Optional] Create Dockerfile for your modpack, just copy another FTB Dockerfile (if jar see vanilla, if zip see others, twitch forge see RLCraft), replace download & md5
4. bash test/testCaseQuick.sh "Vanilla-1.15.2" or bash test/testCaseAll.sh
5. [Optional] If you want more details, `export DEBUGGING=true` (xtrace activated everywhere)

Hint: If you want to test Modpack A in Version B, Dockerfile should be at "modpacks/A/B/Dockerfile" and you can test it with `bash test/testCaseQuick.sh "A-B"`. For A:=Vanilla and B:=1.15.2 this would be "modpacks/Vanilla/1.15.2/Dockerfile" and image name used for testing  "Vanilla-1.15.2".

## FTP Server
* If your Volume is `MyMinecraftVolume`
* If you didn't change UserID / GroupID
* If you want to connect to ftp://...:123 (ports 122/123 are free on your network)

### For FileZilla

```
docker run -d \
 -e MY_NAME="docker" -e MY_PASSWORD="MySecurePW" \
 -e MY_USER_ID="10000" -e MY_GROUP_ID="10000" \
 -p 122:20 -p 123:21 -p 10090-10100:10090-10100 \
 -v MyMinecraftVolume:/home/docker/ \
 jusito/vsftpd-alpine:simple
```

### For Windows Network Mount
* IP of the Host (not container) 1.2.3.4
* Mount: ftp://1.2.3.4:123

```
docker run -d \
 -e MY_NAME="docker" -e MY_PASSWORD="MySecurePW" \
 -e MY_USER_ID="10000" -e MY_GROUP_ID="10000" \
 -p 122:20 -p 123:21 -p 10090-10100:10090-10100 \
 -v MyMinecraftVolume:/home/docker/ \
 -e pasv_address="1.2.3.4" \
 jusito/vsftpd-alpine:simple
```

## Contributing / Requesting
Create a git issue or see maintainer label, I don't check everytime for newer version but I can easily push a new tag

## Acknowledgments
* [PurpleBooth@github Docker Template](https://gist.github.com/PurpleBooth/ea518ae68a49029bae95 "Template-README-for-containers.md")
* [jamietech@github MC server status](https://github.com/jamietech/MinecraftServerPing)
* [Valiano@stackoverflow ash grep behaviour](https://stackoverflow.com/questions/54572688/different-behaviour-of-grep-with-pipe-from-nc-on-alpine-vs-ubuntu)
* Every mod / modpack creator, you sacrifice a lot of free time for our free time, thank you! Especially DDSS hooked me.