ARG	USER
ARG	DISTRO
ARG	OSMOCOM_REPO_VERSION="latest"
FROM	$USER/$DISTRO-obs-$OSMOCOM_REPO_VERSION
# Arguments used after FROM must be specified again

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		iptables \
		osmo-ggsn \
		osmo-hlr \
		osmo-mgw \
		osmo-msc \
		osmo-sgsn \
		osmo-stp \
		runit && \
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
