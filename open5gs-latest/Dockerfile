ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:buster


RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg

ADD	https://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_10/Release.key /tmp/Release.key
ADD	https://pgp.mongodb.com/server-4.2.asc /tmp/server-4.2.asc

RUN	echo "deb http://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_10/ ./" \
		> /etc/apt/sources.list.d/open5gs.list
RUN	echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" \
		> /etc/apt/sources.list.d/mongodb-org.list
RUN	apt-key add /tmp/Release.key && apt-key add /tmp/server-4.2.asc

RUN	apt-get update && \
	apt-get install -y \
		mongodb-org \
		open5gs
