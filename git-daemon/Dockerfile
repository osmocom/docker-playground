FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

# Install git
RUN apt-get update -qq

RUN apt-get install -qqy git

RUN useradd -u 30001 -g ssh git-daemon

ADD git-daemon.sh /usr/bin/git-daemon.sh
VOLUME /git

# git daemon ports
EXPOSE 9418

CMD /usr/bin/git-daemon.sh
