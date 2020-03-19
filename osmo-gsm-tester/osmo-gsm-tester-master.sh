#!/bin/bash
set -x -e
# Add local IP addresses required by osmo-gsm-tester resources:
ip addr add 172.18.50.2/24 dev eth0 || true #already set by docker run --ip cmd
ip addr add 172.18.50.3/24 dev eth0
ip addr add 172.18.50.4/24 dev eth0
ip addr add 172.18.50.5/24 dev eth0
ip addr add 172.18.50.6/24 dev eth0
ip addr add 172.18.50.7/24 dev eth0
ip addr add 172.18.50.8/24 dev eth0
ip addr add 172.18.50.9/24 dev eth0
ip addr add 172.18.50.10/24 dev eth0

build_srslte() {
        git_repo_dir="/tmp/trial/${SRS_LTE_REPO_NAME}"
        if [ ! -d "$git_repo_dir" ]; then
                echo "No external trial nor git repo provided for srsLTE!"
                exit 1
        fi
        pushd "/tmp/trial"
        rm -rf inst && mkdir inst
        rm -rf build && mkdir build && cd build || exit 1
        cmake -DCMAKE_INSTALL_PREFIX="../inst/" "${git_repo_dir}"
        set +x; echo; echo; set -x
        make "-j$(nproc)"
        set +x; echo; echo; set -x
        make install
        this="srslte.build-${BUILD_NUMBER-$(date +%Y-%m-%d_%H_%M_%S)}"
        tar="${this}.tgz"
        tar czf "/tmp/trial/$tar" -C "/tmp/trial/inst" .
        cd "/tmp/trial/" && md5sum "$tar" >>checksums.md5
        popd
}

# Build srsLTE.git if not provided by host system:
if [ "x$(ls /tmp/trial/srslte.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
        build_srslte
fi

# Make trial dir avaialable to jenkins user inside container:
chown -R jenkins /tmp/trial/

rc=0
su -c "python3 -u /tmp/osmo-gsm-tester/src/osmo-gsm-tester.py /tmp/trial $OSMO_GSM_TESTER_OPTS" -m jenkins || rc=$?

# Make trial dir again owned by user running the container:
chown -R "${HOST_USER_ID}:${HOST_GROUP_ID}" /tmp/trial/

exit $rc
