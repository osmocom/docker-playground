FROM redmine:6.1.3

RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y --no-install-recommends \
		gcc \
		graphviz \
		imagemagick \
		libc6-dev \
		make \
		mscgen \
		patch \
		&& \
	apt-get clean

# {ruby,rack}-openid: needed after 5.0.0 removes openID [client] support
# nkf: needed for redmine 6 to run redmine_openid_provider
RUN	gem install ruby-openid rack-openid nkf

ADD	openid_server_length_empty.diff /tmp/openid_server_length_empty.diff
RUN 	cd /usr/local/bundle/gems/ruby-openid-2.9.2 && patch -p1 < /tmp/openid_server_length_empty.diff

ADD	commitlog-references-oshash-5.1.3.diff /tmp/commitlog-references-oshash-5.1.3.diff
RUN	cd /usr/src/redmine && patch -p1 < /tmp/commitlog-references-oshash-5.1.3.diff

ADD	0001-Set-session_store-to-active_record_store.patch /tmp/
RUN	cd /usr/src/redmine && patch -p1 < /tmp/0001-Set-session_store-to-active_record_store.patch

ADD	docker-entrypoint-osmo.sh /
ENTRYPOINT ["/docker-entrypoint-osmo.sh"]
CMD	["rails", "server", "-b", "0.0.0.0"]
