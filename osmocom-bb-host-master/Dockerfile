ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO
ARG	OSMO_BB_BRANCH="master"

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		libosmocore-dev && \
	apt-get clean

WORKDIR	/tmp

RUN	git clone git://git.osmocom.org/osmocom-bb.git

ADD	http://git.osmocom.org/osmocom-bb/patch?h=$OSMO_BB_BRANCH /tmp/commit
RUN	cd osmocom-bb && \
	git fetch && git checkout $OSMO_BB_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$OSMO_BB_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD

RUN	cd osmocom-bb/src/host/trxcon && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

RUN	cd osmocom-bb/src/host/virt_phy && \
	autoreconf -fi && \
	./configure && \
	make "-j$(nproc)" install

RUN	mkdir -p /data/unix

VOLUME	/data

WORKDIR	/data
#CMD	["/usr/local/sbin/virtphy","-s","/data/osmocom_l2"]
