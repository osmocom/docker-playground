#!/bin/sh

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

LOGDIR=$WORKSPACE/logs

rm -rf $LOGDIR || /bin/true
mkdir -p $LOGDIR

# start container with STP in background
docker volume rm stp-vol || /bin/true
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network sigtran --ip 172.18.0.200 \
		-v stp-vol:/data \
		--name stp \
		-d $REPO_USER/osmo-stp-master

# start docker container with tests
docker volume rm m3ua-test-vol || /bin/true
docker run	--rm \
		--network sigtran --ip 172.18.0.2 \
		-v m3ua-test-vol:/data \
		$REPO_USER/m3ua-test > $LOGDIR/junit-xml-m3ua.log

docker container stop -t 1 stp

# start some stupid helper container so we can access the volume
docker run	--rm \
		-v m3ua-test-vol:/m3ua-test \
		-v stp-vol:/stp \
		--name helper \
		-d busybox /bin/sh -c 'sleep 1000 & wait'
docker cp helper:/m3ua-test $LOGDIR
docker cp helper:/stp $LOGDIR
docker container stop -t 0 helper
