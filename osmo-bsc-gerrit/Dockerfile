ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	OSMOCOM_REPO="http://download.opensuse.org/repositories/network:/osmocom:/nightly/Debian_9.0/"

COPY	Release.key /tmp/Release.key

RUN	case "$DISTRO" in \
	debian*) \
		apt-get install -y ca-certificates && \
		apt-key add /tmp/Release.key && \
		rm /tmp/Release.key && \
		echo "deb " $OSMOCOM_REPO " ./" > /etc/apt/sources.list.d/osmocom-nightly.list \
		;; \
	esac

ADD	$OSMOCOM_REPO/Release /tmp/Release
RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			telnet \
			libosmocore-dev \
			libosmo-abis-dev \
			libosmo-netif-dev \
			libosmo-sccp-dev \
			libosmo-sigtran-dev \
			libosmo-mgcp-client-dev \
			libgtp-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libosmo-mgcp-client)" \
			"pkgconfig(libosmo-netif)" \
			"pkgconfig(libosmo-sccp)" \
			"pkgconfig(libosmo-sigtran)" \
			"pkgconfig(libosmoabis)" \
			"pkgconfig(libosmocore)" \
			"pkgconfig(libosmoctrl)" \
			"pkgconfig(libosmogb)" \
			"pkgconfig(libosmogsm)" \
			"pkgconfig(libosmovty)" \
		;; \
	esac

WORKDIR	/tmp

ARG	GERRIT_REFSPEC
# e.g. refs/changes/08/8/1
ARG	GERRIT_CHANGE_NUMBER
# e.g. 8
ARG	GERRIT_PATCHSET_NUMBER
# e.g. 1
ARG	GERRIT_PROJECT
# e.g. osmo-mgw

RUN	git clone https://gerrit.osmocom.org/osmo-bsc.git

# ADD	https://gerrit.osmocom.org/changes/osmo-mgw~19271/revisions/2/patch?download /tmp/commit-osmo-bsc
ADD	"https://gerrit.osmocom.org/changes/${GERRIT_PROJECT}~${GERRIT_CHANGE_NUMBER}/revisions/${GERRIT_PATCHSET_NUMBER}/patch?download" /tmp/commit-osmo-bsc
RUN	cd osmo-bsc && \
	git fetch "https://gerrit.osmocom.org/${GERRIT_PROJECT}" ${GERRIT_REFSPEC} && git checkout FETCH_HEAD && \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	./configure && \
	make -j8 install

VOLUME	/data

COPY	osmo-bsc.cfg /data/osmo-bsc.cfg

WORKDIR	/data
CMD	["/bin/sh", "-c", "/usr/local/bin/osmo-bsc -c /data/osmo-bsc.cfg >/data/osmo-bsc.log 2>&1"]

#EXPOSE
