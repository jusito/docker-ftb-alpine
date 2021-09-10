#!/bin/bash

function setServerProperties_1.17.0() {
  setServerProperties_1.16.5
  #addPropertyConfig "text-filtering-config" "^.*$" ""
  #addPropertyConfig "require-resource-pack" "^.*$" ""
  #addPropertyConfig "resource-pack-prompt" "^.*$" ""
}

function setServerProperties_1.16.1() {
  setServerProperties_1.17.0
}
