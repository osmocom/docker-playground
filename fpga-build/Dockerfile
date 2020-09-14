ARG	USER
FROM	$USER/debian-buster-build

MAINTAINER Harald Welte <laforge@gnumonks.org>

ARG	TOOLCHAIN_DATE=20200914

RUN	wget --quiet https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-$TOOLCHAIN_DATE/fpga-toolchain-linux_x86_64-nightly-$TOOLCHAIN_DATE.tar.gz
RUN	tar -C /opt -xzf fpga-toolchain-linux_x86_64-nightly-$TOOLCHAIN_DATE.tar.gz && \
	rm fpga-toolchain-linux_x86_64-nightly-$TOOLCHAIN_DATE.tar.gz

RUN	wget --quiet https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v8.3.0-1.2/xpack-riscv-none-embed-gcc-8.3.0-1.2-linux-x64.tar.gz
RUN	tar -C /opt -xzvf /xpack-riscv-none-embed-gcc-8.3.0-1.2-linux-x64.tar.gz && \
	rm xpack-riscv-none-embed-gcc-8.3.0-1.2-linux-x64.tar.gz

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		wget && \
	apt-get clean

RUN	useradd -m osmocom
USER	osmocom
WORKDIR	/home/osmocom

ENV	PATH=/opt/fpga-toolchain/bin:/opt/xpack-riscv-none-embed-gcc-8.3.0-1.2/bin:${PATH}
