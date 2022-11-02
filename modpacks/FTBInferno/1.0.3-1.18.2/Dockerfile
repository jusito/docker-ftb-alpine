ARG imageSuffix=""

FROM "jusito/docker-ftb-alpine:17jre-alpine-hotspot$imageSuffix"

ENV MINECRAFT_VERSION="1.18.2" \
	FORGE_VERSION="use-shipped" \
	MY_FILE="serverinstall_99_2270" \
	JAVA_PARAMETERS="-javaagent:log4jfix/Log4jPatcher-1.0.0.jar -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx6144M -Xms4096M @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.1.80/unix_args.txt nogui"

CMD ["https://api.modpacks.ch/public/modpack/99/2270/server/linux", "variable"]
