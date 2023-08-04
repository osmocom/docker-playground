ARG	USER
FROM	$USER/debian-bookworm-build

# Arguments used after FROM must be specified again
ARG	FPGA_TOOLCHAIN_DATE=20200914
ARG	RISCV_TOOLCHAIN_VER=8.3.0-1.2

# Install fpga-toolchain
RUN	set -x && \
	wget --quiet https://github.com/open-tool-forge/fpga-toolchain/releases/download/nightly-${FPGA_TOOLCHAIN_DATE}/fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz && \
	tar -C /opt -xf fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz && \
	rm fpga-toolchain-linux_x86_64-nightly-${FPGA_TOOLCHAIN_DATE}.tar.xz

# Install riscv-none-embed-gcc
RUN	set -x && \
	wget --quiet https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v${RISCV_TOOLCHAIN_VER}/xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz && \
	tar -C /opt -xf /xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz && \
	rm xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}-linux-x64.tar.gz

ENV	PATH=/opt/fpga-toolchain/bin:/opt/xpack-riscv-none-embed-gcc-${RISCV_TOOLCHAIN_VER}/bin:${PATH}
