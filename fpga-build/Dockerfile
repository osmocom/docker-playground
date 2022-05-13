ARG	USER
FROM	$USER/debian-buster-build


ARG	FPGA_TOOLCHAIN_DATE=20200914
ARG	RISCV_TOOLCHAIN_VER=8.3.0-1.2

RUN	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		asciidoc \
		asciidoc-dblatex \
		dblatex \
		docbook5-xml \
		graphviz \
		inkscape \
		mscgen \
		python3-nwdiag \
		rsync \
		ssh \
		wget \
		xsltproc && \
	apt-get clean


RUN	wget https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-${FPGA_TOOLCHAIN_DATE}/fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz
RUN	tar -C /opt -xf fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz && \
	rm fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz

RUN	wget --quiet https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v${RISCV_TOOLCHAIN_VER}/xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz
RUN	tar -C /opt -xf /xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz && \
	rm xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz

# match the outside user
RUN	useradd --uid=1000 build
RUN	mkdir /build
RUN	chown build:build /build

ENV	PATH=/opt/fpga-toolchain/bin:/opt/xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}/bin:${PATH}

# Install osmo-ci.git/scripts to /usr/local/bin
ADD	http://git.osmocom.org/osmo-ci/patch /tmp/osmo-ci-commit
RUN	git clone https://git.osmocom.org/osmo-ci osmo-ci && \
	cp -v $(find osmo-ci/scripts \
		-maxdepth 1 \
		-type f ) \
	   /usr/local/bin

# Install osmo-gsm-manuals to /opt/osmo-gsm-manuals
ADD	http://git.osmocom.org/osmo-gsm-manuals/patch /tmp/osmo-gsm-manuals-commit
RUN	git -C /opt clone https://git.osmocom.org/osmo-gsm-manuals
