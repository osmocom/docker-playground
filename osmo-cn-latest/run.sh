#! /bin/sh

. ../jenkins-common.sh

docker_images_require \
	"osmo-cn-latest"

docker network create --subnet 192.168.42.0/24 $NET_NAME

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
		--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
	    	--network $NET_NAME --ip 192.168.42.10 \
		-p 0.0.0.0:23000:23000/udp \
		-v $VOL_BASE_DIR/osmo-cn:/data \
	       	--name osmo-cn \
	       	$REPO_USER/osmo-cn-latest

echo Stopping containers

docker_kill_wait osmo-cn

network_remove
