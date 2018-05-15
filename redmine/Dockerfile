FROM redmine:3.2

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		graphviz \
		mscgen \
		patch && \
	apt-get clean

COPY	redmine-issue-2047-svg-image-support.diff /tmp/redmine-issue-2047-svg-image-support.diff
RUN	cd app && patch -p1 < /tmp/redmine-issue-2047-svg-image-support.diff

COPY	redmine-openid-hmac-digest.diff /tmp/
RUN	cd /usr/local/bundle/gems/ruby-openid-2.3.0 && patch -p0 < /tmp/redmine-openid-hmac-digest.diff

COPY	redmine-image-content-disposition.diff /tmp/
RUN	patch -p1 < /tmp/redmine-image-content-disposition.diff
