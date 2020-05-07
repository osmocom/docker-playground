#
# spec file for package osmocom-bb-jolly-testing
#
# Copyright (c) 2017, Martin Hauke <mardnh@gmx.de>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

%define build_firmware 1
%define osmocom_bb_dir /opt/osmocom-bb-jolly-testing

Name:           osmocom-bb-jolly-testing
Version:        0.0.0.git1519031227.9516a0e5
Release:        0
Summary:        OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) (jolly/testing)
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
Url:            http://bb.osmocom.org/trac/
Source:         osmocom-bb-%{version}.tar.xz
Patch2:         osmocom-bb-enable-tx.patch
Patch4:         0001-layer23-Fix-build-against-gpsd-3.18.patch
Patch5:         0001-layer23-Fix-build-against-gpsd-3.20.patch
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  gcc-c++
# SLES does not provide gpsd-devel, so build without gps-support on those systems
%if 0%{?is_opensuse}
BuildRequires:  pkgconfig(libgps)
%endif
BuildRequires:  pkgconfig(libosmocodec)
BuildRequires:  pkgconfig(libosmocore)
BuildRequires:  pkgconfig(libosmogsm)
BuildRequires:  pkgconfig(libosmovty)
BuildRequires:  pkgconfig(libosmodsp)
BuildRequires:  libtool
BuildRequires:  pkg-config
BuildRequires:  python
BuildRequires:  git-core
%if 0%{?build_firmware}
BuildRequires:  arm-elf-binutils
BuildRequires:  arm-elf-gcc
# HACK: Disable all post-build-checks
BuildRequires:  -post-build-checks
%endif
ExclusiveArch:  %ix86 x86_64

%description
OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) including firmware.

%package firmware
Summary:        OsmocomBB MS-side GSM Protocol stack - firmware (jolly/testing)
Group:          Productivity/Telephony/Utilities
Requires:       %{name} = %{version}

%description firmware
OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) including firmware.

This subpackage provides firmware-images for various TI-calypto based
phones.

%prep
%setup -q -n osmocom-bb-%{version}
%patch2 -p1
%patch4 -p1
%patch5 -p1

%build
echo "%{version}" >src/host/osmocon/.tarball-version
echo "%{version}" >src/host/gsmmap/.tarball-version
echo "%{version}" >src/shared/libosmocore/.tarball-version

%if 0%{?build_firmware}
export PATH=$PATH:/opt/arm-elf-toolchain/bin
make V=1 -C src/ %{?_smp_mflags} HOST_layer23_CONFARGS=--enable-transceiver
%else
make V=1 nofirmware -C src/ %{?_smp_mflags} HOST_layer23_CONFARGS=--enable-transceiver
%endif


%install
mkdir -p %{buildroot}/%{osmocom_bb_dir}
install -Dm 0755 src/host/osmocon/osmocon %{buildroot}/%{osmocom_bb_dir}/host/osmocon/osmocon
install -Dm 0755 src/host/osmocon/osmoload %{buildroot}/%{osmocom_bb_dir}/host/osmocon/osmoload
install -Dm 0755 src/host/layer23/src/misc/bcch_scan %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/misc/bcch_scan
install -Dm 0755 src/host/layer23/src/misc/cbch_sniff %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/misc/cbch_sniff
install -Dm 0755 src/host/layer23/src/misc/ccch_scan %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/misc/ccch_scan
install -Dm 0755 src/host/layer23/src/misc/cell_log %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/misc/cell_log
install -Dm 0755 src/host/layer23/src/misc/echo_test %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/misc/echo_test
install -Dm 0755 src/host/layer23/src/mobile/mobile %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/mobile/mobile
install -Dm 0755 src/host/layer23/src/transceiver/transceiver %{buildroot}/%{osmocom_bb_dir}/host/layer23/src/transceiver/transceiver
install -Dm 0755 src/host/gsmmap/gsmmap %{buildroot}/%{osmocom_bb_dir}/host/gsmmap/gsmmap

%if 0%{?build_firmware}
### Firmware
# Compal E86
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e86/
cp src/target/firmware/board/compal_e86/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e86/
# Compal E88
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e88/
cp src/target/firmware/board/compal_e88/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e88/
# Compal E99
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e99/
cp src/target/firmware/board/compal_e99/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e99/
# OpenMoko GTA0x
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gta0x/
cp src/target/firmware/board/gta0x/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gta0x/
# Pirelli DP-L10
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/pirelli_dpl10/
cp src/target/firmware/board/pirelli_dpl10/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/pirelli_dpl10/
# Sony Erricson J100
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/se_j100/
cp src/target/firmware/board/se_j100/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/se_j100/
%endif

%files
%{osmocom_bb_dir}/host

%if 0%{?build_firmware}
%files firmware
%{osmocom_bb_dir}/target
%endif

%changelog
