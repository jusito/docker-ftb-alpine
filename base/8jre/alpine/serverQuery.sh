#!/bin/sh

if [ "${DEBUGGING:?}" = "true" ]; then
        set -o xtrace
fi
set -o errexit
#set -o pipefail
set -o nounset

readonly USE_LOG="/home/docker/logs/latest.log"
command="$*"
if [ "not a tty" = "$(tty)" ] || [ "true" = "$TEST_MODE" ]; then
	interacteShell="false"
else
	interacteShell="true"
fi





getLogLines() {
	wc -l "$USE_LOG" | grep -Eo '^\d+'
}
querySend() {
    echo "$@" > "$SERVER_QUERY_PIPE"
}





trap 'exit 0;' 15
while [ "$command" != "end" ]; do
	if [ "$command" = "-h" ] || [ "$command" = "--help" ]; then
		echo "[serverQuery][HELP] help requested with -h or --help"
		echo "[serverQuery][INFO] docker exec CONTAINER query CMD        - single command"
		echo "[serverQuery][INFO] docker exec -it CONTAINER query CMD    - interactive mode"
		echo "[serverQuery][HELP] usage: query command [arg1, arg2, ...] - e.g. query command /fml confirm"
		echo "[serverQuery][HELP] "
		echo "[serverQuery][HELP] special commands:"
		echo "[serverQuery][HELP] end   - end query"
		echo "[serverQuery][HELP] clear - clear terminal"
		echo "[serverQuery][HELP] reset - clear terminal"
		echo "[serverQuery][HELP] show  - show last 50 lines of latest.log"
		echo "[serverQuery][HELP] "
		echo "[serverQuery][HELP] minecraft server commands:"
		echo "[serverQuery][HELP] help  - show all minecraft commands"
	elif [ "$command" = "show" ]; then
		linesOut=50
	elif [ "$command" = "reset" ] || [ "$command" = "clear" ]; then
		reset
	else
		linesBefore="$(getLogLines)"
		querySend "$command"
		timeout=5
		current=1
		while [ "$current" -lt "$timeout" ] && [ "$(getLogLines)" = "$linesBefore" ]; do
			usleep 100000 #100ms
			current=$(( current + 1 ))
		done
		if [ "$current" -ge "$timeout" ]; then
			echo "[serverQuery][ERROR] timeout ${current}/${timeout}"
		fi
		linesAfter="$(getLogLines)"

		if [ "$linesBefore" -gt "$linesAfter" ]; then
			linesOut=20
		else
			linesOut=$(( linesAfter - linesBefore ))
		fi
	fi
	
	tail -n "$linesOut" "$USE_LOG"

	if [ "true" = "$interacteShell" ]; then
		echo "[serverQuery][INFO] insert query command, special commands end/clear/reset/show"
    	read -r command
	else
		command="end"
	fi
done




exit 0