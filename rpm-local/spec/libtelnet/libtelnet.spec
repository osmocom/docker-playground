#
# spec file for package libtelnet
#
# Copyright (c) 2018, Martin Hauke <mardnh@gmx.de>
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

%define sover 1
Name:           libtelnet
Version:        0.0.0+git.20180308
Release:        0
Summary:        Library for parsing the TELNET protocol
License:        MIT
Group:          Development/Libraries/C and C++
URL:            http://git.osmocom.org/libtelnet/
Source:         libtelnet-%{version}.tar.xz
Source99:       libtelnet-rpmlintrc
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libcrypto)
BuildRequires:  pkgconfig(openssl)

%description
libtelnet is a small library for parsing the TELNET protocol, responding
to TELNET commands via an event interface, and generating valid TELNET
commands.

%package -n ipaccess-telnet
Summary:        Telnet client for ip-access nanoBTS devices
Group:          Productivity/Networking/Other

%description -n ipaccess-telnet
Modified telnet client that is required by nanoBTS device. There is some
kind of shared-secret challenge-response MD5 authentication required -
otherwise the BTS will simplydisconnect you after a few seconds.

%package utils
Summary:        Small library for parsing the TELNET protocol - utilities
Group:          Productivity/Networking/Other

%description utils
libtelnet is a small library for parsing the TELNET protocol, responding
to TELNET commands via an event interface, and generating valid TELNET
commands.

This subpackage contains utilities (telnet client, -server) that are
based on libtelnet.

%package -n libtelnet%{sover}
Summary:        Library for parsing the TELNET protocol
Group:          System/Libraries

%description -n libtelnet%{sover}
libtelnet is a small library for parsing the TELNET protocol, responding
to TELNET commands via an event interface, and generating valid TELNET
commands.

%package -n libtelnet-devel
Summary:        Development files for the libtelnet library
Group:          Development/Libraries/C and C++
Requires:       libtelnet%{sover} = %{version}
Requires:       zlib-devel

%description -n libtelnet-devel
libtelnet is a small library for parsing the TELNET protocol, responding
to TELNET commands via an event interface, and generating valid TELNET
commands.

This subpackage contains libraries and header files for developing
applications that want to make use of libtelnet.

%prep
%setup -q

%build
autoreconf -fi
%configure --disable-static
make V=1 %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%post -n libtelnet%{sover} -p /sbin/ldconfig
%postun -n libtelnet%{sover} -p /sbin/ldconfig

%files -n ipaccess-telnet
%{_bindir}/ipaccess-telnet

%files -n libtelnet-utils
%license COPYING
%doc README
%{_bindir}/telnet-chatd
%{_bindir}/telnet-client
%{_bindir}/telnet-proxy
%{_mandir}/man1/telnet-*.1%{?ext_man}

%files -n libtelnet%{sover}
%{_libdir}/libtelnet.so.%{sover}*

%files -n libtelnet-devel
%{_includedir}/libtelnet.h
%{_libdir}/libtelnet.so
%{_libdir}/pkgconfig/libtelnet.pc
%{_mandir}/man3/libtelnet.3%{?ext_man}
%{_mandir}/man3/telnet_*.3%{?ext_man}

%changelog

