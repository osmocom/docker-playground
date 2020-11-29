ARG	USER
ARG	DISTRO
FROM	$USER/osmo-sgsn-master

COPY	osmo-gbproxy.cfg 	/data/osmo-gbproxy.cfg

# work-around for stupid docker not being able to properly deal with host netdevices or start
# containers in pre-existing netns
COPY	pipework		/usr/bin/pipework
COPY	docker-entrypoint.sh	/docker-entrypoint.sh

WORKDIR	/data
CMD	["/docker-entrypoint.sh"]

EXPOSE	23000/udp 4246/tcp 4263/tcp
