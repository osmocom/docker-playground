#!/bin/sh +x

. ../jenkins-common.sh

if [ -z "$OSMO_INTERACT_VTY" ]; then
	OSMO_INTERACT_VTY="osmo-interact-vty.py"
fi

mkdir $VOL_BASE_DIR/osmo-hlr-master/
cp osmo-hlr.cfg $VOL_BASE_DIR/osmo-hlr-master/
mkdir $VOL_BASE_DIR/osmo-stp-master/
cp osmo-stp.cfg $VOL_BASE_DIR/osmo-stp-master/
mkdir $VOL_BASE_DIR/osmo-bsc-master/
cp osmo-bsc.cfg $VOL_BASE_DIR/osmo-bsc-master/
mkdir $VOL_BASE_DIR/osmo-msc-master/
cp osmo-msc.cfg $VOL_BASE_DIR/osmo-msc-master/
mkdir $VOL_BASE_DIR/osmo-mgw-master/
cp osmo-mgw.cfg $VOL_BASE_DIR/osmo-mgw-master/
mkdir $VOL_BASE_DIR/osmo-sgsn-master/
cp osmo-sgsn.cfg $VOL_BASE_DIR/osmo-sgsn-master/
mkdir $VOL_BASE_DIR/osmo-ggsn-master/
cp osmo-ggsn.cfg $VOL_BASE_DIR/osmo-ggsn-master/
mkdir $VOL_BASE_DIR/osmo-sip-master/
cp osmo-sip-connector.cfg $VOL_BASE_DIR/osmo-sip-master/


network_create 172.18.12.0/24

container_create() {
	NAME=$1
	IP_ADDR=$2

	docker run --rm --network ${NET_NAME} --ip ${IP_ADDR} \
		-v ${VOL_BASE_DIR}/${NAME}:/data \
		--name ${BUILD_TAG}-${NAME} -d \
		${REPO_USER}/${NAME}


}

container_create osmo-stp-master 172.18.12.200
container_create osmo-hlr-master 172.18.12.9
container_create osmo-mgw-master 172.18.12.201
container_create osmo-msc-master 172.18.12.203 
container_create osmo-bsc-master 172.18.12.11 
container_create osmo-sgsn-master 172.18.12.204
container_create osmo-ggsn-master 172.18.12.205
container_create osmo-sip-master 172.18.12.206

# Get asciidoc counter info
#${OSMO_INTERACT_VTY} \
#	-c "enable;show asciidoc counters" -p 4239 -H 172.18.12.200 -O stp_ctr.adoc
#${OSMO_INTERACT_VTY} \
#	-c "enable;show asciidoc counters" -p 4258 -H 172.18.12.9 -O hlr_ctr.adoc
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p 4243 -H 172.18.12.201 -O mgw_ctr.adoc
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p 4254 -H 172.18.12.203 -O msc_ctr.adoc
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p 4242 -H 172.18.12.11 -O bsc_ctr.adoc
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p 4245 -H 172.18.12.204 -O sgsn_ctr.adoc
${OSMO_INTERACT_VTY} \
	-c "enable;show asciidoc counters" -p 4260 -H 172.18.12.205 -O ggsn_ctr.adoc

# Get vty reference
${OSMO_INTERACT_VTY} \
	-X -p 4239 -H 172.18.12.200 -O stp_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4258 -H 172.18.12.9 -O hlr_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4243 -H 172.18.12.201 -O mgw_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4254 -H 172.18.12.203 -O msc_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4242 -H 172.18.12.11 -O bsc_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4245 -H 172.18.12.204 -O sgsn_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4260 -H 172.18.12.205 -O ggsn_vty_reference.xml
${OSMO_INTERACT_VTY} \
	-X -p 4256 -H 172.18.12.206 -O sipcon_vty_reference.xml

docker container kill ${BUILD_TAG}-osmo-stp-master
docker container kill ${BUILD_TAG}-osmo-hlr-master
docker container kill ${BUILD_TAG}-osmo-msc-master
docker container kill ${BUILD_TAG}-osmo-mgw-master
docker container kill ${BUILD_TAG}-osmo-bsc-master
docker container kill ${BUILD_TAG}-osmo-sgsn-master
docker container kill ${BUILD_TAG}-osmo-ggsn-master
docker container kill ${BUILD_TAG}-osmo-sip-master

network_remove

#####define OSMO_VTY_PORT_TRX       4237
#####define OSMO_VTY_PORT_STP       4239
#####define OSMO_VTY_PORT_PCU       4240    /* also: osmo_pcap_client */
#####define OSMO_VTY_PORT_BTS       4241    /* also: osmo_pcap_server */
#####define OSMO_VTY_PORT_NITB_BSC  4242
#####define OSMO_VTY_PORT_BSC_MGCP  4243
#####define OSMO_VTY_PORT_MGW       OSMO_VTY_PORT_BSC_MGCP
#####define OSMO_VTY_PORT_BSC_NAT   4244
#####define OSMO_VTY_PORT_SGSN      4245
#####define OSMO_VTY_PORT_GBPROXY   4246
#####define OSMO_VTY_PORT_BB        4247
#####define OSMO_VTY_PORT_BTSMGR    4252
#####define OSMO_VTY_PORT_GTPHUB    4253
#####define OSMO_VTY_PORT_MSC       4254
#####define OSMO_VTY_PORT_MNCC_SIP  4256
#####define OSMO_VTY_PORT_HLR       4258
#####define OSMO_VTY_PORT_GGSN      4260
#####define OSMO_VTY_PORT_HNBGW     4261
