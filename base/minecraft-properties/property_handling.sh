#!/bin/bash

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



SERVER_PROPERTIES=()
# WRITING global SERVER_PROPERTIES
function readServerPropertiesToVariable() {
  local file="$1"

  # shellcheck disable=SC2207
  IFS=$'\r\n' SERVER_PROPERTIES_new=($(cat "$file"))

  # remove comments from array
  for property in "${SERVER_PROPERTIES_new[@]}"; do
    if grep -q '^[^#=]*=' <<< "$property"; then
      SERVER_PROPERTIES+=("$property")
    fi
  done
}



SERVER_PROPERTIES_MINIMAL=()
SERVER_PROPERTIES_CUSTOM=()
# READING global SERVER_PROPERTIES
# WRITING global SERVER_PROPERTIES, SERVER_PROPERTIES_MINIMAL
function validateServerPropertiesVariable() {
  local fix_illegal="$(grep -q 'fix-illegal' <<< "$@" && echo "false" || echo "true")"
  local rm_default="$(grep -q 'rm_default' <<< "$@" && echo "false" || echo "true")"

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
