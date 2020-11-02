ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:stretch

MAINTAINER Daniel Willmann <dwillmann@sysmocom.de>

ARG OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/latest/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		gnupg

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		osmo-msc osmo-hlr osmo-sgsn osmo-ggsn osmo-mgw osmo-stp \
		runit telnet iptables && \
	apt-get clean

WORKDIR	/tmp

VOLUME	/data
COPY	osmo-stp.cfg /data/osmo-stp.cfg
COPY	osmo-msc.cfg /data/osmo-msc.cfg
COPY	osmo-hlr.cfg /data/osmo-hlr.cfg
COPY	osmo-mgw.cfg /data/osmo-mgw.cfg
COPY	osmo-sgsn.cfg /data/osmo-sgsn.cfg
COPY	osmo-ggsn.cfg /data/osmo-ggsn.cfg

COPY	runit/stp-run /etc/service/osmo-stp/run
COPY	runit/msc-run /etc/service/osmo-msc/run
COPY	runit/hlr-run /etc/service/osmo-hlr/run
COPY	runit/mgw-run /etc/service/osmo-mgw/run
COPY	runit/sgsn-run /etc/service/osmo-sgsn/run
COPY	runit/ggsn-run /etc/service/osmo-ggsn/run

WORKDIR	/data
CMD	["/sbin/runit"]


EXPOSE 23000/udp
