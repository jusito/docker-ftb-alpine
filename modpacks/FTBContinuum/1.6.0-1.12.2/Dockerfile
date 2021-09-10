ARG imageBase="8jre-alpine-hotspot"
ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:$imageBase$imageSuffix"

ENV	MINECRAFT_VERSION="1.12.2" \
	FORGE_VERSION="14.23.5.2796" \
	JAVA_PARAMETERS="-Xmx2048M -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=5 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"

CMD ["https://media.forgecdn.net/files/2658/289/FTBContinuumServer_1.6.0.zip", "da48cbbfb86712acee4bd4975aa13cfd"]
