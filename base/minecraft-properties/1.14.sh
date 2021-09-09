#!/bin/bash

function setServerProperties_1.14.0() {
  setServerProperties_1.13.2
  overwriteProperty "difficulty" "^([0-3]|peaceful|easy|normal|hard)$" "easy"
}

function setServerProperties_1.14.1() {
  setServerProperties_1.14.0
}

function setServerProperties_1.14.2() {
  setServerProperties_1.14.0
}

function setServerProperties_1.14.3() {
  setServerProperties_1.14.0
}

function setServerProperties_1.14.4() {
  setServerProperties_1.14.0
  addProperty "broadcast-rcon-to-ops" "^(true|false)$" "true"
  addProperty "function-permission-level" "^[2-4]$" "2"
}
