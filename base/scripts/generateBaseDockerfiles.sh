#!/bin/bash

readonly TARGET_MC_VERSION="1.16.5"
readonly CONFIG=(
  "8jre/alpine/hotspot"
    "adoptopenjdk/openjdk8:alpine-jre"
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCGroupMemoryLimitForHeap"
  "8jre/alpine/openj9"
    "adoptopenjdk/openjdk8-openj9:alpine-jre"
    "-Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -Xtune:virtualized"
  "11jre/alpine/hotspot"
    "adoptopenjdk/openjdk11:alpine-jre"
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCGroupMemoryLimitForHeap"
  "11jre/alpine/openj9"
    "adoptopenjdk/openjdk11-openj9:alpine-jre"
    "-Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -Xtune:virtualized"
  "16jre/alpine/hotspot"
    "adoptopenjdk/openjdk16:alpine-jre"
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCGroupMemoryLimitForHeap"
  "16jre/alpine/openj9"
    "adoptopenjdk/openjdk16-openj9:alpine-jre"
    "-Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -Xtune:virtualized"
)

pwd_old="$(realpath "$(pwd)")"
cd "$(dirname "$0")/.."
# setup server.properties
for script_file in ./minecraft-properties/*; do
  # shellcheck disable=SC1090
  . "$script_file"
done
loadServerPropertyConfig "$TARGET_MC_VERSION" || ( echo "failed to load minecraft config" && exit 10)
dockerServerProperties=()
for property_index in $(seq 0 3 "$(("${#SERVER_PROPERTIES_CONFIG[@]}" - 1))"); do
  property="${SERVER_PROPERTIES_CONFIG["$property_index"]}"
  value="${SERVER_PROPERTIES_CONFIG[$((property_index + 2))]}"
  dockerServerProperties+=("$(propertyLineToDocker "$property" "$value" "=" "\"")")
done

# shellcheck disable=SC2207
IFS=$'\n' dockerServerProperties=( $( grep -o "\S*=\"[^\"]*\"" <<< "${dockerServerProperties[@]}" | sort | uniq ) )
dockerServerProperties_string="$({
  property_count="${#dockerServerProperties[@]}"
  for property_index in $(seq 0 1 "$((property_count - 1))"); do
    if [ "$property_index" -lt "$((property_count - 1))" ]; then
      echo "    ${dockerServerProperties["$property_index"]} \\"
    else
      echo "    ${dockerServerProperties["$property_index"]}"
    fi
  done
})"
cd "$pwd_old"

set -o errexit
set -o nounset
set -o pipefail

(
  cd "$(dirname "$0")/.."

  # load checkHealth
  checkhealth_sha3="$(sha3sum ./scripts/checkHealth.sh | grep -Eo '^\S*' )"

  date="$(date +%Y%m%d)"

  for base_index in $(seq 0 3 "$(( ${#CONFIG[@]} - 1 ))"); do
    base_path="${CONFIG[$base_index]}"
    base_from="${CONFIG[$(("$base_index" + 1))]}"
    JAVA_PARAMETERS="${CONFIG[$(("$base_index" + 2))]}"

    mkdir -p "$base_path" || true
cat > "$base_path/Dockerfile" <<- EOM
FROM $base_from

LABEL version="$date" \\
  maintainer="docker-minecraft+$date@mail.jusito.de"

EXPOSE 25565/tcp

ENV MY_GROUP_ID=10000 \\
    MY_USER_ID=10000 \\
    MY_NAME="docker" \\
    MY_HOME="/home/docker" \\
    MY_VOLUME="/home/docker" \\
    MY_FILE="Server.zip" \\
    MY_SERVER="" \\
    MY_MD5="" \\
    SERVER_QUERY_PIPE="/home/query.pipe" \\
    \\
# for CI needed
    TEST_MODE="" \\
    STARTUP_TIMEOUT=600 \\
    \\
# changeable by user
    HEALTH_URL="127.0.0.1" \\
    HEALTH_PORT="" \\
    FORCE_DOWNLOAD="false" \\
    JAVA_PARAMETERS="$JAVA_PARAMETERS" \\
    OVERWRITE_PROPERTIES="true" \\
    ADMIN_NAME="" \\
    DEBUGGING=false \\
    ROOT_IN_MODPACK_ZIP="" \\
    MINECRAFT_VERSION="" \\
    FORGE_VERSION="" \\
    CLEANUP_PATHS="mods config scripts structures libraries resources" \\
    PERSISTENT_PATHS="banned-ips.json banned-players.json config.sh ops.json server.properties usercache.json usernamecache.json whitelist.json" \\
    \\
# server.properties
$dockerServerProperties_string

COPY ["base/minecraft-properties/", "/home/minecraft-properties/" ]
COPY ["base/scripts/entrypoint.sh", "base/scripts/checkHealth.sh", "base/scripts/entrypointTestMode.sh", "base/scripts/addOp.sh", "base/scripts/serverQuery.sh", "/home/" ]

RUN apk update && \\
    apk add --no-cache ca-certificates bash && \\
# create user
    addgroup -g "\${MY_GROUP_ID}" "\${MY_NAME}" && \\
    adduser -h "\${MY_HOME}" -g "" -s "/bin/false" -G "\${MY_NAME}" -D -u "\${MY_USER_ID}" "\${MY_NAME}" && \\
# add permissions to all in /home
    chown -R "\${MY_NAME}:\${MY_NAME}" "/home" && \\
    chmod -R u=rwx,go= "/home" && \\
# remove temp files
    apk del --quiet --no-cache --progress --purge && \\
    rm -rf /var/cache/apk/* && \\
# create symlinks for easy usage
    ln -s "/home/serverQuery.sh" "/usr/local/bin/query" && \\
    ln -s "/home/addOp.sh" "/usr/local/bin/addop"

VOLUME "\$MY_HOME"

ENTRYPOINT ["bash", "/home/entrypoint.sh"]

USER "\${MY_USER_ID}:\${MY_GROUP_ID}"

# retry default is 3
# check integrity of checkHealth.sh
# execute sh
HEALTHCHECK --interval=10s --timeout=610s CMD \\
    sha3sum "/home/checkHealth.sh" | grep -Eq '^${checkhealth_sha3}\s' && \\
    sh /home/checkHealth.sh
EOM
  done

)