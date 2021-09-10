#!/bin/bash

function setServerProperties_1.11.0() {
  setServerProperties_1.10.2
  addPropertyConfig "prevent-proxy-connections" "^(true|false)$" "false"
}

function setServerProperties_1.11.1() {
  setServerProperties_1.11.0
}

function setServerProperties_1.11.2() {
  setServerProperties_1.11.0
}
