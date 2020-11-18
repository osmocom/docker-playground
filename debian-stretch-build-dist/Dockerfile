ARG	USER
FROM	$USER/debian-stretch-build
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="http://download.opensuse.org"

ARG	OSMOCOM_REPO="$OSMOCOM_REPO_MIRROR/repositories/network:/osmocom:/latest/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-latest.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		libboost-all-dev \
		liboping-dev \
		libuhd-dev \
		\
		libasn1c-dev \
		libgtp-dev \
		libgtpnl-dev \
		liblimesuite-dev \
		liborcania-dev \
		libosmo-abis-dev \
		libosmocore-dev \
		libosmodsp-dev \
		libosmo-gsup-client-dev \
		libosmo-mgcp-client-dev \
		libosmo-netif-dev \
		libosmo-ranap-dev \
		libosmo-sccp-dev \
		libosmo-sigtran-dev \
		libsmpp34-dev \
		libulfius-dev \
		libusrp-dev \
		libyder-dev && \
	apt-get clean
