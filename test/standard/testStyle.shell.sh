#!/bin/sh

if [ ! -f "test/shared/shared.sh" ]; then exit 1; fi
# shellcheck disable=SC1091
. test/shared/shared.sh

directory="$PWD"
echo "[testStyle.shell][INFO] starting workdir=$directory"

check() {
	file="$1"
	exclude="--exclude=SC2155"
	if [ -n "$2" ]; then
		exclude="$exclude,$2"
	fi

	echo "[testStyle.shell][INFO] processing $file with extra arg: $exclude"
	# shellcheck disable=SC2086
	if shellcheck $exclude "$file"; then
		return 0
	else
		echo "[testStyle.shell][ERROR] style is bad"
		return 1
	fi
}


find "${directory}" -type f -iname '*.sh' |
while read -r filename
do
    if ! check "$filename" ''; then
		exit 1
	fi
done

# shellcheck disable=SC2181
if [ "$?" = "0" ]; then
	echo "[testStyle.shell][INFO] successful!"
	exit 0
else
	echo "[testStyle.shell][ERROR] style in at least one element looks bad"
	exit 1
fi