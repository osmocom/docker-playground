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

build_srsran() {
        git_repo_dir="/tmp/trial/${SRS_RAN_REPO_NAME}"
        if [ ! -d "$git_repo_dir" ]; then
                echo "No external trial nor git repo provided for srsRAN!"
                exit 1
        fi
        pushd "/tmp/trial"
        rm -rf sysroot && mkdir sysroot
        rm -rf build && mkdir build && cd build || exit 1
        cmake -DCMAKE_INSTALL_PREFIX="../sysroot/" "${git_repo_dir}"
        set +x; echo; echo; set -x
        make "-j$(nproc)"
        set +x; echo; echo; set -x
        make install
        cd ..
        # REMARK: OGT still uses old naming "srslte" for the trial.
        this="srslte.build-${BUILD_NUMBER-$(date +%Y-%m-%d_%H_%M_%S)}"
        tar="${this}.tgz"
        tar czf "/tmp/trial/$tar" -C "/tmp/trial/sysroot" .
        rm -rf build sysroot
        md5sum "$tar" >>checksums.md5
        popd
}

build_open5gs() {
        git_repo_dir="/tmp/trial/open5gs"
        if [ ! -d "$git_repo_dir" ]; then
                echo "No external trial nor git repo provided for Open5GS!"
                exit 1
        fi
        pushd "/tmp/trial"
        rm -rf sysroot && mkdir sysroot
        rm -rf build && mkdir build && cd build || exit 1
        meson "${git_repo_dir}" --prefix="/tmp/trial/sysroot" --libdir="lib"
        set +x; echo; echo; set -x
        ninja "-j$(nproc)"
        set +x; echo; echo; set -x
        ninja install
        find "/tmp/trial/sysroot/lib" -depth -type f -name "lib*.so.*" -exec patchelf --set-rpath '$ORIGIN/' {} \;
        cd ..
        this="open5gs.build-${BUILD_NUMBER-$(date +%Y-%m-%d_%H_%M_%S)}"
        tar="${this}.tgz"
        tar czf "/tmp/trial/$tar" -C "/tmp/trial/sysroot" .
        rm -rf build sysroot
        md5sum "$tar" >>checksums.md5
        popd
}

# Build srsRAN.git if not provided by host system:
if [ "x$(ls /tmp/trial/srslte.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
        build_srsran
fi

# Build open5gs.git if not provided by host system:
if [ "x$(ls /tmp/trial/open5gs.*.tgz 2>/dev/null | wc -l)" = "x0" ]; then
        build_open5gs
fi

# If open5gs is available, start mongodb in the background:
if [ "x$(ls /tmp/trial/open5gs.*.tgz 2>/dev/null | wc -l)" != "x0" ]; then
        echo "Starting mongodb in the background..."
        /usr/bin/mongod --fork --config /etc/mongod.conf --logpath /data/mongodb.log
        chown "${HOST_USER_ID}:${HOST_GROUP_ID}" /data/mongodb.log
fi

# Make trial dir avaialable to jenkins user inside container:
chown -R jenkins /tmp/trial/

rc=0
su -c "python3 -u /tmp/osmo-gsm-tester/src/osmo-gsm-tester.py -c \"$OSMO_GSM_TESTER_CONF\" /tmp/trial $OSMO_GSM_TESTER_OPTS" -m jenkins || rc=$?

# Make trial dir again owned by user running the container:
chown -R "${HOST_USER_ID}:${HOST_GROUP_ID}" /tmp/trial/

exit $rc
