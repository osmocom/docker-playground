Osmocom docker playground
=========================

This repository contains some humble attempts at creating some Docker
containers + related stacks around Osmocom.

Historically this repository had all containers for running the TTCN3
testsuites. We are porting them over to the new testenv configurations
inside `osmo-ttcn3-hacks.git` and removing them afterwards from
`docker-playground.git`. See
[_testenv/README.md](https://gitea.osmocom.org/ttcn3/osmo-ttcn3-hacks/src/branch/master/_testenv/README.md)
for more information, and [OS#6494](https://osmocom.org/issues/6494)
for reasoning.

## Running a testsuite
All testsuite folders start with `ttcn3` or `nplab`. Run the following
to build/update all required containers from the "master" branch and
start a specific testsuite:

```
$ cd ttcn3-mgw-test
$ ./jenkins.sh
```

Environment variables:
* `IMAGE_SUFFIX`: the version of the Osmocom stack to run the testsuite
  against. Default is `master`, set this to `latest` to test the last
  stable releases.
* `OSMO_TTCN3_BRANCH`: [osmo-ttcn3-hacks.git](https://gitea.osmocom.org/ttcn3/osmo-ttcn3-hacks)
  branch, which will be used when building a `ttcn3-*` docker image.
  Defaults to `master`.
* `OSMO_BSC_BRANCH`, `OSMO_MSC_BRANCH`, ...: branch of the appropriate
  Osmocom project. Defaults to `master`.
* `NO_DOCKER_IMAGE_BUILD`: when set to `1`, it won't try to update the
  containers (see "caching" below)
* `NO_DOCKER_IMAGE_PULL`: when running `docker build`, don't add `--pull`
* `DOCKER_ARGS`: pass extra arguments to docker, e.g. to mount local sources
  for building as done in osmo-dev.git/ttcn3/ttcn3.sh
* `TEST_CONFIGS`: for tests that can run with multiple config sets (e.g.
  `ttcn3-bts-test`), run only some of them. See `TEST_CONFIGS_ALL` in the
  `jenkins.sh` for possible values.
* `RUN_BPFTRACE`: when set to `1`, run bpftrace scripts in `ttcn3-bts-test`.

### Run only one test

Run only `TC_gsup_sai` in `ttcn3-hlr-test`:

```
$ cd ttcn3-hlr-test
$ export DOCKER_ARGS="-e TEST_NAME=TC_gsup_sai"
$ ./jenkins.sh
```

Run only `TC_est_dchan` in `ttcn3-bts-test`, with the `generic` configuration:

```
$ cd ttcn3-bts-test
$ export DOCKER_ARGS="-e TEST_NAME=TC_est_dchan"
$ export TEST_CONFIGS="generic"
$ ./jenkins.sh
```

### Using nightly packages from a different date

Pick a date from [here](https://downloads.osmocom.org/obs-mirror/) and use it:

```
$ export OSMOCOM_REPO_PATH="obs-mirror/20230316-061901"
$ cd ttcn3-bsc-test
$ ./jenkins.sh
```

### More examples

latest (debian):
```
$ export IMAGE_SUFFIX="latest"
$ cd ttcn3-mgw-test
$ ./jenkins.sh
```

latest-centos8:
```
$ export IMAGE_SUFFIX="latest-centos8"
$ cd ttcn3-mgw-test
$ ./jenkins.sh
```

2021q1-centos8:
```
export OSMOCOM_REPO_TESTSUITE_MIRROR="https://downloads.osmocom.org"
export OSMOCOM_REPO_MIRROR="https://downloads.osmocom.org"
export OSMOCOM_REPO_PATH="osmo-maintained"
export OSMOCOM_REPO_VERSION="2021q1"
export IMAGE_SUFFIX="2021q1-centos8"
$ cd ttcn3-mgw-test
$ ./jenkins.sh
```

## Kernel test
OsmoGGSN can be configured to either run completely in userspace, or to
use the GTP-U kernel module. To test the kernel module, OsmoGGSN and
the kernel module will run with a Linux kernel (either the pre-built
one from Debian, or a custom built one) in QEMU inside docker. As of
writing, `ttcn3-ggsn-test` is the only testsuite where it makes
sense to test kernel modules. But the same environment variables could
be used for other testsuites in the future.

Environment variables:
* `KERNEL_TEST`: set to 1 to run the SUT in QEMU
* `KERNEL_TEST_KVM`: set to 0 to disable KVM acceleration
* `KERNEL_BUILD`: set to 1 to build the kernel instead of using the
  pre-built one
* `KERNEL_REMOTE_NAME`: git remote name (to add multiple git
  repositories in the same local linux clone, default: net-next)
* `KERNEL_URL`: git remote url (default: net-next.git on kernel.org)
* `KERNEL_BRANCH` branch to checkout (default: main)
* `KERNEL_SKIP_REBUILD`: set to 1 to not build the kernel again if already
  built with `KERNEL_BUILD=1`
* `KERNEL_SKIP_SMOKE_TEST`: don't boot up the kernel in QEMU once before
  running the testsuite

The OBS repository mirror consists of
`${OSMOCOM_REPO_MIRROR}/${OSMOCOM_REPO_PATH}/${OSMOCOM_REPO_VERSION}`,
e.g. `https://downloads.osmocom.org/packages/osmocom:/latest/`.

### Creating kernel config fragments
For the kernel tests, we are storing kernel config fragments in the git
repository instead of full kernel configs. Generate them as follows:

```
$ cd _cache/linux
$ cp custom.config .config
$ make olddefconfig
$ cp .config custom-updated.config
$ make defconfig  # config to which to diff
$ scripts/diffconfig -m .config custom-updated.config > fragment.config
```

Verify that it was done right:
```
$ make defconfig
$ scripts/kconfig/merge_config.sh -m .config fragment.config
$ make olddefconfig
$ diff .config custom-updated.config  # should be the same
```

## Building containers manually
Most folders in this repository contain a `Dockerfile`. Build a docker
container with the same name as the folder like this:

```
$ cd debian-stretch-build
$ make
```

## Caching
All folders named `osmo-*-latest` and `osmo-*-master` build the latest
stable or most recent commit from `master` of the corresponding Osmocom
program's git repository. When you have built it already, running `make`
will only do a small HTTP request to check if the sources are outdated
and skip the build in case it is still up-to-date.

## Dependencies
Folders that don't have a `jenkins.sh` usually only depend on the
container that is specified in the `FROM` line of their `Dockerfile`.
Testsuites depend on multiple containers, they are defined on top of
each `jenkins.sh`:

```shell
. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-bsc-$IMAGE_SUFFIX" \
	"osmo-bts-$IMAGE_SUFFIX" \
	"ttcn3-bsc-test"
```

#### Reasoning for this implementation
Before having the `docker_images_require` lines, there used to be a
top-level `Makefile` for resolving dependencies between the containers.
But it was prone to mistakes: when new folders in the repository
were added without related targets in the `Makefile`, `make` would
always assume that the targets where the always existing folders and
therefore never build the containers.

In order to implement testing `latest` in addition to `master`
([OS#3268](https://osmocom.org/issues/3268)), it would have been
necessary to add further complexity to the `Makefile`. Instead it was
decided to scrap the file, and just keep the short list of dependencies
right above where they would be needed in the `jenkins.sh`.

## Obtaining gdb backtrace from crash

If for instance TTCN3 test is producing a crash on a program running in docker,
eg. osmo-msc, it is desirable to get a full crash report. This section describes
how to do so.

First, open `osmo-$program/Dockerfile` and add lines to install `gdb` plus
`$program` dependency debug packages. For instance:

```
+RUN    apt-get install -y --no-install-recommends \
+               gdb \
+               libosmocore-dbg libosmo-abis-dbg libosmo-netif-dbg libosmo-sigtran-dbg osmo-msc-dbg && \
+               apt-get clean
```

In same `Dockerfile` file, modify configure to build with debug symbols enabled
and other interesting options, such as `--enable-sanitize`:

```
-       ./configure --enable-smpp --enable-iu && \
+       export CPPFLAGS="-g -O0 -fno-omit-frame-pointer" && \
+       export CFLAGS="-g -O0 -fno-omit-frame-pointer" && \
+       export CXXFLAGS="-g -O0 -fno-omit-frame-pointer" && \
+       ./configure --enable-smpp --enable-iu --enable-sanitize && \
```

Finally open the script you use to run the program (for instance
`ttcn3-$program-master/jenkins.sh`), and modify it to launch the process using
gdb, and to print a full backtrace when control returns to gdb (when the process
crashes):

```
-/bin/sh -c "osmo-msc -c /data/osmo-msc.cfg >>/data/osmo-msc.log 2>&1"
+/bin/sh -c "gdb -ex 'run' -ex 'bt full' --arg osmo-msc -c /data/osmo-msc.cfg >>/data/osmo-msc.log 2>&1"
```

## See also
* [Overhyped Docker](http://laforge.gnumonks.org/blog/20170503-docker-overhyped/)
  for related rambling on why this doesn't work as well as one would
  want.
* [Osmocom wiki: Titan TTCN3 Testsuites](https://osmocom.org/projects/cellular-infrastructure/wiki/Titan_TTCN3_Testsuites)
