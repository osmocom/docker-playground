ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:buster

MAINTAINER Vadim Yanitskiy <vyanitskiy@sysmocom.de>

# TODO: remove me!
ADD sources.list /etc/apt/sources.list

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg \
		curl
RUN	curl https://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_10/Release.key | apt-key add -
RUN	curl https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -

RUN	echo "deb http://download.opensuse.org/repositories/home:/acetcom:/open5gs:/latest/Debian_10/ ./" \
		> /etc/apt/sources.list.d/open5gs.list
RUN	echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" \
		> /etc/apt/sources.list.d/mongodb-org.list

RUN	apt-get update && \
	apt-get install -y \
		mongodb-org \
		open5gs
