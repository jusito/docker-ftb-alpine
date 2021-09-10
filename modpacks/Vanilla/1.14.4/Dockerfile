ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:8jre-alpine-hotspot$imageSuffix"

ENV MY_FILE="Server.jar" \
    MINECRAFT_VERSION="1.14.4"

RUN bash /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar" "ec3c704819a0508e3991cb896d6e02ee" "true"

CMD ["https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar", "ec3c704819a0508e3991cb896d6e02ee"]