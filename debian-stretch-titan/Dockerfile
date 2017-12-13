FROM debian:stretch

MAINTAINER Harald Welte <laforge@gnumonks.org>

RUN	apt-get update && apt-get install -y \
	eclipse-titan

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install \
		build-essential \
		git && \
	apt-get clean

# somehow Debian folks updated the gcc version but not titan :/
RUN	sed -i 's/^#error/\/\/#error/' /usr/include/titan/cversion.h
