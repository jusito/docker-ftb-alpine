#!/bin/bash

# generator-settings json anstatt strings
function setServerProperties_1.16.0() {
  setServerProperties_1.15.2
  addProperty "enable-status" "^(true|false)$" "true"
  addProperty "entity-broadcast-range-percentage" "^([0-9]|[1-9][0-9]|[1-4][0-9][0-9]|500)$" "100"
  addProperty "sync-chunk-writes" "^(true|false)$" "true"
  addProperty "enable-jmx-monitoring" "^(true|false)$" "false"

}

function setServerProperties_1.16.1() {
  setServerProperties_1.16.0
}

function setServerProperties_1.16.2() {
  setServerProperties_1.16.0
  addProperty "rate-limit" "^[0-9]+$" "0"
}

function setServerProperties_1.16.3() {
  setServerProperties_1.16.2
}

function setServerProperties_1.16.4() {
  setServerProperties_1.16.2
  addProperty "text-filtering-config" "^.*$" ""
}

function setServerProperties_1.16.5() {
  setServerProperties_1.16.4
}

