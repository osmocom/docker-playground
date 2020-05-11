#!/bin/sh

# This docker env allows running a typical osmo-gsm-tester setup with a main
# unit (ogt-master) running osmo-gsm-tester process, and using another docker
# container as a remote host where to run child processes.
#
# Trial directory to use may be placed in the container's host /tmp/trial path,
# which will then be mounted to ogt-master and used my osmo-gsm-tester.
# If no inst is detected, then jenkins.sh will attempt to fetch the sources in
# the host system (so that host's user ssh keys are potentially available) under
# /tmp/trial, and the inst is then later built inside the container.
# Several env vars are available to tweak where to fetch from.
# SRS_LTE_BRANCH: The srsLTE.git branch to fetch.
# SRS_LTE_REPO_PREFIX: The URL & prefix patch from where to clone the srsLTe.git
#                      repo.
# SRS_LTE_REPO_NAME: The srsLTE.git repo name, usually "srsLTE", but known to
#                    have different names on some forks.
#
# osmo-gsm-tester parameters and suites are passed to osmo-gsm-tester.sh in same
# directory as this script using environment variable OSMO_GSM_TESTER_OPTS.
#
# Log files can be found in host's /tmp/logs/ directory. Results generated by
# osmo-gsm-tester last run can be found as usual under the trial directory
# (/tmp/trial/last_run).

TRIAL_DIR="${TRIAL_DIR:-/tmp/trial}"

SRS_LTE_BRANCH=${SRS_LTE_BRANCH:-master}
SRS_LTE_REPO_PREFIX=${SRS_LTE_REPO_PREFIX:-git@github.com:srsLTE}
SRS_LTE_REPO_NAME=${SRS_LTE_REPO_NAME:-srsLTE}
have_repo_srslte() {
	echo "srsLTE inst not provided, fetching it now and it will be build in container"
	if [ -d "${TRIAL_DIR}/${SRS_LTE_REPO_NAME}" ]; then
		git fetch -C ${TRIAL_DIR}/${SRS_LTE_REPO_NAME}
	else
		mkdir -p ${TRIAL_DIR}
		git clone "${SRS_LTE_REPO_PREFIX}/${SRS_LTE_REPO_NAME}" "${TRIAL_DIR}/${SRS_LTE_REPO_NAME}"
	fi
	# Figure out whether we need to prepend origin/ to find branches in upstream.
	# Doing this allows using git hashes instead of a branch name.
	if git -C "${TRIAL_DIR}/${SRS_LTE_REPO_NAME}" rev-parse "origin/$SRS_LTE_BRANCH"; then
	  SRS_LTE_BRANCH="origin/$SRS_LTE_BRANCH"
	fi

	git -C "${TRIAL_DIR}/${SRS_LTE_REPO_NAME}" checkout -B build_branch "$SRS_LTE_BRANCH"
	rm -rf "${TRIAL_DIR:?}/${SRS_LTE_REPO_NAME}/*"
	git -C "${TRIAL_DIR}/${SRS_LTE_REPO_NAME}" reset --hard "$SRS_LTE_BRANCH"
}

# If srsLTE trial not provided by user, fetch srsLTE git repo and let the container build it:
if [ "x$(ls ${TRIAL_DIR}/srslte.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
	have_repo_srslte
fi

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-jenkins" \
	"osmo-gsm-tester"

network_create 172.18.50.0/24

mkdir $VOL_BASE_DIR/ogt-slave
cp osmo-gsm-tester-slave.sh $VOL_BASE_DIR/ogt-slave/

mkdir $VOL_BASE_DIR/ogt-master
cp osmo-gsm-tester-master.sh $VOL_BASE_DIR/ogt-master/

echo Starting container with osmo-gsm-tester slave
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--ulimit rtprio=99 \
		--device /dev/net/tun:/dev/net/tun \
		--network $NET_NAME \
		--ip 172.18.50.100 \
		-v $VOL_BASE_DIR/ogt-slave:/data \
		--name ${BUILD_TAG}-ogt-slave -d \
		$REPO_USER/osmo-gsm-tester \
		/bin/sh -c "/data/osmo-gsm-tester-slave.sh >/data/sshd.log 2>&1"

echo Starting container with osmo-gsm-tester main unit
OSMO_GSM_TESTER_CONF=${OSMO_GSM_TESTER_CONF:-/tmp/osmo-gsm-tester/sysmoco/main.conf}
OSMO_GSM_TESTER_OPTS=${OSMO_GSM_TESTER_OPTS:--T -l dbg -s 4g:srsenb-rftype@zmq+srsue-rftype@zmq -t ping}
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--ulimit rtprio=99 \
		--device /dev/net/tun:/dev/net/tun \
		--network $NET_NAME \
		--ip 172.18.50.2 \
		-v $VOL_BASE_DIR/ogt-master:/data \
		-v "${TRIAL_DIR}:/tmp/trial" \
		-e "OSMO_GSM_TESTER_CONF=${OSMO_GSM_TESTER_CONF}" \
		-e "OSMO_GSM_TESTER_OPTS=${OSMO_GSM_TESTER_OPTS}" \
		-e "SRS_LTE_REPO_NAME=${SRS_LTE_REPO_NAME}" \
		-e "HOST_USER_ID=$(id -u)" \
		-e "HOST_GROUP_ID=$(id -g)" \
		--name ${BUILD_TAG}-ogt-master \
		$REPO_USER/osmo-gsm-tester
rc=$?

echo Stopping containers
docker container kill ${BUILD_TAG}-ogt-slave

network_remove
collect_logs

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
if [ $rc -eq 0 ]; then
	echo -e "${GREEN}SUCCESS${NC}"
else
	echo -e "${RED}FAILED ($rc)${NC}"
fi
