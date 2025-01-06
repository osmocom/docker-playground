FROM redmine:5.1.5

RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y --no-install-recommends \
		graphviz \
		imagemagick \
		mscgen \
		patch && \
	apt-get clean

# needed after 5.0.0 removes openID [client] support
RUN	gem install ruby-openid rack-openid

ADD	openid_server_length_empty.diff /tmp/openid_server_length_empty.diff
RUN 	cd /usr/local/bundle/gems/ruby-openid-2.9.2 && patch -p1 < /tmp/openid_server_length_empty.diff

ADD	commitlog-references-oshash-5.1.3.diff /tmp/commitlog-references-oshash-5.1.3.diff
RUN	cd /usr/src/redmine && patch -p1 < /tmp/commitlog-references-oshash-5.1.3.diff

# https://www.redmine.org/issues/42013
# https://www.redmine.org/projects/redmine/repository/svn/revisions/23408/diff/trunk/Gemfile
ADD	changeset_r23408.diff /tmp/changeset_r23408.diff
RUN	cd /usr/src/redmine && patch -p0 < /tmp/changeset_r23408.diff

ADD	docker-entrypoint-osmo.sh /
ENTRYPOINT ["/docker-entrypoint-osmo.sh"]
CMD	["rails", "server", "-b", "0.0.0.0"]
