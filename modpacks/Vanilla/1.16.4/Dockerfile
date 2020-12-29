ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar" "c43dc4c1bda4f485428fc60d5b998270" "true"

CMD ["https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar", "c43dc4c1bda4f485428fc60d5b998270"]