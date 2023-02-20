ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:bullseye
ARG	OPEN5GS_REPO_HOST="https://download.opensuse.org"
ARG	OPEN5GS_REPO_PATH="repositories/home:/acetcom:/open5gs:"
ARG	OPEN5GS_REPO="${OPEN5GS_REPO_HOST}/${OPEN5GS_REPO_PATH}/latest/Debian_11"
ARG	OPEN5GS_KEY=/usr/share/keyrings/open5gs-latest.asc
ARG	MONGODB_KEY=/usr/share/keyrings/mongodb-org.asc


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg \
		iproute2 \
		iputils-ping \
		libcap2-bin \
		net-tools \
		sudo \
		wget

RUN	echo "deb [signed-by=$OPEN5GS_KEY] $OPEN5GS_REPO/ ./" \
		> /etc/apt/sources.list.d/open5gs.list
RUN	echo "deb [signed-by=$MONGODB_KEY] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" \
		> /etc/apt/sources.list.d/mongodb-org.list

RUN	wget "$OPEN5GS_REPO/Release.key" -O "$OPEN5GS_KEY" && \
	wget "https://pgp.mongodb.com/server-5.0.asc" -O "$MONGODB_KEY"

RUN	apt-get update && \
	apt-get install -y \
		mongodb-org \
		open5gs
