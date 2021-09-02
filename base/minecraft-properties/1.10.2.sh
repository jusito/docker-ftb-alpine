#!/bin/bash

patternBoolean="^(true|false)$"

function setServerProperties_1.10.2() {
  export SERVER_PROPERTIES_CONFIG=(
    "allow-flight" "$patternBoolean" "false"
    "allow-nether" "$patternBoolean" "true"
    "broadcast-console-to-ops" "$patternBoolean" "true"
    "difficulty" "^([0-3]|peaceful|easy|normal|hard)$" "1"
    "enable-command-block" "$patternBoolean" "false"
    "enable-jmx-monitoring" "$patternBoolean" "false"
    "enable-query" "$patternBoolean" "false"
    "enable-rcon" "$patternBoolean" "false"
    "enable-status" "$patternBoolean" "true"
    "entity-broadcast-range-percentage" "^([0-9]|[1-9][0-9]|[1-4][0-9][0-9]|500)$" "100"
    "enforce-whitelist" "$patternBoolean" "false"
    "force-gamemode" "$patternBoolean" "false"
    "function-permission-level" "^[1-4]$" "2"
    "gamemode" "^([0-3]|survival|creative|adventure|spectator)$" "0"
    "generate-structures" "$patternBoolean" "true"
    "generator-settings" "^.*$" "" #if user is setting this, he knows what he does
    "hardcore" "$patternBoolean" "false"
    "level-name" "^[a-zA-Z0-9]([ a-zA-Z0-9]*[a-zA-Z0-9])?$" "world"
    "level-seed" "^.*$" ""
    "level-type" "^.+$" "DEFAULT" # not matching mod types: (DEFAULT|FLAT|LARGEBIOMES|AMPLIFIED|BUFFET)
    "max-build-height" "^[0-9]+$" "256"
    "max-players" "^[1-9][0-9]*$" "20"
    "max-tick-time" "^(-1|[0-9]+)$" "60000"
    "max-world-size" "^[0-9]+$" "29999984"
    "motd" "^.*$" "A Minecraft Server"
    "network-compression-threshold" "^(-1|[0-9]+)$" "256"
    "online-mode" "$patternBoolean" "true"
    "op-permission-level" "^[1-4]$" "4"
    "player-idle-timeout" "^[0-9]+$" "0"
    "prevent-proxy-connections" "$patternBoolean" "false"
    "pvp" "$patternBoolean" "true"
    "query.port" "^[1-9][0-9]*$" "25565"
    "rate-limit" "^[0-9]+$" ""
    "rcon.password" "^.*$" ""
    "rcon.port" "^[1-9][0-9]*$" "25575"
    "resource-pack" "^.*$" ""
    "resource-pack-sha1" "^.*$" "" #TODO correct pattern
    "server-ip" "^.*$" "" #TODO correct pattern
    "server-port" "^[1-9][0-9]*$" "25565"
    "snooper-enabled" "$patternBoolean" "true"
    "spawn-animals" "$patternBoolean" "true"
    "spawn-monsters" "$patternBoolean" "true"
    "spawn-npcs" "$patternBoolean" "true"
    "spawn-protection" "^[0-9]+$" "16"
    "sync-chunk-writes" "$patternBoolean" "true"
    "view-distance" "^([3-9]|1[0-5])$" "10"
    "white-list" "$patternBoolean" "false")
}
