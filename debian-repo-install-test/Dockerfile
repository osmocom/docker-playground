ARG	USER
ARG	REGISTRY=docker.io
FROM	${REGISTRY}/debian:stretch

COPY	Release.key /tmp/Release.key

RUN	apt-get update && \
	apt-get install -y --no-install-recommends \
		aptitude \
		gnupg \
		systemd && \
	apt-key add /tmp/Release.key && \
	rm /tmp/Release.key
