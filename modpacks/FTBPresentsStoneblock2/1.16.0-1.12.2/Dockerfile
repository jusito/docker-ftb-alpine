ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2846" \
	JAVA_PARAMETERS="-Xmx2048M -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=5 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"

CMD ["https://media.forgecdn.net/files/2792/352/FTBPresentsStoneblock2Server_1.16.0.zip", "ae25ea85c9cb53328992e035be5fdfec"]
