#
# spec file for package osmocom-bb
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

%ifarch %{ix86} x86_64
%define build_firmware 1
%else
%define build_firmware 0
%endif

%if 0%{?centos_ver}
%define build_firmware 0
%endif

%define osmocom_bb_dir /opt/osmocom-bb

Name:           osmocom-bb
Version:        0.0.0.git1588674152.901ac897
Release:        0
Summary:        OsmocomBB MS-side GSM Protocol stack (L1, L2, L3)
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
URL:            http://bb.osmocom.org/trac/
Source:         %{name}-%{version}.tar.xz
Patch2:         osmocom-bb-enable-tx.patch
Patch3:         osmocom-bb-pkgconfig-find-lua.patch
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  gcc-c++
BuildRequires:  git-core
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  python
# SLES does not provide gpsd-devel, so build without gps-support on those systems
%if 0%{?is_opensuse}
BuildRequires:  pkgconfig(libgps)
%endif
BuildRequires:  pkgconfig(libosmocodec)
BuildRequires:  pkgconfig(libosmocoding)
BuildRequires:  pkgconfig(libosmocore)
BuildRequires:  pkgconfig(libosmogb)
BuildRequires:  pkgconfig(libosmogsm)
BuildRequires:  pkgconfig(libosmovty)
%if 0%{?suse_version} >= 1500
BuildRequires:  pkgconfig(lua) >= 5.3
%endif
%if 0%{?build_firmware}
BuildRequires:  arm-elf-binutils
BuildRequires:  arm-elf-gcc
# HACK: Disable all post-build-checks
BuildRequires:  -post-build-checks
%endif

%description
OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) including firmware

%package firmware
Summary:        OsmocomBB MS-side GSM Protocol stack - firmware
Group:          Productivity/Telephony/Utilities
Requires:       %{name} = %{version}

%description firmware
OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) including firmware.

This subpackage provides firmware-images for various TI-calypto based
phones.

%prep
%setup -q
%patch2 -p1
%patch3 -p1
# HACK: Don't use /usr/bin/env as an interpreter
sed -i 's|#!/usr/bin/env python2|#!/usr/bin/python2|g' src/target/trx_toolkit/*.py

%build
echo "%{version}" >src/host/osmocon/.tarball-version
echo "%{version}" >src/host/gsmmap/.tarball-version
echo "%{version}" >src/shared/libosmocore/.tarball-version
#
%if 0%{?build_firmware}
export PATH=$PATH:/opt/arm-elf-toolchain/bin
make V=1 -C src/ %{?_smp_mflags}
%else
make V=1 nofirmware -C src/ %{?_smp_mflags}
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
install -Dm 0755 src/host/gsmmap/gsmmap %{buildroot}/%{osmocom_bb_dir}/host/gsmmap/gsmmap
install -Dm 0755 src/host/virt_phy/src/virtphy %{buildroot}/%{osmocom_bb_dir}/host/virt_phy/src/virtphy
install -Dm 0755 src/host/gprsdecode/gprsdecode %{buildroot}/%{osmocom_bb_dir}/host/gprsdecode/gprsdecode
install -Dm 0755 src/host/trxcon/trxcon %{buildroot}/%{osmocom_bb_dir}/host/trxcon/trxcon
install -d %{buildroot}/%{osmocom_bb_dir}/target/trx_toolkit/
install -m 0755 src/target/trx_toolkit/*.py %{buildroot}/%{osmocom_bb_dir}/target/trx_toolkit/

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
# FreeCalpyso FCDEV3B
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/fcdev3b
cp src/target/firmware/board/fcdev3b/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/fcdev3b
# OpenMoko GTA0x
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gta0x/
cp src/target/firmware/board/gta0x/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gta0x/
# Huawei GTM900-B
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gtm900b/
cp src/target/firmware/board/gtm900b/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/gtm900b/
# Pirelli DP-L10
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/pirelli_dpl10/
cp src/target/firmware/board/pirelli_dpl10/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/pirelli_dpl10/
# Sony Erricson J100
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/se_j100/
cp src/target/firmware/board/se_j100/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/se_j100/
%endif

%files
%dir %{osmocom_bb_dir}
%{osmocom_bb_dir}/host
%dir %{osmocom_bb_dir}/target
%{osmocom_bb_dir}/target/trx_toolkit

%if 0%{?build_firmware}
%files firmware
%exclude %{osmocom_bb_dir}/target/trx_toolkit
%{osmocom_bb_dir}/target
%endif

%changelog
