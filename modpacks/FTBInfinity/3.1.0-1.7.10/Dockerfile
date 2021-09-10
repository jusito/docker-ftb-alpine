ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="ERROR_FILL_MANUALLY" \
	FORGE_VERSION="ERROR_FILL_MANUALLY" \
	JAVA_PARAMETERS="-Xms512M -Xmx2048M -XX:PermSize=256M -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"

CMD ["https://media.forgecdn.net/files/2731/545/FTBInfinityServer_3.1.0.zip", "5fd22d9c01ab783a3bee177a5c4d5f22"]
