#!/bin/sh
# shellcheck disable=SC2039

set -o errexit
set -o pipefail
set +o nounset

src=$1
srcSuffix=""
srcDir=true
readonly srcType=$2 # path / volume
readonly targetName=$3
readonly userId=$4
readonly groupId=$5

containerName="copyToVolume.sh"
if [ "$src" = "-h" ] || [ "$src" = "--help" ]; then
	echo "Usage: source sourceType targetName userid groupid"
	echo "Example Path to Volume: \"/home/jusito/serverfiles\" \"path\" \"NewServerfilesVolume\" \"10000\" \"10000\""
	echo "Result: NewServerfilesVolume:serverfiles/..."
	echo "Example Path to Volume: \"/home/jusito/serverfiles/*\" \"path\" \"NewServerfilesVolume\" \"10000\" \"10000\""
	echo "Result: NewServerfilesVolume:..."
	echo "Example Volume to Volume: \"OldServerfilesVolume\" \"volume\" \"NewServerfilesVolume\" \"10000\" \"10000\""
	exit 0
fi
set -o nounset





#shellcheck disable=SC2039
echo -n "[copyToVolume][INFO] check preconditions"
if [ "$srcType" = "path" ]; then
	suffix="/*"
	srcSuffix=""
	# if only sub-files wanted
	if test "$src" != "${src%$suffix}"; then
		echo "[copyToVolume][INFO] found suffix \"$suffix\" for directory"
		src="${src%$suffix}"
		srcSuffix="$suffix"
		srcDir=true
		
	# if directory given
	elif [ -d "$src" ]; then
		echo "[copyToVolume][INFO] looks like directory: $src"
		srcDir=true
		
	# if file given
	else
		echo "[copyToVolume][INFO] looks like file: $src"
		srcDir=false
	fi
	
	if [ ! -e "$src" ]; then
		echo "[copyToVolume][ERROR] source path \"$src\" no existing."
		exit 11
	elif [ "$(docker volume ls -f "name=^${targetName}$" | wc -l)" = "2" ]; then
		echo "[copyToVolume][ERROR] target volume \"$targetName\" already existing"
		exit 12
	fi
elif [ "$srcType" = "volume" ]; then
	if [ "$(docker volume ls -f "name=^${src}$" | wc -l)" = "1" ]; then
		echo "[copyToVolume][ERROR] source volume doesn't exist"
		exit 13
	elif [ "$(docker volume ls -f "name=^${targetName}$" | wc -l)" = "2" ]; then
		echo "[copyToVolume][ERROR] target volume \"$targetName\" already existing"
		exit 14
	fi
else
	echo "[copyToVolume][ERROR] srcType: \"$srcType\" not \"path\" or \"volume\""
	exit 10
fi
#shellcheck disable=SC2039
echo -en "\r[copyToVolume][INFO] preconditions looks fine\n"





#shellcheck disable=SC2039
echo -n "[copyToVolume][INFO] starting copy..."
if [ "$srcType" = "path" ]; then
	#shellcheck disable=SC2039
	echo -en "\r[copyToVolume][INFO] starting copy... \"path\" mode\n"
	docker run -d --rm --name "$containerName" \
	-v "${targetName}:/home/target:rw" \
	busybox:latest sleep 365d 1>/dev/null
	
	if [ "$srcDir" = "true" ]; then
		echo "[copyToVolume][INFO] source is directory"
		if [ -n "$srcSuffix" ]; then
			echo "[copyToVolume][INFO] sub-files of directory should be copied"
			for entry in "$src"/*
			do
				docker cp "${entry}" "${containerName}:/home/target/"
			done
		else
			echo "[copyToVolume][INFO] directory should be copied"
			docker cp "${src}" "${containerName}:/home/target/"
		fi
	else
		echo "[copyToVolume][INFO] source is NO directory"
		docker cp "$src" "${containerName}:/home/target/"
	fi
	
	docker exec "$containerName" chown -vR "${userId}:${groupId}" "/home/target"
	docker kill "$containerName"
	
elif [ "$srcType" = "volume" ]; then
	#shellcheck disable=SC2039
	echo -en "\r[copyToVolume][INFO] starting copy... \"volume\" mode\n"
	docker run -it --rm --name "$containerName" \
	-v "${src}:/home/source:ro" \
	-v "${targetName}:/home/target:rw" \
	-w="/home/source/" \
	busybox:latest sh -c "cp -rfv . /home/target/;chown -vR \"${userId}:${groupId}\" /home/target;"
else
	echo "[copyToVolume][ERROR] srcType: \"$srcType\" not \"path\" or \"volume\""
	exit 15
fi
echo "[copyToVolume][INFO] copy done"








echo "[copyToVolume][INFO] done"
exit 0