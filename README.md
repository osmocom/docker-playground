Osmocom docker playground
=========================

This repository contains some humble attempts at creating some Docker
containers + related stacks around Osmocom.   So far, the main focus is
test automation.

## Running a testsuite
All testsuite folders start with `ttcn3` or `nplab`. Run the following
to build/update all required containers and start a specific testsuite:

```
$ cd ttcn3-mgw-test
$ ./jenkins.sh
```

Arguments to `jenkins.sh` are passed to the TTCN-3 testsuite executable.
With the following example, only a single test gets started:

FIXME

Environment variables:
* `IMAGE_SUFFIX`: the version of the Osmocom stack to run the testsuite
  against. Default is `master`, set this to `latest` to test the last
  stable releases.
* `OSMO_TTCN3_BRANCH`: [osmo-ttcn3-hacks.git](https://git.osmocom.org/osmo-ttcn3-hacks/)
  branch, which will be used when building a `ttcn3-*` docker image.
  Defaults to `master`.
* `NO_DOCKER_IMAGE_BUILD`: when set to `1`, it won't try to update the
  containers (see "caching" below)

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
