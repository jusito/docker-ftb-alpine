ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:16jre-alpine-hotspot$imageSuffix"

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar" "0c657982f8223bdd64d8e31fb48b98a4" "true"

CMD ["https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar", "0c657982f8223bdd64d8e31fb48b98a4"]