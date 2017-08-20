#!/bin/sh

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" == "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" == "x" ]; then
	WORKSPACE=/tmp
fi

# start container with ggsn in background
docker volume rm ggsn-vol
docker run	--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--rm \
		--network sigtran --ip 172.18.0.201 \
		-v ggsn-vol:/data \
		--name ggsn -d \
		$REPO_USER/osmo-ggsn-master

# start docker container with testsuite in foreground
docker volume rm ggsn-test-vol
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network sigtran --ip 172.18.0.202 \
		-v ggsn-test-vol:/data \
		$REPO_USER/ggsn-test

# stop GGSN after test has completed
docker container stop ggsn

# start some stupid helper container so we can access the volume
docker run	--rm \
		-v ggsn-test-vol:/ggsn-tester \
		-v ggsn-vol:/ggsn \
		--name helper -d \
		busybox /bin/sh -c 'sleep 1000 & wait'
rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
docker cp helper:/ggsn-tester $WORKSPACE/logs
docker cp helper:/ggsn $WORKSPACE/logs
docker container stop -t 0 helper
