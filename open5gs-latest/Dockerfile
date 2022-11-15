ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:bullseye


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg

ADD	https://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_11/Release.key /tmp/Release.key
ADD	https://pgp.mongodb.com/server-5.0.asc /tmp/server-5.0.asc

RUN	echo "deb http://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_11/ ./" \
		> /etc/apt/sources.list.d/open5gs.list
RUN	echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" \
		> /etc/apt/sources.list.d/mongodb-org.list
RUN	apt-key add /tmp/Release.key && apt-key add /tmp/server-5.0.asc

RUN	apt-get update && \
	apt-get install -y \
		mongodb-org \
		open5gs
