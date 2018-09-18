#! /bin/sh

. ../jenkins-common.sh

network_create 192.168.42.0/24

mkdir $VOL_BASE_DIR/osmo-cn
cp osmo-stp.cfg $VOL_BASE_DIR/osmo-cn/
cp osmo-msc.cfg $VOL_BASE_DIR/osmo-cn/
cp osmo-hlr.cfg $VOL_BASE_DIR/osmo-cn/
cp osmo-mgw.cfg $VOL_BASE_DIR/osmo-cn/
cp osmo-sgsn.cfg $VOL_BASE_DIR/osmo-cn/
cp osmo-ggsn.cfg $VOL_BASE_DIR/osmo-cn/
cp hlr.db $VOL_BASE_DIR/osmo-cn/

echo Starting Osmocom core services
docker run	--rm \
	    	--network $NET_NAME --ip 192.168.42.10 \
		-v $VOL_BASE_DIR/osmo-cn:/data \
	       	--name osmo-cn \
	       	$REPO_USER/osmo-cn-latest

echo Stopping containers

docker container kill osmo-cn

network_remove
