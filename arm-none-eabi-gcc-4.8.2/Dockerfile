FROM 	debian:stretch


ENV	BINUTILS_SRC=http://ftp.gnu.org/gnu/binutils/binutils-2.21.1a.tar.bz2
ENV	NEWLIB_SRC=https://sourceware.org/pub/newlib/newlib-1.19.0.tar.gz
ENV	GCC_SRC=http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2
ENV	PREFIX=/usr/local

# Install build tools and dependencies
RUN	apt update && apt install -y \
		build-essential \
		libmpfr-dev \
		libmpc-dev \
		libgmp3-dev \
		zlib1g-dev \
		zlibc \
		texinfo \
		bison \
		flex \
		curl \
		patch \
		file \
		python2.7-minimal \
		autoconf \
		libtool \
		git

# Stage 0: Download and patch the source code
RUN	curl -SL ${BINUTILS_SRC} | tar -xj -C /usr/src && \
	curl -SL ${NEWLIB_SRC} | tar -xz -C /usr/src && \
	curl -SL ${GCC_SRC} | tar -xj -C /usr/src

COPY	patches/ /usr/src/patches
RUN	for patch in /usr/src/patches/gcc-*.patch; do \
		patch -d /usr/src/gcc-* -p1 < $patch; \
	done

# Stage 1: Build and install binutils
RUN	mkdir -p /home/build/binutils && cd /home/build/binutils \
		&& /usr/src/binutils-*/configure \
			CFLAGS="-w" \
			--prefix=${PREFIX} \
			--disable-werror \
			--target=arm-none-eabi \
			--enable-interwork \
			--enable-threads=posix \
			--enable-multilib \
			--with-float=soft \
		&& make all install

# Stage 2: Build and install GCC (compiler only)
RUN	mkdir -p /home/build/gcc && cd /home/build/gcc \
		&& HDR_PATH=$(realpath /usr/src/newlib-*/newlib/libc/include) \
		&& /usr/src/gcc-*/configure \
			CFLAGS="-w" \
			--prefix=${PREFIX} \
			--disable-shared \
			--disable-werror \
			--target=arm-none-eabi \
			--enable-interwork \
			--enable-multilib \
			--with-float=soft \
			--enable-languages="c,c++" \
			--with-newlib \
			--with-headers=$HDR_PATH \
			--with-system-zlib \
		&& make all-gcc install-gcc

# Stage 3: Build and install newlib
RUN	mkdir -p /home/build/newlib && cd /home/build/newlib \
		&& /usr/src/newlib-*/configure \
			CFLAGS="-w" \
			--prefix=${PREFIX} \
			--disable-werror \
			--target=arm-none-eabi \
			--enable-interwork \
			--enable-multilib \
			--with-float=soft \
		&& make all install

# Stage 4: Build and install the rest of GCC
RUN	cd /home/build/gcc && make all install
