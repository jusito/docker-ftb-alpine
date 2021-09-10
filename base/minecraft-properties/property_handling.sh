#!/bin/bash
# shellcheck disable=SC2155
#TODO add file description


# check if default configuration contains the given value
function isOriginalProperty() {
  local property="$1"
  local property_index

  for property_index in $(seq 0 3 "$((${#SERVER_PROPERTIES_CONFIG[@]}-1))"); do
    if [ "${SERVER_PROPERTIES_CONFIG["$property_index"]}" == "$property" ]; then
      return 0
    fi
  done
  return 1
}



# READING global SERVER_PROPERTIES_CONFIG
function getPropertyPattern() {
  local property="$1"
  local property_index=0

  for property_index in $(seq 0 3 "$((${#SERVER_PROPERTIES_CONFIG[@]}-1))"); do
    if [ "${SERVER_PROPERTIES_CONFIG["$property_index"]}" == "$property" ]; then
      echo "${SERVER_PROPERTIES_CONFIG["$((property_index+1))"]}"
    fi
  done
}



# READING global SERVER_PROPERTIES_CONFIG
function getPropertyDefault() {
  local property="$1"
  local property_index=0

  for property_index in $(seq 0 3 "$((${#SERVER_PROPERTIES_CONFIG[@]}-1))"); do
    if [ "${SERVER_PROPERTIES_CONFIG["$property_index"]}" == "$property" ]; then
      echo "${SERVER_PROPERTIES_CONFIG["$((property_index+2))"]}"
    fi
  done
}



function isPropertyDefault() {
  local property="$1"
  local value="$2"

  if ! isOriginalProperty "$property"; then
    return 1
  elif [ "$(getPropertyDefault "$property")" != "$value" ]; then
    return 1
  else
    return 0
  fi
}



function isPropertyValueValid() {
  local property="$1"
  local value="$2"

  if ! isOriginalProperty "$property"; then
    return 1
  elif ! grep -qP "$(getPropertyPattern "$property")" <<< "$value"; then
    return 1
  else
    return 0
  fi
}



function overwritePropertyConfig() {
    local property="$1"
    local pattern="$2"
    local default="$3"

    for property_index in $(seq 0 3 "$((${#SERVER_PROPERTIES_CONFIG[@]}-1))"); do
      if [ "${SERVER_PROPERTIES_CONFIG["$property_index"]}" == "$property" ]; then
        SERVER_PROPERTIES_CONFIG["$((property_index+1))"]="$pattern"
        SERVER_PROPERTIES_CONFIG["$((property_index+2))"]="$default"
      fi
    done
}


function addPropertyConfig() {
    local property="$1"
    local pattern="$2"
    local default="$3"
    if isOriginalProperty "$property"; then
      overwritePropertyConfig "$property" "$pattern" "$default"
    else
      SERVER_PROPERTIES_CONFIG+=("$property" "$pattern" "$default")
    fi
}

function addProperty() {
    local property="$1"
    local value="$2"

    local overwritten=false
    for property_index in $(seq 0 1 "$((${#SERVER_PROPERTIES[@]}-1))"); do
      local property_line="${SERVER_PROPERTIES["$property_index"]}"
      if [ "$property" == "${property_line//=*/}" ]; then
        overwritten=true
        SERVER_PROPERTIES["$property_index"]="$value"
        break
      fi
    done

    if ! "$overwritten"; then
      SERVER_PROPERTIES+=("$property=$value")
    fi
}



function getOriginalPropertyKeys() {
  for property_index in $(seq 0 3 "$((${#SERVER_PROPERTIES_CONFIG[@]}-1))"); do
    echo "${SERVER_PROPERTIES_CONFIG["$property_index"]}"
  done
}



SERVER_PROPERTIES=()
# WRITING global SERVER_PROPERTIES
function readServerProperties_fromFile_toVariable() {
  local file="$1"

  echo "[property_handling][INFO] reading from \"$file\""
  # shellcheck disable=SC2207
  IFS=$'\r\n' SERVER_PROPERTIES_new=($(cat "$file"))

  # remove comments from array
  for property in "${SERVER_PROPERTIES_new[@]}"; do
    if grep -q '^[^#=]*=' <<< "$property"; then
      SERVER_PROPERTIES+=("$property")
    fi
  done

  sortServerProperties
}


# WRITING global SERVER_PROPERTIES
function readServerProperties_fromEnvironment_toVariable() {
  local env_var=""

  for property_index in $(seq 0 3 "$(("${#SERVER_PROPERTIES_CONFIG[@]}" - 1))"); do
    property="${SERVER_PROPERTIES_CONFIG["$property_index"]}"
    env_var="${property//-/_}"
    env_var="${env_var//./_}"
    # ! dereference env_var name
    # -"" if unset return empty, else its value
    SERVER_PROPERTIES+=("$property=${!env_var-}")
  done

  sortServerProperties
}



# e.g. allow-flight -> allow_flight
function propertyLineToDocker() {
  local property="$1"
  local value="$2"
  local delimiter="$3" # "=" or ": "
  local stringWrap="$4" # " or '

  property="${property//-/_}"
  property="${property//./_}"

  echo "${property//(-|\\.)/_}$delimiter$stringWrap$value$stringWrap"
}




SERVER_PROPERTIES_MINIMAL=()
SERVER_PROPERTIES_CUSTOM=()
# READING global SERVER_PROPERTIES
# WRITING global SERVER_PROPERTIES, SERVER_PROPERTIES_MINIMAL
function validateServerPropertiesVariable() {
  local fix_illegal="$(grep -q 'fix-illegal' <<< "$@" && echo "false" || echo "true")"

  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[0;33m'
  local NC='\033[0m'

  for property_index in $(seq 0 $(("${#SERVER_PROPERTIES[@]}" - 1))); do
    local property_line="${SERVER_PROPERTIES[$property_index]}"
    local property="${property_line//=*/}"
    local value="${property_line//*=/}"
    local state=""

    if ! isOriginalProperty "$property"; then
      state="CUSTOM"
      echo -n "[property_handling][INFO] "
      echo -en "${YELLOW}($state)${NC}  "
      echo -n "$property=$value - "
      echo -e "${YELLOW}not original property${NC}"

    elif isPropertyDefault "$property" "$value"; then
      state="DEFAULT"
      echo -n "[property_handling][INFO] "
      echo -en "${GREEN}($state)${NC} "
      echo "$property=$value"

    elif isPropertyValueValid "$property" "$value"; then
      state="VALID"
      echo -n "[property_handling][INFO] "
      echo -en "${GREEN}($state)${NC}   "
      echo "$property=$value"

    else
      state="ILLEGAL"
      echo -n "[property_handling][INFO] "
      echo -en "${RED}($state)${NC} "
      echo -n "$property=$value - "
      echo -en "${RED}"
      echo -n "pattern: \"$(getPropertyPattern "$property")\" doesn't match \"$value\""
      echo -en "${NC}"

      if "$fix_illegal"; then
        state="DEFAULT"
        property_line="$property=$(getPropertyDefault "$property")"
        SERVER_PROPERTIES[$property_index]="$property_line"
        echo -en " set to ${GREEN}($state)${NC} "
        echo -n "${SERVER_PROPERTIES[$property_index]}"
      fi
      echo ""
    fi

    if [ "$state" == "CUSTOM" ]; then
      SERVER_PROPERTIES_CUSTOM+=("${SERVER_PROPERTIES[$property_index]}")
    elif [ "$state" != "DEFAULT" ]; then
      SERVER_PROPERTIES_MINIMAL+=("${SERVER_PROPERTIES[$property_index]}")
    fi
  done
}



# WRITING SERVER_PROPERTIES_CONFIG
function loadServerPropertyConfig() {
  # shellcheck disable=SC2207
  IFS=$'\n' local version=( $(grep -o '[0-9]*' <<< "$1" || true) )
  local fallback_minor=12
  local fallback_patch=2

  if [ "${#version[@]}" -eq "3" ] && [ "${version[1]}" -ge "$fallback_minor" ]; then
    local successful=false
    # check if patch config is there
    for patch in $(seq "${version[2]}" -1 "0"); do
      if command eval "setServerProperties_1.${version[1]}.${patch}"; then
        successful=true
        break
      fi
    done
    if ! "$successful"; then
      # check for minor version down to fallback
      for minor in $(seq "${version[1]}" -1 "$fallback_minor"); do
        if command eval "setServerProperties_1.${minor}.0"; then
          break
        fi
      done
    fi
  else
    command eval "setServerProperties_1.${fallback_minor}.${fallback_patch}" \
      || echo "[property_handling][ERROR] loading fallback properties failed"
  fi

  echo "[property_handling][INFO] loaded $((${#SERVER_PROPERTIES_CONFIG[@]} / 3)) properties"
  [ "${#SERVER_PROPERTIES_CONFIG[@]}" -gt 0 ] && return 0 || return 1
}




# WRITING global SERVER_PROPERTIES
function sortServerProperties() {
  # sort properties
  # shellcheck disable=SC2207
  IFS=$'\n' SERVER_PROPERTIES=( $( printf "%s\n" "${SERVER_PROPERTIES[@]}" | sort | uniq | sed -E 's/^\s*//g' | sed -E 's/\s*$//g' ) )
}





# WRITING global SERVER_PROPERTIES
function writeServerProperties_toFile() {
  local file="$1"
  local ignore_errors="$(grep -q 'ignore-errors' <<< "$@" && echo "false" || echo "true")"

  sortServerProperties

  if ! "$ignore_errors"; then
    validateServerPropertiesVariable "fix_illegal"
  fi

  echo "#Minecraft server properties" > "$file"
  echo "#never booted" >> "$file"
  for property_line in "${SERVER_PROPERTIES[@]}"; do
    echo "$property_line" >> "$file"
  done
}
