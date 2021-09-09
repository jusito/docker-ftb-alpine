#!/bin/bash

function setServerProperties_1.17.0() {
  setServerProperties_1.16.5
  #addProperty "text-filtering-config" "^.*$" ""
  #addProperty "require-resource-pack" "^.*$" ""
  #addProperty "resource-pack-prompt" "^.*$" ""
}

function setServerProperties_1.16.1() {
  setServerProperties_1.17.0
}

