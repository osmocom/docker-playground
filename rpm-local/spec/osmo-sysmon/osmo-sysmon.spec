#
# spec file for package osmo-sysmon
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

Name:           osmo-sysmon
Version:        0.2.0.4
Release:        0
Summary:        Osmocom System Monitor
License:        GPL-2.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            http://cgit.osmocom.org/osmo-sysmon/
Source:         %{name}-%{version}.tar.xz
BuildRequires:  autoconf-archive
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libmnl)
BuildRequires:  pkgconfig(libosmocore) >= 0.11.0
BuildRequires:  pkgconfig(libosmoctrl) >= 0.11.0
BuildRequires:  pkgconfig(libosmogsm) >= 0.11.0
BuildRequires:  pkgconfig(libosmovty) >= 0.11.0
BuildRequires:  pkgconfig(libosmo-netif) >= 0.4.0
BuildRequires:  pkgconfig(liboping) >= 1.9.0.

%description
Osmocom System Monitor.

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure \
  --docdir=%{_docdir}/%{name} \
  --with-systemdsystemunitdir=%{_unitdir}
make %{?_smp_mflags}

%install
%make_install

%files
%license COPYING
%dir %{_docdir}/%{name}
%dir %{_docdir}/%{name}/examples
%dir %{_docdir}/%{name}/examples/%{name}
%{_docdir}/%{name}/examples/%{name}/osmo-sysmon.cfg
%{_bindir}/osmo-ctrl-client
%{_bindir}/osmo-sysmon
%dir %{_sysconfdir}/osmocom
%config %{_sysconfdir}/osmocom/osmo-sysmon.cfg

%changelog
