ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.7.10" \
	FORGE_VERSION="10.13.4.1614" \
	JAVA_PARAMETERS="-Xms512M -Xmx2048M -XX:PermSize=256M -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"

CMD ["https://media.forgecdn.net/files/2731/545/FTBInfinityServer_3.1.0.zip", "5fd22d9c01ab783a3bee177a5c4d5f22"]
