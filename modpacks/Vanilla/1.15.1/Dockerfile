FROM jusito/docker-ftb-alpine:FTBBase

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/4d1826eebac84847c71a77f9349cc22afd0cf0a1/server.jar" "50bcc8e23970e2f0b45606205cba3bd0" "true"

CMD ["https://launcher.mojang.com/v1/objects/4d1826eebac84847c71a77f9349cc22afd0cf0a1/server.jar", "50bcc8e23970e2f0b45606205cba3bd0"]