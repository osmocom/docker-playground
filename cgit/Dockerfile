# from https://github.com/ankitrgadiya/docker-cgit/blob/master/debian-nginx/Dockerfile
################################################################################
FROM debian:latest

# Update repositories the system
RUN apt-get update

# Install packages
RUN apt-get install git cgit nginx highlight fcgiwrap -y

# Add configurations
ADD config/nginx.conf /etc/nginx/sites-available/git
ADD config/cgitrc /etc/cgitrc

# Enable configuration
RUN rm -rf /etc/nginx/sites-enabled/*
RUN ln -s /etc/nginx/sites-available/git /etc/nginx/sites-enabled/git

# Start
EXPOSE 80
CMD service fcgiwrap restart && nginx -g 'daemon off;'

# osmocom additions
################################################################################

# This adds the Osmocom specific syntax highlighting + redmine/gerrit integration
RUN apt-get update
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
