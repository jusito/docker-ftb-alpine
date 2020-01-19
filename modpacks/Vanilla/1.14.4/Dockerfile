FROM jusito/docker-ftb-alpine:FTBBase

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar" "ec3c704819a0508e3991cb896d6e02ee" "true"

CMD ["https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar", "ec3c704819a0508e3991cb896d6e02ee"]