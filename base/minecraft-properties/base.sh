#!/bin/bash

patternBoolean="^(true|false)$"

# TODO announce-player-achievements in 1.12 but can be used prior
export SERVER_PROPERTIES_CONFIG=(
    "allow-flight" "$patternBoolean" "false"
    "allow-nether" "$patternBoolean" "true"
    "broadcast-console-to-ops" "$patternBoolean" "true"
    "difficulty" "^[0-3]$" "1"
    "enable-command-block" "$patternBoolean" "false"
    "enable-jmx-monitoring" "$patternBoolean" "false"
    "enable-query" "$patternBoolean" "false"
    "enable-rcon" "$patternBoolean" "false"
    "enforce-whitelist" "$patternBoolean" "false"
    "force-gamemode" "$patternBoolean" "false"
    "gamemode" "^([0-3]|survival|creative|adventure|spectator)$" "0"
    "generate-structures" "$patternBoolean" "true"
    "hardcore" "$patternBoolean" "false"
    "level-name" "^[a-zA-Z0-9]([ a-zA-Z0-9]*[a-zA-Z0-9])?$" "world"
    "level-seed" "^.*$" ""
    "level-type" "^.+$" "DEFAULT" # not matching mod types: (DEFAULT|FLAT|LARGEBIOMES|AMPLIFIED|BUFFET)
    "max-build-height" "^[0-9]+$" "256"
    "max-players" "^[1-9][0-9]*$" "20"
    "max-tick-time" "^(-1|[0-9]+)$" "60000"
    "max-world-size" "^[1-9][0-9]*$" "29999984"
    "motd" "^.*$" "A Minecraft Server"
    "network-compression-threshold" "^(-1|[0-9]+)$" "256"
    "online-mode" "$patternBoolean" "true"
    "op-permission-level" "^[1-4]$" "4"
    "player-idle-timeout" "^[0-9]+$" "0"
    "pvp" "$patternBoolean" "true"
    "query.port" "^[1-9][0-9]*$" "25565" #TODO correct pattern
    "rcon.password" "^.*$" ""
    "rcon.port" "^[1-9][0-9]*$" "25575" #TODO correct pattern
    "resource-pack" "^.*$" ""
    "resource-pack-sha1" "^.*$" "" #TODO correct pattern
    "server-ip" "^.*$" "" #TODO correct pattern
    "server-port" "^[1-9][0-9]*$" "25565" #TODO correct pattern
    "snooper-enabled" "$patternBoolean" "true"
    "spawn-animals" "$patternBoolean" "true"
    "spawn-monsters" "$patternBoolean" "true"
    "spawn-npcs" "$patternBoolean" "true"
    "spawn-protection" "^[0-9]+$" "16"
    "use-native-transport" "$patternBoolean" "true" # linux only
    "view-distance" "^([3-9]|1[0-5])$" "10"
    "white-list" "$patternBoolean" "false")
