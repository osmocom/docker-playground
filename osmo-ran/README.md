This directory provides an environment to set up and run an Osmocom RAN
(osmo-bts, osmo-pcu, osmo-bsc, osmo-mgw) managed by systemd, all run inside a
docker container.

Easiest way to build + run the setup is to execute _jenkins.sh_ in this same
directory.

This script will build the Dockerfile image, then set up a bridge network on
subnet `172.18.$SUBNET.0/24`, where the IP address `172.18.$SUBNET.200` is
assigned to the internal network interface inside the docker container (and
which RAN processes will be using), and `172.18.$SUBNET.1` is assigned to the
bridge network interface outside the docker container. All The VTY and CTRL
ports are available on both `172.18.$SUBNET.200` and also on `172.18.$SUBNET.1`
(through docker port mapping).

Shared directories between docker container and the host are mounted in
_/tmp/logs/ran-$SUBNET/_ on the host, with _osmocom_ subdirectory mapping to
container's _/etc/osmocom_, and _data_ to _/data:_.

The script has the following parameters (environment variables):
- `SUBNET`: The IPv4 subnet to configure and use (`172.18.$SUBNET.0/24`) when
  running the container (defaults to `25`)
- `SGSN_IP`: The IP address where the SGSN outside the docker container listens to (Gb interface)
- `STP_IP`: The IP address where the STP outside the docker container listens to (A interface)
- `TRX_IP`: The IP address where the OsmoTRX outside the docker container listens to (TRXC/TRXD interface)
- `IMAGE_SUFFIX`: Type of base image to use: Leave unset to build on top of
  Debian (default), set to `centos8` to run on top of CentOS8 distribution
- `OSMOCOM_REPO_VERSION`: Osmocom OBS repository version to use: `nightly` or `latest` (default).

The above IP addresses will be replaced by _jenkins.sh_ from tokens of the same
name in the provided configuration files, available in _osmocom/_ directory,
which will be then placer inside docker image's `/etc/osmocom/` directory, where
the osmocom projects will read the configuration by default (see systemd
services).

Example:
Run Osmocom RAN on a Centos8 distro with osmocom's nightly repository on subnet 26:
```
OSMOCOM_REPO_VERSION="nightly" IMAGE_SUFFIX="centos8" SUBNET=26 ./jenkins.sh
```

If several independent RANs are to be set up by the user, it's up to them to
configure iptables rules to forbid access from one docker container to another.
It should be doable pretty easily by rejecting connections between
`172.18.$subnetA.0/24` and `172.18.$subnetB.0/24`.

The docker container started by _jenkins.sh_ is running systemd and hence is
expected to run forever (until the container instance is killed through docker
or by killing the process, eg. pressing CTRL+C on the terminal).

While the container is running, shell access to to it in order inspect the RAN
processes managed by systemd can be obtained by using:
```
docker exec -it nonjenkins-ran-subnet$SUBNET bash
```
