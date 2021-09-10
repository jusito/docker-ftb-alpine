#!/bin/bash

function setServerProperties_1.13.0() {
  setServerProperties_1.12.2
  addPropertyConfig "enforce-whitelist" "^(true|false)$" "false"
}

function setServerProperties_1.13.1() {
  setServerProperties_1.13.0
}

function setServerProperties_1.13.2() {
  setServerProperties_1.13.0
}
