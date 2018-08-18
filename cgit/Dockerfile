FROM	ankitrgadiya/cgit:debian-nginx

# This adds the Osmocom specific syntax highlighting + redmine/gerrit integration

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		python3 \
		python3-markdown \
		python3-pygments

RUN	mkdir -p /usr/local/lib/cgit/filters

COPY	osmo-commit-filter.py /usr/local/lib/cgit/filters/osmo-commit-filter.py
COPY	syntax-highlighting.py /usr/local/lib/cgit/filters/syntax-highlighting.py

RUN    useradd -u 30001 -g ssh git-daemon
RUN    usermod -a -G 101 www-data
