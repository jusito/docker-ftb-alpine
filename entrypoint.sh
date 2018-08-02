#!/bin/sh

set -e

# copy zip into dir
cp -f "${MY_HOME}/${MY_FILE}" "${MY_VOLUME}/${MY_FILE}"

# set workdir to volume
cd "${MY_VOLUME}"

# unzip server files
unzip -o "${MY_FILE}"

# delete copied zip
rm -f "${MY_FILE}"

# set eula = accepted
sed -i 's/eula=false/eula=true/g' 'eula.txt'

# execute server
chmod +x ServerStart.sh
./ServerStart.sh