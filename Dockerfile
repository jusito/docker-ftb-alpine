FROM openjdk:8-jre-alpine

EXPOSE 25565/tcp

ENV MY_GROUP_ID=10000 \
	MY_USER_ID=10000 \
	MY_NAME=docker \
	MY_HOME=/home/docker \
	MY_VOLUME=/home/docker/volume \
	MY_FILE="FTBServer.zip" \
	MY_SERVER="https://media.forgecdn.net/files/2582/366/FTB+Presents+Direwolf20+1.12-1.12.2-2.1.0-Server.zip" \
	MY_MD5="fdfbedd84bdff0417634e652678fe1dd"

VOLUME "${MY_SERVER}"

COPY ["entrypoint.sh", "${MY_HOME}/entrypoint.sh" ]

RUN apk update && \
	apk add --no-cache ca-certificates && \
	addgroup -g "${MY_GROUP_ID}" "${MY_NAME}" && \
	adduser -h "${MY_HOME}" -g "" -s "/bin/false" -G "${MY_NAME}" -D -u "${MY_USER_ID}" "${MY_NAME}" && \
	mkdir "${MY_VOLUME}" && \
	cd "${MY_HOME}" && \
	wget -O "${MY_FILE}" "${MY_SERVER}" && \
	echo "${MY_MD5}  ${MY_FILE}" | md5sum -s -c - && \
	chown -R "${MY_NAME}:${MY_NAME}" "${MY_HOME}" && \
	chmod -R u=rwx,go= "${MY_HOME}" && \
	apk del --quiet --no-cache --progress --purge && \
	rm -rf /var/cache/apk/*
	
CMD ["./home/docker/entrypoint.sh"]

USER "${MY_USER_ID}:${MY_GROUP_ID}"