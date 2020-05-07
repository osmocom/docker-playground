#
# spec file for package osmo-iuh
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


Name:           osmo-iuh
Version:        0.6.0.13
Release:        0
Summary:        Osmocom code for the Iuh interface (HNBAP, RUA, RANAP)
License:        AGPL-3.0-or-later AND GPL-2.0-or-later
Group:          Hardware/Mobile
URL:            https://osmocom.org/projects/osmohnbgw/wiki
Source:         %{name}-%{version}.tar.xz
BuildRequires:  automake >= 1.9
BuildRequires:  libtool >= 2
BuildRequires:  lksctp-tools-devel
BuildRequires:  pkgconfig >= 0.20
# python3 for asn1tostruct.py
BuildRequires:  python3
BuildRequires:  pkgconfig(libasn1c) >= 0.9.30
BuildRequires:  pkgconfig(libosmo-netif) >= 0.3.0
BuildRequires:  pkgconfig(libosmo-sigtran) >= 0.10.0
BuildRequires:  pkgconfig(libosmocore) >= 0.12.0
BuildRequires:  pkgconfig(libosmoctrl) >= 0.12.0
BuildRequires:  pkgconfig(libosmogb)
BuildRequires:  pkgconfig(libosmogsm) >= 0.12.0
BuildRequires:  pkgconfig(libosmovty) >= 0.12.0

%description
Osmocom code for the Iuh interface (HNBAP, RUA, RANAP)

%package -n libosmo-ranap3
Summary:        Shared Library part of libosmo-ranap
Group:          System/Libraries

%description -n libosmo-ranap3
Osmocom code for the Iuh interface (HNBAP, RUA, RANAP)

%package -n libosmo-ranap-devel
Summary:        Development files for Osmocom RANAP library
Group:          Development/Libraries/C and C++
Requires:       libosmo-ranap3 = %{version}

%description -n libosmo-ranap-devel
Osmocom code for the Iuh interface (HNBAP, RUA, RANAP)

This subpackage contains libraries and header files for developing
applications that want to make use of libosmoranap.


%package -n libosmo-sabp0
Summary:        Shared Library part of libosmo-sabp
Group:          System/Libraries

%description -n libosmo-sabp0
Osmocom code for the SABP (service area broadcast protocol) interface

%package -n libosmo-sabp-devel
Summary:        Development files for Osmocom SABP library
Group:          Development/Libraries/C and C++
Requires:       libosmo-sabp0 = %{version}

%description -n libosmo-sabp-devel
Osmocom code for the SABP (service area broadcast protocol) interface

This subpackage contains libraries and header files for developing
applications that want to make use of libosmo-sabp.


%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fi
%configure \
  --disable-static \
  --docdir="%{_docdir}/%{name}" \
  --with-systemdsystemunitdir=%{_unitdir}
make %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%check
make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)

%post   -n libosmo-ranap3 -p /sbin/ldconfig
%postun -n libosmo-ranap3 -p /sbin/ldconfig
%post   -n libosmo-sabp0 -p /sbin/ldconfig
%postun -n libosmo-sabp0 -p /sbin/ldconfig
%pre     %service_add_pre    osmo-hnbgw.service
%post    %service_add_post   osmo-hnbgw.service
%preun   %service_del_preun  osmo-hnbgw.service
%postun  %service_del_postun osmo-hnbgw.service

%files
%license COPYING
%doc README.md
%dir %{_docdir}/%{name}/examples
%{_docdir}/%{name}/examples/osmo-hnbgw.cfg
%{_bindir}/osmo-hnbgw
%dir %{_sysconfdir}/osmocom
%config %{_sysconfdir}/osmocom/osmo-hnbgw.cfg
%{_unitdir}/osmo-hnbgw.service

%files -n libosmo-ranap3
%{_libdir}/libosmo-ranap.so.3*

%files -n libosmo-ranap-devel
%{_includedir}/*
%{_libdir}/libosmo-ranap.so
%{_libdir}/pkgconfig/libosmo-ranap.pc

%files -n libosmo-sabp0
%{_libdir}/libosmo-sabp.so.0*

%files -n libosmo-sabp-devel
%{_libdir}/libosmo-sabp.so
%{_libdir}/pkgconfig/libosmo-sabp.pc

%changelog
