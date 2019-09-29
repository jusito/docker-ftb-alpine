FROM jusito/docker-ftb-alpine:FTBBase-debian

ENV allow_flight=true \
	difficulty=3 \
	max_tick_time=-1 \
	view_distance=6 \
	\
	FORGE_VERSION="14.23.5.2847"

COPY ["ServerStart.sh", "/home/" ]

CMD ["https://media.forgecdn.net/files/2791/783/RLCraft+Server+Pack+1.12.2+-+Beta+v2.6.3.zip", "7f9246a84caabd2d74e25fc82811621e"]
