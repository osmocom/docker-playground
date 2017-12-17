#!/bin/sh

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

# non-jenkins execution: put logs in /tmp
if [ "x$WORKSPACE" = "x" ]; then
	WORKSPACE=/tmp
fi

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/bsc-tester
cp BSC_Tests.cfg $VOL_BASE_DIR/bsc-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/bsc
cp osmo-bsc.cfg $VOL_BASE_DIR/bsc/

echo Starting container with STP 
docker run	--rm \
		--network sigtran --ip 172.18.0.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name stp -d \
		$REPO_USER/osmo-stp-master

echo Starting container with BSC 
docker run	--rm \
		--network sigtran --ip 172.18.0.20 \
		-v $VOL_BASE_DIR/bsc:/data \
		--name bsc -d \
		$REPO_USER/osmo-bsc-master

for i in `seq 0 2`; do
	echo Starting container with OML for BTS$i
	docker run	--rm \
			--network sigtran --ip 172.18.0.10$i \
			--name bts$i -d \
			$REPO_USER/osmo-bts-omldummy ./respawn.sh 172.18.0.20 $((i + 1234))
done

echo Starting container with BSC testsuite
docker run	--rm \
		--network sigtran --ip 172.18.0.203 \
		-v $VOL_BASE_DIR/bsc-tester:/data \
		--name ttcn3-bsc-test \
		$REPO_USER/ttcn3-bsc-test

echo Stopping containers
for i in `seq 0 2`; do
	docker container kill bts$i
done
docker container kill bsc
docker container kill stp

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
#rm -rf $VOL_BASE_DIR
