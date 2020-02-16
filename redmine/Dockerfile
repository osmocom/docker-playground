FROM redmine:3.4-passenger

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		graphviz \
		imagemagick \
		mscgen \
		patch && \
	apt-get clean

# no longer needed after ruby-openid-2.9.2 is used
#ADD	hmac.diff /tmp/hmac.diff
#RUN	cd / && patch -p0 < /tmp/hmac.diff
