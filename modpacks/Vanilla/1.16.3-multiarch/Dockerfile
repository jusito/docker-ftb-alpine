FROM jusito/docker-ftb-alpine:8jre-ubuntu-hotspot

ENV MY_FILE="Server.jar"

RUN sh /home/entrypoint.sh "https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar" "51f363d9fdf9caf953c1fec932e50593" "true"

CMD ["https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar", "51f363d9fdf9caf953c1fec932e50593"]