RUN_ARGS?=--sysctl net.ipv6.conf.all.disable_ipv6=0 --rm --network pdn --ip 172.20.0.10 --ip6 fd10:5741:8e20:0000::10 -v httpd-vol:/etc/lighttpd/lighttpd.conf.d --stop-signal SIGINT

include ../make/Makefile
