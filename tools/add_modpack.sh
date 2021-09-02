#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# sudo apt-get update
# sudo apt-get install -y unzip grep

## prepare section
readonly download_link="$([ -f "$1" ] && realpath "$1" || echo "$1")"
readonly script_location="$(realpath "$(dirname "$0")")"
readonly VERBOSE=false

properties_config="$(realpath "$script_location/../base/minecraft-properties/")"
for script_file in "$properties_config"/*; do
  "$VERBOSE" && echo "[add_modpack][DEBUG] including $script_file"
  . "$script_file"
done


function resolveVariable() {
  var="$1"

  for exe in $(find ./* -maxdepth 0 -iname "*.sh" ) $(find ./* -maxdepth 0 -iname "*.bat" ); do
    if grep -qP "(?<=$var=).*" "$exe"; then
      grep -oP "(?<=$var=)[^#]*" "$exe" | tr -d '"'"'" | sed -E 's/\s*(.+?)\s*/\1/'
      return 0
    fi
  done
}

function resolveVariablesInString() {
    string="$1"

    for var in $(grep -Po '((?<!\\)$[a-zA-Z0-9_]+|(?<!\\)$\{[^}]+\}|(?<!%)%[a-zA-Z0-9_]+%|)' <<< "$string" | sort | uniq); do
      # shellcheck disable=SC2016
      var_name="$(tr -d '${}%' <<< "$var")" # extract name from: $var ${var} %var%
      replace="$(resolveVariable "$var_name")"
      string="${string//$var/$replace}"
    done

    echo "$string"
}

function getArgumentFromString() {
  arg="$1"
  string="$2"
  onlyArgumentValue="$3"
  ret=""

  # if arg is part of string
  if grep -qP "(?i)$arg\S+" <<< "$string"; then
    # extract it
    ret="$(grep -Po "(?i)$arg\S+" <<< "$string")"
    # remove argument name
    if [ "$onlyArgumentValue" == "only_arg_value" ]; then
      ret="${ret:${#arg}}"
    fi
    # sanitize escaping
    ret="$(sed -E "s/[\"']*([^\"']*)[\"']*/\1/" <<< "$ret")"
  fi

  echo "$ret"
}

(
  readonly tmp="$(mktemp -d)"
  cd "$tmp"



  ## get URL
  URL=""
  if [ -f "$download_link" ]; then
    cp "$download_link" "server.zip"
  else
    URL="$download_link"
    wget -O "server.zip" "$download_link"
  fi
  echo "[add_modpack][INFO] URL=$URL"
  "$VERBOSE" && echo ""



  ## get md5
  readonly MD5="$(md5sum "server.zip" | grep -Eo '^[0-9a-f]*')"
  echo "[add_modpack][INFO] MD5=$MD5"
  unzip -o server.zip &>> /dev/null
  "$VERBOSE" && echo ""


  ## check root in modpack
  ROOT_IN_MODPACK_ZIP=""
  if [ "$(find ./* -maxdepth 0 -type d | wc -l)" -eq "1" ]; then
    cd "$(find ./* -maxdepth 0 -type d)"
    ROOT_IN_MODPACK_ZIP="${PWD##*/}"
  fi
  echo "[add_modpack][INFO] ROOT_IN_MODPACK_ZIP=$ROOT_IN_MODPACK_ZIP"

  ## find mc/forge version
  MC_VERSION=""
  FORGE_VERSION=""
  #shellcheck disable=SC2044
  for jar in $(find . -type f -iname "*.jar" ! -iwholename "*/mods/*"); do
    name="$(grep -oP "(?<=/)[^/]*$" <<< "$jar")"
    if grep -qP "^[a-zA-Z]*-[0-9.]*-[0-9]{1,2}\.[0-9]*[0-9].*.jar" <<< "$name"; then
      "$VERBOSE" && echo -en "\n\n\n"
      "$VERBOSE" && echo "[add_modpack][DEBUG] checking possible forge jar $jar"

      PREFIX="$(grep -o "^[a-zA-Z]*" <<< "$name")"
      MC_VERSION_new="$(grep -Po "(?<=$PREFIX-)[0-9.]*" <<< "$name")"
      FORGE_VERSION_new="$(grep -Po "(?<=$PREFIX-$MC_VERSION_new-)[0-9.]*[0-9]" <<< "$name")"

      # is one info missing
      if [ -z "$MC_VERSION_new" ] || [ -z "$FORGE_VERSION_new" ]; then
        echo "[add_modpack][INFO] couldnt extract MC / Forge version, skipping file"

      # could extract info and no global set
      elif [ -z "$MC_VERSION" ]; then
        MC_VERSION="$MC_VERSION_new"
        FORGE_VERSION="$FORGE_VERSION_new"

      elif [ "$MC_VERSION" != "$MC_VERSION_new" ]; then
        echo "[add_modpack][WARNING] found multiple MC versions $MC_VERSION vs $MC_VERSION_new"

      elif [ "$FORGE_VERSION" != "$FORGE_VERSION_new" ]; then
        echo "[add_modpack][WARNING] found multiple forge versions $FORGE_VERSION vs $FORGE_VERSION_new"

      # else info are already set and identical = all fine
      fi
    fi
  done
  echo "[add_modpack][INFO] MC_VERSION=$MC_VERSION"
  echo "[add_modpack][INFO] FORGE_VERSION=$FORGE_VERSION"
  if [ -z "$MC_VERSION" ]; then
    echo "[add_modpack][ERROR] couldn't get mc version"
  elif [ -z "$FORGE_VERSION" ]; then
    echo "[add_modpack][ERROR] couldn't get forge version"
  fi



  # server properties
  "$VERBOSE" && echo -en "\n\n\n"
  if [ -z "$MC_VERSION" ]; then
    echo "[add_modpack][ERROR] skipping server.properties because no MC_VERSION"

  elif [ -f "server.properties" ]; then
    echo "[add_modpack][INFO] found server.properties"

    if command eval "setServerProperties_$MC_VERSION"; then
      echo "[add_modpack][INFO] loading properties $properties_config"

      readServerPropertiesToVariable "server.properties"
      validateServerPropertiesVariable "fix_illegal"

      #for p in "${SERVER_PROPERTIES_MINIMAL[@]}"; do
      #  echo "> $p"
      #done
    else
      echo "[add_modpack][WARNING] no properties configuration found for given minecraft version"
    fi

  else
    echo "[add_modpack][WARNING] no server.properties"
  fi


  ## preprocessor, try to remove variables
  for exe in $(find ./* -maxdepth 0 -iname "*.sh" ) $(find ./* -maxdepth 0 -iname "*.bat" ); do
    "$VERBOSE" && echo "[add_modpack][DEBUG] checking $exe"
    for var in $(grep -Po '((?<!\\)\$[a-zA-Z0-9_]+|(?<!\\)\$\{[^}]+\}|(?<!%)%[a-zA-Z0-9_]+%)' "$exe" | sort | uniq); do
      s_var="$(tr -d '${}%' <<< "$var")"
      "$VERBOSE" && echo "[add_modpack][DEBUG] resolving $var / $s_var"
      replace="$(resolveVariable "$s_var")"
      if [ -n "$replace" ]; then
        # sed sanitize
        replace="${replace//\//\\\/}"
        replace="${replace//\$/\\\$}"
        "$VERBOSE" && echo "[add_modpack][DEBUG] variable: $var -> $replace"
        sed -i "s/$var/$replace/g" "$exe"
      else
        echo "[add_modpack][WARNING] variable: $var unresolved"
      fi
    done
  done


  # extract JVM args
  JAVA_PARAMETERS=""
  JAVA_CALL=""
  for exe in $(find ./* -maxdepth 0 -iname "*.sh" ) $(find ./* -maxdepth 0 -iname "*.bat" ); do
    "$VERBOSE" && echo -en "\n\n\n"
    "$VERBOSE" && echo "[add_modpack][DEBUG] checking $exe"

    # check for java parameters
    if grep -q 'JAVA_PARAMETERS=["'\'']' "$exe"; then
      if [ -z "$JAVA_PARAMETERS" ]; then
        JAVA_PARAMETERS="$(grep -Po '(?<=JAVA_PARAMETERS=["'\''])[^"'\'']*' "$exe")"
        JAVA_PARAMETERS="${JAVA_PARAMETERS//#*/}"
        "$VERBOSE" && echo "[add_modpack][DEBUG] contains JAVA_PARAMETERS=$JAVA_PARAMETERS"
      else
        echo "[add_modpack][WARNING] skipping because JAVA_PARAMETERS already set"
      fi
    fi

    # check for java ... -jar invocations
    if grep -qP 'java[^#]*-jar' "$exe"; then
      if [ -z "$JAVA_CALL" ]; then
        # get java ... -jar line
        JAVA_CALL="$(grep -Eo '^.*java[^#]*-jar' "$exe")"
        # extract line between java ... -jar
        JAVA_CALL="$(sed -E 's/^[^#]*java\S*\s+([^#]*)-jar/\1/' <<< "$JAVA_CALL")"
        # remove -server
        JAVA_CALL="$(sed -E 's/^(\s?)-server(\s)/\1\2/g' <<< "$JAVA_CALL")"
        # trim whitespaces
        JAVA_CALL="$(sed -E 's/^\s*(.*?)\s*$/\1/' <<< "$JAVA_CALL")"

        "$VERBOSE" && echo "[add_modpack][DEBUG] $exe contains java call with arguments $JAVA_CALL"
        if grep -q "^\s*$" <<< "$JAVA_CALL"; then
          JAVA_CALL=""
        fi
      else
        echo "[add_modpack][WARNING] skipping $exe because JAVA_CALL already set"
      fi
    fi
  done
  JAVA_PARAMETERS="$(resolveVariablesInString "$JAVA_PARAMETERS")"
  echo "[add_modpack][INFO] resolved variables in $JAVA_PARAMETERS"
  JAVA_CALL="$(resolveVariablesInString "$JAVA_CALL")"
  echo "[add_modpack][INFO] resolved variables in $JAVA_CALL"
  if grep -Fq "$JAVA_PARAMETERS" <<< "$JAVA_CALL" &>> /dev/null; then
    echo "[add_modpack][INFO] parameters aren't part of call -> injecting"
    JAVA_CALL="$JAVA_CALL $JAVA_PARAMETERS"
  else
    echo "[add_modpack][INFO] parameters are already part of call"
  fi

  # check for min ram
  arg="-xms"
  JAVA_MEM_MIN="$(getArgumentFromString "$arg" "$JAVA_CALL" "only_arg_value")"
  if ! grep -qE '^[0-9]+[mMgG]$' <<< "$JAVA_MEM_MIN"; then
    echo "[add_modpack][WARNING] resolving $arg failed"
    JAVA_MEM_MIN=""
  fi
  echo "[add_modpack][INFO] $arg refers to $JAVA_MEM_MIN"

  # check for max ram
  arg="-xmx"
  JAVA_MEM_MAX="$(getArgumentFromString "$arg" "$JAVA_CALL" "only_arg_value")"
  CONTAINER_MEMORY_LIMIT=""
  if ! grep -qE '^[0-9]+[mMgG]$' <<< "$JAVA_MEM_MAX"; then
    echo "[add_modpack][WARNING] resolving $arg failed"
    JAVA_MEM_MAX=""
  else
    # container limit should be around 20% higher
    max_mem="$(grep -Eo '[0-9]+' <<< "$JAVA_MEM_MAX") "
    mem_overhead="$((max_mem / 5))"
    if grep -q '[Mm]' <<< "$JAVA_MEM_MAX" && [ "$mem_overhead" -lt "2048" ]; then
      mem_overhead="2048"
    elif grep -q '[Gg]' <<< "$JAVA_MEM_MAX" && [ "$mem_overhead" -lt "2" ]; then
      mem_overhead="2"
    fi
    if grep -q '[Mm]' <<< "$JAVA_MEM_MAX"; then
      CONTAINER_MEMORY_LIMIT="$((max_mem + mem_overhead))M"
    else
      CONTAINER_MEMORY_LIMIT="$((max_mem + mem_overhead))G"
    fi

  fi
  echo "[add_modpack][INFO] $arg refers to $JAVA_MEM_MAX"
  JAVA_CALL="$(sed -E 's/^\s*(.*?)\s*/\1/' <<< "$JAVA_CALL")"



  echo "[add_modpack][INFO] extracting done, generating files"
  {
    echo 'ARG imageSuffix=""'
    echo ''
    echo 'FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"'
    echo ''
    echo "ENV JAVA_PARAMETERS=\"$JAVA_CALL\" \\"
    if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then
      echo "	ROOT_IN_MODPACK_ZIP=\"$ROOT_IN_MODPACK_ZIP\"\\"
    fi
    echo "	\\"
    # TODO custom property support
    #for env in "${SERVER_PROPERTIES_CUSTOM[@]}"; do
    #done
    for env in "${SERVER_PROPERTIES_MINIMAL[@]}"; do
        key="$(grep -Po "^[^= ]*" <<< "$env" | tr '-' '_')"
        value="$(grep -Po "(?<==).*" <<< "$env")"
        echo "	$key=\"$value\" \\"
    done
    echo "	\\"
    echo "	MINECRAFT_VERSION=\"$MC_VERSION\" \\"
    echo "	FORGE_VERSION=\"$FORGE_VERSION\""
    echo ''
    echo "CMD [\"$URL\", \"$MD5\"]"
  } > "$script_location/Dockerfile"

    {
      echo 'services:'
      echo "  minecraft-server:"
      echo "    image: jusito/docker-ftb-alpine:8jre-alpine-hotspot"
      echo "    command: [\"$URL\", \"$MD5\"]"
      echo "    ports:"
      echo "      - 25565:25565"
      echo "    environment:"
      if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then
        echo "      ROOT_IN_MODPACK_ZIP: '$ROOT_IN_MODPACK_ZIP'"
      fi
      echo "      MINECRAFT_VERSION: '$MC_VERSION'"
      echo "      FORGE_VERSION: '$FORGE_VERSION'"
      echo "      JAVA_PARAMETERS: '$JAVA_CALL'"
      echo "      ADMIN_NAME: ''"

      # TODO custom property support
      #for env in "${SERVER_PROPERTIES_CUSTOM[@]}"; do
      #done
      for env in "${SERVER_PROPERTIES_MINIMAL[@]}"; do
          key="$(grep -Po "^[^= ]*" <<< "$env" | tr '-' '_')"
          value="$(grep -Po "(?<==).*" <<< "$env")"
          echo "      $key: '$value'"
      done

      if [ -n "$CONTAINER_MEMORY_LIMIT" ]; then
        echo "    volumes:"
        echo "      - minecraft-server:/home/docker:rw"
        echo "    deploy:"
        echo "      resources:"
        echo "        limits:"
        echo "          memory: $CONTAINER_MEMORY_LIMIT"
        echo ""
        echo "volumes:"
        echo "  minecraft-server:"
      fi

    } > "$script_location/docker-compose.yml"

  cd /tmp && rm -rf "$tmp"
)
