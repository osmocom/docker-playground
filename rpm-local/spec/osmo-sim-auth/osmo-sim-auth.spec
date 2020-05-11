#
# spec file for package osmo-sim-auth
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

Name:           osmo-sim-auth
Version:        0.0.0.git1519829479.3aa3422
Release:        0
Summary:        A command line tool for (U)SIM authentication
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
URL:            http://openbsc.osmocom.org/trac/wiki/osmo-sim-auth
Source:         %{name}-%{version}.tar.xz
Requires:       python-libmich
Requires:       python-scard
BuildArch:      noarch

%description
osmo-sim-auth is a small script that can be used with a PC-based smartcard
reader to obtain GSM/UMTS authentication parameters from a SIM/USIM card.

%prep
%setup -q

# fix python shebangs
find . -type f -name "*.py" -exec sed -i '/^#!/ s|.*|#!%{__python3}|' {} \;

%build

%install
install -Dm 0755 osmo-sim-auth.py %{buildroot}%{_bindir}/osmo-sim-auth

%files
%doc README.md
%{_bindir}/osmo-sim-auth

%changelog
