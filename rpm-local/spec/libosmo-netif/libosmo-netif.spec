#
# spec file for package libosmo-netif
#
# Copyright (c) 2018 SUSE LINUX GmbH, Nuernberg, Germany.
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


%define version_unconverted 0.7.0.11
Name:           libosmo-netif
Version:        0.7.0.11
Release:        0
Summary:        Osmocom library for muxed audio
License:        GPL-2.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            https://osmocom.org/projects/libosmo-netif
Source:         %{name}-%{version}.tar.xz
BuildRequires:  automake
BuildRequires:  libtool >= 2
BuildRequires:  lksctp-tools-devel
BuildRequires:  pkgconfig >= 0.20
BuildRequires:  pkgconfig(libosmoabis) >= 0.6.0
BuildRequires:  pkgconfig(libosmocore) >= 1.0.0
BuildRequires:  pkgconfig(libosmogsm) >= 1.0.0

%description
Network interface demuxer library for OsmoCom projects.

%package -n libosmonetif8
Summary:        Osmocom library for muxed audio
License:        AGPL-3.0-or-later
Group:          System/Libraries

%description -n libosmonetif8
Network interface demuxer library for OsmoCom projects.

%package -n libosmonetif-devel
Summary:        Development files for the Osmocom muxed audio library
License:        AGPL-3.0-or-later
Group:          Development/Libraries/C and C++
Requires:       libosmonetif8 = %{version}

%description -n libosmonetif-devel
Network interface demuxer library for OsmoCom projects.

This subpackage contains libraries and header files for developing
applications that want to make use of libosmo-netif.

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure --enable-shared --disable-static --includedir="%{_includedir}/%{name}"
make %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%check
make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)

%post   -n libosmonetif8 -p /sbin/ldconfig
%postun -n libosmonetif8 -p /sbin/ldconfig

%files -n libosmonetif8
%{_libdir}/libosmonetif.so.8*

%files -n libosmonetif-devel
%license COPYING
%dir %{_includedir}/%{name}
%dir %{_includedir}/%{name}/osmocom
%{_includedir}/%{name}/osmocom/netif/
%{_libdir}/libosmonetif.so
%{_libdir}/pkgconfig/libosmo-netif.pc

%changelog
