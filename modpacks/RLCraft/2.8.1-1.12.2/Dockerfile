FROM jusito/docker-ftb-alpine:FTBBase

ENV allow_flight=true \
	difficulty=3 \
	max_tick_time=-1 \
	view_distance=6 \
	\
	FORGE_VERSION="14.23.5.2847" \
	MY_FILE="Twitch.zip"

COPY ["ServerStart.sh", "/home/" ]

CMD ["https://media.forgecdn.net/files/2836/138/RLCraft+Server+Pack+1.12.2+-+Beta+v2.8.1.zip", "aa06ffab9829705842d8f2c57d6935c0"]
