#
# spec file for package osmocom-bb-snake
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
%define osmocom_bb_dir /opt/osmocom-bb-snake

Name:           osmocom-bb-snake
Version:        0.0.0.git1371651005.c56ff0c9
Release:        0
Summary:        OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) (snake)
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
Url:            http://bb.osmocom.org/trac/
Source:         osmocom-bb-%{version}.tar.xz
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig(libosmocodec)
BuildRequires:  pkgconfig(libosmocore)
BuildRequires:  pkgconfig(libosmogsm)
BuildRequires:  pkgconfig(libosmovty)
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
Cool Firmware-Hack from <Marcel `sdrfnord` McKinnon>
for playing the game snake on OsmocomBB-compatible phones.
Requires Sitronix ST7558 LCD Controller!
(only Motorola C115/C117/C123/C121/C118)

%package firmware
Summary:        OsmocomBB MS-side GSM Protocol stack - firmware (snake)
Group:          Productivity/Telephony/Utilities
Requires:       %{name} = %{version}

%description firmware
OsmocomBB MS-side GSM Protocol stack (L1, L2, L3) including firmware.
Cool Firmware-Hack from <Marcel `sdrfnord` McKinnon>
for playing the game snake on OsmocomBB-compatible phones.
Requires Sitronix ST7558 LCD Controller!
(only Motorola C115/C117/C123/C121/C118)

This subpackage provides firmware-images for various TI-calypto based
phones.

%prep
%setup -q -n osmocom-bb-%{version}

%build
%if 0%{?build_firmware}
export PATH=$PATH:/opt/arm-elf-toolchain/bin
make V=1 -C src/ %{?_smp_mflags} APPLICATIONS="chainload snake_game" BOARDS="compal_e88"
%else
make V=1 nofirmware -C src/ %{?_smp_mflags} APPLICATIONS="chainload snake_game" BOARDS="compal_e88"
%endif


%install
mkdir -p %{buildroot}/%{osmocom_bb_dir}
install -Dm 0755 src/host/osmocon/osmocon %{buildroot}/%{osmocom_bb_dir}/host/osmocon/osmocon
install -Dm 0755 src/host/osmocon/osmoload %{buildroot}/%{osmocom_bb_dir}/host/osmocon/osmoload

%if 0%{?build_firmware}
### Firmware
# Compal E88
mkdir -p %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e88/
cp src/target/firmware/board/compal_e88/*.bin %{buildroot}/%{osmocom_bb_dir}/target/firmware/board/compal_e88/
%endif

%files
%{osmocom_bb_dir}/host

%if 0%{?build_firmware}
%files firmware
%{osmocom_bb_dir}/target
%endif

%changelog
