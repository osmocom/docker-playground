FROM redmine:3.2

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		graphviz \
		mscgen \
		patch && \
	apt-get clean

COPY	redmine-issue-2047-svg-image-support.diff /tmp/redmine-issue-2047-svg-image-support.diff
RUN	cd app && patch -p1 < /tmp/redmine-issue-2047-svg-image-support.diff
