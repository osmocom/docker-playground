RUN_ARGS?=	\
	-it \
	--cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun \
	--sysctl net.ipv6.conf.all.disable_ipv6=0 \
	--sysctl net.ipv6.conf.all.forwarding=1 \
	--network sigtran --ip 172.18.0.201 \
	-v ggsn-vol:/data \
	--stop-signal SIGINT

include ../make/Makefile
