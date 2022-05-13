ARG	REGISTRY=docker.io
FROM	${REGISTRY}/alpine:3.6


RUN	apk update && \
	apk upgrade

RUN	apk update && \
	apk add alpine-sdk git make automake autoconf libtool pkgconfig talloc-dev pcsc-lite-dev linux-headers
