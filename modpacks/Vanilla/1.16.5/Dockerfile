ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar" "c10b74188efc4ed6960db49c9ade50ce" "true"

CMD ["https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar", "c10b74188efc4ed6960db49c9ade50ce"]