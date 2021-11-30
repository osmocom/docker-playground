FROM redmine:4.2-passenger

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

ADD	openid_server_length_empty.diff /tmp/openid_server_length_empty.diff
RUN 	cd /usr/local/bundle/gems/ruby-openid-2.9.2 && patch -p1 < /tmp/openid_server_length_empty.diff

ADD	commitlog-references-oshash.diff /tmp/commitlog-references-oshash.diff
RUN	cd /usr/src/redmine && patch -p1 < /tmp/commitlog-references-oshash.diff

ADD	docker-entrypoint-osmo.sh /
ENTRYPOINT ["/docker-entrypoint-osmo.sh"]
CMD	["passenger", "start"]
