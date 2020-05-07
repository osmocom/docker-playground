#
# spec file for package simtrace
#
# Copyright (c) 2014, Martin Hauke <mardnh@gmx.de>
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

Name:           simtrace
Version:        0.0.0.git1489787354.6fde8e1
Release:        0
Summary:        Osmocom SIMtrace host utility
License:        GPL-2.0+
Group:          Productivity/Telephony/Utilities
URL:            https://osmocom.org/projects/simtrace/wiki/SIMtrace
Source:         %{name}-%{version}.tar.xz
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libosmocore) >= 0.3.0
BuildRequires:  pkgconfig(libusb-1.0)

%description
Osmocom SIMtrace is a software and hardware system for passively tracing
SIM-ME communication between the SIM card and the mobile phone.

This package contains SIMtrace host utility.

%prep
%setup -q

%build
export CFLAGS='%{optflags} -Wno-return-type'
make -C host %{?_smp_mflags}

%install
cd host
%make_install

%files
%doc README.md
%doc docs
%{_bindir}/simtrace

%changelog
