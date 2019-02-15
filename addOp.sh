#!/bin/sh

set -o errexit
set -o pipefail
set +o nounset 

uuid="$1"
readonly name="$2"
level="$3"
bypassesPlayerLimit="$4"
set -o nounset
#uuid=$(wget -O - "https://api.mojang.com/users/profiles/minecraft/terzut" | grep -Eo -e '"id":"[^"]+' | grep -Eo -e '[^"]+$')

readonly file="$MY_VOLUME/ops.json"
readonly fileBac="$MY_VOLUME/ops.json.bac"
readonly uuidResolve="https://api.mojang.com/users/profiles/minecraft/"

# check entrys given
if [ -z "$name" ]; then
	echo "[addOp][ERROR]The given name is empty, this isn't valid."
	exit 10
fi
if [ -z "$level" ]; then
	level=4
	echo "[addOp][WARN]The given level is empty, using $level."
fi
if [ -z "$bypassesPlayerLimit" ]; then
	bypassesPlayerLimit=true
	echo "[addOp][WARN]The given value for bypass player limit is empty, using $bypassesPlayerLimit."
fi
# https://minecraft-de.gamepedia.com/UUID
if [ -z "$uuid" ]; then
	echo "[addOp][INFO]resolving uuid from mojang"
	set +o errexit
	uuid=$(wget -O - "${uuidResolve}${name}" | grep -Eo -e '"id":"[^"]+' | grep -Eo -e '[^"]+$')
	if [ -z "$uuid" ]; then
		echo "[addOp][ERROR]couldn't resolve uuid, given name maybe invalid."
		exit 14
	fi
	set -o errexit
fi
echo "[addOp][INFO]checking uuid $uuid"
uuidLength="${#uuid}"
if [ "$uuidLength" = "32" ]; then
	echo "[addOp][INFO]uuid is short form"
	if echo "$uuid" | grep -q -E -e '^[0-9a-fA-F]{32}$'; then
		echo "[addOp][INFO]converting to long form"
		uuid=$(echo "$uuid" | sed -E 's/^(.{8})(.{4})(.{4})(.{4})(.{12})$/\1-\2-\3-\4-\5/')
	else
		echo "[addOp][ERROR]uuid contains invalid characters, only 0-9a-fA-F valid."
		exit 12
	fi
elif [ "$uuidLength" = "36" ]; then
	echo"[addOp][INFO]uuid is long form"
	if ! echo "$uuid" | grep -q -E -e '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'; then
		echo "[addOp][ERROR]Given uuid is invalid, used regex: [0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12"
		exit 13
	else
		echo "[addOp][INFO]uuid looks valid"
	fi
else
	echo "[addOp][ERROR]Current uuid is invalid, not of length 33 or 37"
	exit 11
fi
echo "[addOp][INFO]Using uuid: $uuid"

# read existing entrys
existing=""
if [ -e "$file" ]; then
	existing=$(tr -d '\r\n[]' < "$file")
	
	players=$(echo "$existing" | grep -Eoc -e '\{[^}]*\}')
	if [ "$players" = "0" ]; then
		existing=""
		
	# remove existing player
	else
		temp="$existing"
		existing=""
		echo "$temp" | grep -Eo -e '\{[^}]+\}' |
		while read -r current
		do
			if echo "$current" | grep -Eq -e "\"name\"\s*:\s*\"$name\""; then
				echo "[addOp][INFO]uuid is already in, replacing with new values"
			else
				existing="${existing},${current}"
			fi
		done
	fi
fi

# backup old one
if [ -e "$file" ]; then
	mv -fv "$file" "$fileBac"
fi

# write new one
if [ -n "$existing" ]; then
	existing="${existing},"
fi
echo "[${existing}{\"uuid\": \"$uuid\",\"name\": \"$name\",\"level\": $level,\"bypassesPlayerLimit\": $bypassesPlayerLimit}]" > "$file"

echo "[addOp][INFO]printing $file"
cat "$file"
exit 0
