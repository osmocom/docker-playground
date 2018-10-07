FROM redmine:3.4

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		graphviz \
		imagemagick \
		mscgen \
		patch && \
	apt-get clean

ADD	hmac.diff /tmp/hmac.diff
RUN	cd / && patch -p0 < /tmp/hmac.diff
