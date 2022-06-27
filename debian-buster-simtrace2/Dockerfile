ARG	USER
FROM	$USER/debian-buster-build
# Arguments used after FROM must be specified again
ARG	OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
ARG	OSMOCOM_REPO_PATH="packages/osmocom:"
ARG	OSMOCOM_REPO="${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/nightly/Debian_10/"

COPY	.common/Release.key /tmp/Release.key

RUN	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key && \
	echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev \
		&& \
	apt-get clean

RUN	useradd -m osmocom
USER	osmocom
WORKDIR	/home/osmocom

RUN	git clone https://gerrit.osmocom.org/simtrace2
