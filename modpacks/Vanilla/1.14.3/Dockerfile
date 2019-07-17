FROM jusito/docker-ftb-alpine:FTBBase

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar" "80424cd6fd6161d5509815bbe65cf9a3" "true"

CMD ["https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar", "80424cd6fd6161d5509815bbe65cf9a3"]