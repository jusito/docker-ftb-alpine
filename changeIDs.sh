#!/bin/sh

set -e

NEW_USER_ID=$1
NEW_GROUP_ID=$2
echo "This script needed to execute as root f.e. docker exec -u root:root NAME_OF_CONTAINER changeIDs.sh NEW_USER_ID NEW_GROUP_ID"
echo "trying to switch ids of ${MY_NAME}:${MY_NAME} from ${MY_USER_ID}:${MY_GROUP_ID} to ${NEW_USER_ID}:${NEW_GROUP_ID}, package shadow needed for usermod & groupmod."

if [ ! -n "${NEW_USER_ID}" ]; then
	echo 'Please insert user id & group id.'
	exit 1
elif [ ! -n "${NEW_GROUP_ID}" ]; then
	echo 'Please insert group id.'
	exit 2
else
	echo 'installing dependecies'
	apk add --no-cache shadow
	export MY_USER_ID=${NEW_USER_ID}
	export MY_GROUP_ID=${NEW_GROUP_ID}
	
	echo 'changing ids'
	pkill -20 entrypoint.sh
	usermod -u "${MY_USER_ID}" "${MY_NAME}"
	groupmod -g "${MY_GROUP_ID}" "${MY_NAME}"
	
	echo "switched ids to ${MY_USER_ID}:${MY_GROUP_ID}, cleanup."
	apk del shadow
	apk del --quiet --no-cache --progress --purge
	rm -rf /var/cache/apk/*
	echo 'done'
	exit 0
fi