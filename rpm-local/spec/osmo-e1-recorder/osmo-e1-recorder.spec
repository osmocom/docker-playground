#
# spec file for package osmo-e1-recorder
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

Name:           osmo-e1-recorder
Version:        0.0.0+git.20191204
Release:        0
Summary:        Osmocom E1/T1 span recorder
License:        GPL-2.0-or-later
Group:          Productivity/Telephony/Utilities
URL:            https://git.osmocom.org/osmo-e1-recorder
Source:         %{name}-%{version}.tar.xz
BuildRequires:  autoconf
BuildRequires:  autoconf-archive
BuildRequires:  automake
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libosmoabis)
BuildRequires:  pkgconfig(libosmocore)
BuildRequires:  pkgconfig(libosmogsm)
BuildRequires:  pkgconfig(libosmovty)
BuildRequires:  pkgconfig(talloc)

%description
The idea of this program is to be able to passively record E1/T1 based
communications for purposes of data analysis.

Recording of a single E1 link always requires two E1 interface cards,
one for each direction.

%prep
%setup -q

%build
echo "%{version}" >.tarball-version
autoreconf -fi
%configure \
  --docdir=%{_docdir}/%{name}
make %{?_smp_mflags}

%install
%make_install

%check
make %{?_smp_mflags} check

%files
%doc README
%{_docdir}/osmo-e1-recorder/examples/osmo-e1-recorder.cfg
%dir %{_docdir}/%{name}/examples
%{_docdir}/%{name}/examples/osmo-e1-recorder.cfg
%dir %{_sysconfdir}/osmocom
%config %{_sysconfdir}/osmocom/osmo-e1-recorder.cfg
%{_bindir}//hdlc-test
%{_bindir}/osmo-e1-recorder
%{_bindir}/osmo-e1cap-dump

%changelog
