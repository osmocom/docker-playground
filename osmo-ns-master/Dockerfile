ARG	USER
ARG	DISTRO
FROM	$USER/$DISTRO-build
# Arguments used after FROM must be specified again
ARG	DISTRO

RUN	case "$DISTRO" in \
	debian*) \
		apt-get update && \
		apt-get install -y --no-install-recommends \
			python3-osmopy-utils \
			libmnl-dev && \
		apt-get clean \
		;; \
	centos*) \
		dnf install -y \
			"pkgconfig(libmnl)" \
		;; \
	esac

WORKDIR	/tmp

ARG	LIBOSMOCORE_BRANCH="master"

RUN	git clone https://gerrit.osmocom.org/libosmocore.git
ADD	https://gerrit.osmocom.org/plugins/gitiles/libosmocore/+/$LIBOSMOCORE_BRANCH?format=TEXT /tmp/commit-libosmocore

RUN	set -x && \
	cd libosmocore && \
	git fetch && git checkout $LIBOSMOCORE_BRANCH && \
	(git symbolic-ref -q HEAD && git reset --hard origin/$LIBOSMOCORE_BRANCH || exit 1); \
	git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && \
	autoreconf -fi && \
	CONFIGURE_FLAGS="--disable-doxygen --disable-pcsc --enable-external-tests" && \
	if [ "$DISTRO" = "debian-buster" ]; then \
		CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-uring"; \
	fi && \
	./configure $CONFIGURE_FLAGS && \
	make "-j$(nproc)" install && \
	install -m 0755 utils/.libs/osmo-ns-dummy /usr/local/bin/osmo-ns-dummy && \
	/sbin/ldconfig

VOLUME	/data

COPY	osmo-ns-dummy.cfg /data/osmo-ns-dummy.cfg

# work-around for stupid docker not being able to properly deal with host netdevices or start
# containers in pre-existing netns
COPY	.common/pipework	/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

WORKDIR	/data
CMD	["/docker-entrypoint.sh"]

#EXPOSE
