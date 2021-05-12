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
# SRS_RAN_BRANCH: The srsRAN.git branch to fetch.
# SRS_RAN_REPO_PREFIX: The URL & prefix patch from where to clone the srsRAN.git
#                      repo.
# SRS_RAN_REPO_NAME: The srsRAN.git repo name, usually "srsRAN", but known to
#                    have different names on some forks.
#
# osmo-gsm-tester parameters and suites are passed to osmo-gsm-tester.sh in same
# directory as this script using environment variable OSMO_GSM_TESTER_OPTS.
#
# Log files can be found in host's /tmp/logs/ directory. Results generated by
# osmo-gsm-tester last run can be found as usual under the trial directory
# (/tmp/trial/last_run).

TRIAL_DIR="${TRIAL_DIR:-/tmp/trial}"

SRS_RAN_BRANCH=${SRS_RAN_BRANCH:-master}
SRS_RAN_REPO_PREFIX=${SRS_RAN_REPO_PREFIX:-git@github.com:srsran}
SRS_RAN_REPO_NAME=${SRS_RAN_REPO_NAME:-srsRAN}
OPEN5GS_REPO_PREFIX=${OPEN5GS_REPO_PREFIX:-git@github.com:open5gs}
OPEN5GS_BRANCH=${OPEN5GS_BRANCH:-main}
have_repo() {
	repo_prefix=$1
	repo_name=$2
	branch=$3
	echo "srsRAN inst not provided, fetching it now and it will be build in container"
	if [ -d "${TRIAL_DIR}/${repo_name}" ]; then
		git fetch -C ${TRIAL_DIR}/${repo_name}
	else
		mkdir -p ${TRIAL_DIR}
		git clone "${repo_prefix}/${repo_name}" "${TRIAL_DIR}/${repo_name}"
	fi
	# Figure out whether we need to prepend origin/ to find branches in upstream.
	# Doing this allows using git hashes instead of a branch name.
	if git -C "${TRIAL_DIR}/${repo_name}" rev-parse "origin/$branch"; then
	  branch="origin/$branch"
	fi

	git -C "${TRIAL_DIR}/${repo_name}" checkout -B build_branch "$branch"
	rm -rf "${TRIAL_DIR:?}/${repo_name}/*"
	git -C "${TRIAL_DIR}/${repo_name}" reset --hard "$branch"
}
# If srsRAN trial not provided by user, fetch srsRAN git repo and let the container build it:
if [ "x$(ls ${TRIAL_DIR}/srslte.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
	have_repo  $SRS_RAN_REPO_PREFIX $SRS_RAN_REPO_NAME $SRS_RAN_BRANCH
fi

# If open5gs trial not provided by user, fetch srsRAN git repo and let the container build it:
if [ "x$(ls ${TRIAL_DIR}/open5gs.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
	have_repo $OPEN5GS_REPO_PREFIX "open5gs" $OPEN5GS_BRANCH
	have_repo "https://github.com/open5gs" "freeDiameter" "r1.5.0"
	mv "${TRIAL_DIR}/freeDiameter" "${TRIAL_DIR}/open5gs/subprojects"
fi

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-buster-jenkins" \
	"osmo-gsm-tester"

set_clean_up_trap
set -e

SUBNET=50
network_create $SUBNET

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
		$(docker_network_params $SUBNET 100) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ogt-slave:/data \
		--name ${BUILD_TAG}-ogt-slave -d \
		$REPO_USER/osmo-gsm-tester \
		/bin/sh -c "/data/osmo-gsm-tester-slave.sh >/data/sshd.log 2>&1"

echo Starting container with osmo-gsm-tester main unit
OSMO_GSM_TESTER_CONF=${OSMO_GSM_TESTER_CONF:-/tmp/osmo-gsm-tester/sysmocom/main.conf}
OSMO_GSM_TESTER_OPTS=${OSMO_GSM_TESTER_OPTS:--T -l dbg -s 4g:srsue-rftype@zmq+srsenb-rftype@zmq+mod-enb-nprb@6 -t =ping.py}
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--ulimit rtprio=99 \
		--device /dev/net/tun:/dev/net/tun \
		$(docker_network_params $SUBNET 2) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ogt-master:/data \
		-v "${TRIAL_DIR}:/tmp/trial" \
		-e "OSMO_GSM_TESTER_CONF=${OSMO_GSM_TESTER_CONF}" \
		-e "OSMO_GSM_TESTER_OPTS=${OSMO_GSM_TESTER_OPTS}" \
		-e "SRS_RAN_REPO_NAME=${SRS_RAN_REPO_NAME}" \
		-e "HOST_USER_ID=$(id -u)" \
		-e "HOST_GROUP_ID=$(id -g)" \
		--name ${BUILD_TAG}-ogt-master \
		$REPO_USER/osmo-gsm-tester
rc=$?

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
if [ $rc -eq 0 ]; then
	echo -e "${GREEN}SUCCESS${NC}"
else
	echo -e "${RED}FAILED ($rc)${NC}"
fi
