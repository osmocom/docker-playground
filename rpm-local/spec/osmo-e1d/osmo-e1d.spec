#
# spec file for package osmo-e1d
#
# Copyright (c) 2019, Martin Hauke <mardnh@gmx.de>
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

%define sover 0
Name:           osmo-e1d
Version:        0.0.0+git.20190710
Release:        0
Summary:        Osmocom E1 Daemon
License:        GPL-2.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            https://osmocom.org/projects/e1-t1-adapter/wiki/Osmo-e1d
Source:         %{name}-%{version}.tar.xz
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libosmocore) >= 1.0.1.120
BuildRequires:  pkgconfig(libusb-1.0) >= 1.0.21
BuildRequires:  pkgconfig(talloc) >= 2.0.1

%description
Osmocom E1 Daemon.

%package -n libosmo-e1d%{sover}
Summary:        Osmocom E1 Daemon Protocol Library
License:        LGPL-3.0-or-later
Group:          System/Libraries

%description -n libosmo-e1d%{sover}
Osmocom E1 Daemon Protocol Library.

%package -n libosmo-e1d-devel
Summary:        Development files for the Osmocom E1 Daemon Protocol Library
License:        LGPL-3.0-or-later
Group:          Development/Libraries/C and C++
Requires:       libosmo-e1d%{sover} = %{version}

%description -n libosmo-e1d-devel
Osmocom E1 Daemon Protocol Library.

This subpackage contains libraries and header files for developing
applications that want to make use of libosmo-e1d.

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure -enable-shared --disable-static
make %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%check
make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)

%post   -n libosmo-e1d%{sover} -p /sbin/ldconfig
%postun -n libosmo-e1d%{sover} -p /sbin/ldconfig

%files
%license COPYING COPYING.gpl2 COPYING.lgpl3
%{_bindir}/osmo-e1d

%files -n libosmo-e1d%{sover}
%{_libdir}/libosmo-e1d.so.%{sover}*

%files -n libosmo-e1d-devel
%dir %{_includedir}/osmocom/
%{_includedir}/osmocom/e1d/
%{_libdir}/libosmo-e1d.so
%{_libdir}/pkgconfig/libosmo-e1d.pc

%changelog
