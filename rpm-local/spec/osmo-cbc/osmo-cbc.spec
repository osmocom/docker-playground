#
# spec file for package osmo-cbc
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

Name:           osmo-cbc
Version:        0.0.0+git.20191204
Release:        0
Summary:        Osmocom Cell Broadcast Centre
License:        AGPL-3.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            https://osmocom.org/projects/osmo-cbc/wiki
Source:         %{name}-%{version}.tar.xz
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig >= 0.20
BuildRequires:  pkgconfig(libosmo-netif) >= 0.4.0
BuildRequires:  pkgconfig(libosmocore) >= 1.0.0
BuildRequires:  pkgconfig(libosmogsm) >= 1.0.0
BuildRequires:  pkgconfig(libosmovty) >= 1.0.0
BuildRequires:  pkgconfig(libulfius)
BuildRequires:  pkgconfig(systemd)

%description
Osmocom Cell Broadcast Centre.
XXX TODO XXX
XXX TODO XXX
XXX TODO XXX
XXX TODO XXX

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure
make %{?_smp_mflags}

%install
%make_install

%check
make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)

%preun
%service_del_preun %{name}.service

%postun
%service_del_postun %{name}.service

%pre
%service_add_pre %{name}.service

%post
%service_add_post %{name}.service

%files
%{_bindir}/osmo-cbc
%{_unitdir}/osmo-cbc.service

%changelog
