#!/bin/sh -ex
. ../jenkins-common.sh

docker_images_require \
	"debian-bullseye-obs-latest" \
	"release-tarball-build-dist"

docker run \
	--rm=true \
	-v "$PWD:/build" \
	-w /osmo-ci \
	-e KEEP_TEMP="$KEEP_TEMP" \
	"$USER/release-tarball-build-dist" sh -e /build/osmocom-release-tarballs.sh

if [ -z "$WORKSPACE" ]; then
	set +x
	echo "NOTE: not running on jenkins, skipping upload"
fi

cat > "$WORKSPACE/known_hosts" <<EOF
[ftp.osmocom.org]:48 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDgQ9HntlpWNmh953a2Gc8NysKE4orOatVT1wQkyzhARnfYUerRuwyNr1GqMyBKdSI9amYVBXJIOUFcpV81niA7zQRUs66bpIMkE9/rHxBd81SkorEPOIS84W4vm3SZtuNqa+fADcqe88Hcb0ZdTzjKILuwi19gzrQyME2knHY71EOETe9Yow5RD2hTIpB5ecNxI0LUKDq+Ii8HfBvndPBIr0BWYDugckQ3Bocf+yn/tn2/GZieFEyFpBGF/MnLbAAfUKIdeyFRX7ufaiWWz5yKAfEhtziqdAGZaXNaLG6gkpy3EixOAy6ZXuTAk3b3Y0FUmDjhOHllbPmTOcKMry9
[ftp.osmocom.org]:48 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPdWn1kEousXuKsZ+qJEZTt/NSeASxCrUfNDW3LWtH+d8Ust7ZuKp/vuyG+5pe5pwpPOgFu7TjN+0lVjYJVXH54=
[ftp.osmocom.org]:48 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8iivY70EiR5NiGChV39gRLjNpC8lvu1ZdHtdMw2zuX
EOF

SSH_COMMAND="ssh -o 'UserKnownHostsFile=$WORKSPACE/known_hosts' -p 48"
cd _release_tarballs
rsync -avz --delete -e "$SSH_COMMAND" . releases@ftp.osmocom.org:web-files/
