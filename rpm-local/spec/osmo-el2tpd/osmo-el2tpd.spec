#
# spec file for package osmo-el2tpd
#
# Copyright (c) 2020, Martin Hauke <mardnh@gmx.de>
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

Name:           osmo-el2tpd
Version:        0.0.0+git.20200503
Release:        0
Summary:        Osmocom L2TP daemon compatible with Ericsson L2TP dialect (SIU)
License:        GPL-2.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            http://cgit.osmocom.org/osmo-el2tpd/
Source:         %{name}-%{version}.tar.xz
BuildRequires:  autoconf
BuildRequires:  autoconf-archive
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig(libosmocore) >= 1.0.0
BuildRequires:  pkgconfig(libcrypto)
##BuildRequires:  systemd-rpm-macros

%description
Osmocom L2TP daemon compatible with Ericsson L2TP dialect (SIU).

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure \
  --docdir="%{_docdir}/%{name}" \
  --with-systemdsystemunitdir=%{_unitdir}
make %{?_smp_mflags}

%install
%make_install

%check
### FIXME - no checks atm 
#make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)

### FIXME - no service file atm
#%%preun
#%%service_del_preun %{name}.service
#%
#%%postun
#%%service_del_postun %{name}.service
#%
#%%pre
#%%service_add_pre %{name}.service
#%
#%%post
#%%service_add_post %{name}.service

%files
%license COPYING
%doc README.md
#%dir %{_docdir}/%{name}
#%dir %{_docdir}/%{name}/examples
#%{_docdir}/%{name}/examples/osmo-uecups-daemon.cfg
%{_sbindir}/osmo-el2tpd
#%dir %{_sysconfdir}/osmocom
#%config %{_sysconfdir}/osmocom/osmo-uecups-daemon.cfg
##%%{_unitdir}/osmo-uecups.service

%changelog
