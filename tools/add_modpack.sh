#!/bin/bash
# shellcheck disable=SC2235

set -o errexit
set -o pipefail
set -o nounset

# sudo apt-get update
# sudo apt-get install -y unzip grep

## prepare section
readonly download_link="$([ -f "$1" ] && realpath "$1" || echo "$1")"
readonly script_location="$(realpath "$(dirname "$0")")"
VERBOSE=false

properties_config="$(realpath "$script_location/../base/minecraft-properties/")"
for script_file in "$properties_config"/*; do
  "$VERBOSE" && echo "[add_modpack][DEBUG] including $script_file"
  # shellcheck disable=SC1090
  . "$script_file"
done

function getConfigFiles() {
  find ./* -maxdepth 0 -iname "*.bat" -print
  find ./* -maxdepth 0 -iname "*.sh" -print
  find ./* -maxdepth 0 -iname "*.txt" -print
  find ./* -maxdepth 0 -iname "*.cfg" -print
}


function resolveVariable() {
  var="$1"

  #var="${var//?/\\?}"
  #var="${var//+/\\+}"
  #var="${var//\*/\\*}"

  for exe in $(getConfigFiles); do
    if grep -qP "(?<=$var=).*" "$exe"; then
      results="$(grep -m 1 -oP "(?<=$var=)[^#]*" "$exe" | tr -d '\r\n')"

      # trim whitespaces: .."asd"... -> "asd"
      results="$(sed -E 's/^\s*//' <<< "$results" | sed -E 's/\s*$//')"

      # trim "content" and 'content' -> content
      results="$(sed -E "s/^(\"|')(.+?)(\1)/\2/" <<< "$results")"

      echo "$results"
      break # skip other files
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
  MODE=""
  FILE=""
  if [ -f "$download_link" ]; then
    cp "$download_link" "server.zip"
    NAME="$(basename "$download_link")"
    FILE="$download_link"
    MODE="zip"
  else
    URL="$download_link"
    #NAME="$(wget --server-response -q "$download_link" --spider 2>&1 | grep -oP '(?<=filename=")[^"]*')"
    #wget -O "$NAME" "$download_link"
    NAME="$(wget "$download_link" --content-disposition 2>&1 | grep -oP '(?<=Saving to: .)[a-zA-Z0-9_.%+-\[\]]*')"
    cp -f "$NAME" "$script_location/"
    if grep -q 'serverinstall_[0-9]*_[0-9]*' <<< "$NAME"; then
      echo "[add_modpack][INFO] found FTB modpack"
      id="$(grep -oP '(?<=serverinstall_)[0-9]*' <<< "$NAME")"
      version="$(grep -oE "[0-9]*$" <<< "$NAME")"
      MODE="FTB"
      chmod +x "$NAME"
      FILE="$NAME"
      NAME="$(wget -O - "https://api.modpacks.ch/public/modpack/$id" | jq -r '.name')-$(wget -O - "https://api.modpacks.ch/public/modpack/$id/$version" | jq -r '.name')"
    else
      MODE="zip"
      FILE="server.zip"
      mv "$NAME" "$FILE"
    fi
  fi
  echo "[add_modpack][INFO] name=$NAME"
  if [ "${#NAME}" -le "6" ]; then
    NAME="minecraft-server"
  elif [ "$MODE" != "FTB" ]; then
    NAME="${NAME::-4}" # remove zip
  fi
  NAME="$(sed -E 's/^[^a-zA-Z0-9]*(.*)$/\1/' <<< "${NAME//[^a-zA-Z0-9_.-]/_}")" # replace illegal signs with _ and ensure valid start
  NAME="$(sed -E 's/[_]+/_/g' <<< "$NAME")"
  NAME="$(sed -E 's/_*$//' <<< "$NAME")"
  NAME="$(tr '[:upper:]' '[:lower:]' <<< "$NAME")" # all lower case
  echo "[add_modpack][INFO] URL=$URL"
  "$VERBOSE" && echo ""



  ## get md5
  readonly MD5="$(md5sum "$FILE" | grep -Eo '^[0-9a-f]*')"
  echo "[add_modpack][INFO] MD5=$MD5"
  "$VERBOSE" && echo ""


  ## check root in modpack
  ROOT_IN_MODPACK_ZIP=""
  if [ "$MODE" = "zip" ]; then
    unzip -o "$FILE" &>> /dev/null
    if [ "$(find ./* -maxdepth 0 -type d | wc -l)" -eq "1" ]; then
      cd "$(find ./* -maxdepth 0 -type d)"
      ROOT_IN_MODPACK_ZIP="${PWD##*/}"
    fi
    echo "[add_modpack][INFO] ROOT_IN_MODPACK_ZIP=$ROOT_IN_MODPACK_ZIP"
  elif [ "$MODE" = "FTB" ]; then
    ./"$FILE" --auto
  fi


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
    MC_VERSION="ERROR_FILL_MANUALLY"
  fi
  if [ -z "$FORGE_VERSION" ]; then
    echo "[add_modpack][ERROR] couldn't get forge version"
    FORGE_VERSION="ERROR_FILL_MANUALLY"
  fi



  # server properties
  "$VERBOSE" && echo -en "\n\n\n"
  if [ -z "$MC_VERSION" ]; then
    echo "[add_modpack][ERROR] skipping server.properties because no MC_VERSION"

  elif ! loadServerPropertyConfig "$MC_VERSION"; then
    echo "[add_modpack][ERROR] failed to load server.property configuration for minecraft version: $MC_VERSION"

  elif [ -f "server.properties" ]; then
    echo "[add_modpack][INFO] found server.properties"

    readServerProperties_fromFile_toVariable "server.properties"
    validateServerPropertiesVariable "fix_illegal"

  else
    echo "[add_modpack][WARNING] no server.properties, looking for txt files "
    # shellcheck disable=SC2207
    IFS=$'\n' properties=($(getOriginalPropertyKeys))
    while IFS= read -r -d '' file
    do
      for property in "${properties[@]}"; do
        if grep -qE "^\s*$property=" "$file" &>> /dev/null; then

          match="$(grep --max-count=1 -E "^\s*$property=.*" "$file" | tr -d $'\r'$'\n')"
          addProperty "$property" "${match//*=/}"
        fi
      done
    done < <(find ./* -maxdepth 0 -type f -iname "*.txt" -print0)
    validateServerPropertiesVariable "fix_illegal"
  fi


  ## preprocessor, try to remove variables
  for config in $(getConfigFiles); do
    echo "[add_modpack][DEBUG] checking $config"
    for var in $(grep -Po '((?<!\\)\$[a-zA-Z0-9_]+|(?<!\\)\$\{[^}]+\}|(?<!%)%[a-zA-Z0-9_]+%)' "$config" | sort | uniq); do
      "$VERBOSE" && echo -e '\n\n\n'
      # shellcheck disable=SC2016
      s_var="$(tr -d '${}%' <<< "$var")"
      "$VERBOSE" && echo "[add_modpack][DEBUG] resolving $var / $s_var"

      # remove e.g. ${var:0:1}
      s_var="$(sed -E 's/^([a-zA-Z0-9_]+).*/\1/' <<< "$s_var")"
      replace="$(resolveVariable "$s_var")"

      if [ -n "$replace" ]; then
        # sanitize
        var="${var//\//\\\/}" # sed escape /
        replace="${replace//\//\\\/}" # sed escape /
        "$VERBOSE" && echo "[add_modpack][DEBUG] variable: $var -> $replace"
        sed -i "s/$var/$replace/g" "$config"
      else
        echo "[add_modpack][WARNING] variable: $var unresolved"
      fi
    done
  done


  # extract JVM args
  JAVA_CALL=""
  for exe in $(getConfigFiles); do
    "$VERBOSE" && echo -en "\n\n\n"
    "$VERBOSE" && echo "[add_modpack][DEBUG] checking $exe"

    # check for java ... -jar invocations
    # shellcheck disable=SC2207
    IFS=$'\n' JAVA_INVOCATIONS=( $(grep -P 'java[^#]*-jar' "$exe" || true) )
    for java_invocation in "${JAVA_INVOCATIONS[@]}"; do
      "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $java_invocation"
      # skip forge invocations
      if ! grep -q -e '--installServer' <<< "$java_invocation"; then
        "$VERBOSE" && echo "[add_modpack][DEBUG] found minecraft server invocation"
        if [ -z "$JAVA_CALL" ]; then
          ! "$VERBOSE" && echo "[add_modpack][INFO] found minecraft server invocation: $java_invocation"
          # get all after java ...
          JAVA_CALL="$(sed -E 's/^.*java\s(.*)/\1/' <<< "$java_invocation")"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"
          # remove -jar
          JAVA_CALL="$(sed -E 's/(^|\s)-jar/\1/g' <<< "$JAVA_CALL")"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"
          # remove -server
          JAVA_CALL="$(sed -E 's/(^|\s)-server/\1/g' <<< "$JAVA_CALL")"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"
          # remove unresolved variables
          JAVA_CALL="$(sed -E 's/\S*[$%][{}a-zA-Z0-9_%]*//g' <<< "$JAVA_CALL")"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"
          # remove non java argument
          # assuming every argument starting with -
          JAVA_CALL="$(sed -E 's/(^|\s)[^- ]\S*//g' <<< "$JAVA_CALL")"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"
          # trim whitespaces
          JAVA_CALL="$(sed -E 's/^\s*//' <<< "$JAVA_CALL" | sed -E 's/\s*$//')"
          "$VERBOSE" && echo "[add_modpack][DEBUG] invocation: $JAVA_CALL"

          "$VERBOSE" && echo "[add_modpack][DEBUG] $exe contains java call with arguments $JAVA_CALL"
          if grep -q "^\s*$" <<< "$JAVA_CALL"; then
            JAVA_CALL=""
          fi
        else
          "$VERBOSE" && echo "[add_modpack][WARNING] skipping $exe because JAVA_CALL already set"
        fi
      fi
    done
  done
  #JAVA_PARAMETERS="$(resolveVariablesInString "$JAVA_PARAMETERS")"
  #echo "[add_modpack][INFO] resolved variables in $JAVA_PARAMETERS"
  JAVA_CALL="$(resolveVariablesInString "$JAVA_CALL")"
  echo "[add_modpack][INFO] extracted java parameters $JAVA_CALL"

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
  echo "[add_modpack][INFO] extracting done"





  ###################
  # generating output
  ###################
  #8jre-alpine-hotspot
  echo "[add_modpack][INFO] generating files"
  {
    echo 'ARG imageBase='8jre-alpine-hotspot''
    echo "ARG imageSuffix=''"
    echo ''
    # shellcheck disable=SC2016
    echo 'FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"'
    echo ''
    if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then
      echo "ENV	ROOT_IN_MODPACK_ZIP='$ROOT_IN_MODPACK_ZIP' \\"
      echo "	MINECRAFT_VERSION='$MC_VERSION' \\"
    elif [ "$MODE" = "FTB" ]; then
      echo "ENV	MY_FILE='$FILE' \\"
      echo "	MINECRAFT_VERSION='$MC_VERSION' \\"
    else
      echo "ENV	MINECRAFT_VERSION='$MC_VERSION' \\"
    fi
    printf "%s" "	FORGE_VERSION='$FORGE_VERSION' "
    if [ -n "$JAVA_CALL" ]; then
      printf "\\\\\n	%s" "JAVA_PARAMETERS='$JAVA_CALL'"
    fi

    if [ "${#SERVER_PROPERTIES_MINIMAL[@]}" -gt "0" ]; then
      printf "\\\\\n	%s" ""
    fi
    # TODO custom property support
    #for env in "${SERVER_PROPERTIES_CUSTOM[@]}"; do
    #done
    for property_line in "${SERVER_PROPERTIES_MINIMAL[@]}"; do
        printf " \\\\\n %s" "	$(propertyLineToDocker "${property_line//=*/}" "${property_line//*=/}" "=" "'")"
    done
    echo ''
    echo ''
    echo "CMD [\"$URL\", \"$MD5\"]"
  } > "$script_location/Dockerfile"

    {
      echo 'services:'
      echo "  $NAME:"
      echo "    image: jusito/docker-ftb-alpine:8jre-alpine-hotspot"
      echo "    command: ['$URL', '$MD5']"
      echo "    ports:"
      echo "      - 25565:25565"
      echo "    environment:"
      if [ -n "$ROOT_IN_MODPACK_ZIP" ]; then
        echo "      ROOT_IN_MODPACK_ZIP: '$ROOT_IN_MODPACK_ZIP'"
      elif [ "$MODE" = "FTB" ]; then
        echo "      MY_FILE: '$FILE'"
      fi
      echo "      MINECRAFT_VERSION: '$MC_VERSION'"
      echo "      FORGE_VERSION: '$FORGE_VERSION'"
      if [ -n "$JAVA_CALL" ]; then
        echo "      JAVA_PARAMETERS: '$JAVA_CALL'"
      fi
      echo "      ADMIN_NAME: ''"

      # TODO custom property support
      #for env in "${SERVER_PROPERTIES_CUSTOM[@]}"; do
      #done
      for property_line in "${SERVER_PROPERTIES_MINIMAL[@]}"; do
          echo "      $(propertyLineToDocker "${property_line//=*/}" "${property_line//*=/}" ": " "'")"
      done

      echo "    volumes:"
      echo "      - $NAME:/home/docker:rw"
      if [ -n "$CONTAINER_MEMORY_LIMIT" ]; then
        echo "    deploy:"
        echo "      resources:"
        echo "        limits:"
        echo "          memory: $CONTAINER_MEMORY_LIMIT"
      fi
      echo ""
      echo "volumes:"
      echo "  $NAME:"

    } > "$script_location/docker-compose.yml"

  cd /tmp && rm -rf "$tmp"
)
