#!/bin/sh

set -e

NEW_USER_ID=$1
NEW_GROUP_ID=$2

echo "trying to switch ids of ${MY_NAME}:${MY_NAME} from ${MY_USER_ID}:${MY_GROUP_ID} to ${NEW_USER_ID}:${NEW_GROUP_ID}, package shadow needed for usermod & groupmod."

if [ ! -n "${NEW_USER_ID}" ]; then
	echo 'Please insert user id & group id.'
	exit 1
elif [ ! -n "${NEW_GROUP_ID}" ]; then
	echo 'Please insert group id.'
	exit 2
else
	export MY_USER_ID=${NEW_USER_ID}
	export MY_GROUP_ID=${NEW_GROUP_ID}
	
	usermod -u "${MY_USER_ID}" "${MY_NAME}"
	groupmod -g "${MY_GROUP_ID}" "${MY_NAME}"
	
	echo "switched ids to ${MY_USER_ID}:${MY_GROUP_ID}."
	exit 0
fi