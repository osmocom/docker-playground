#
# spec file for package diag-parser
#
# Copyright (c) 2016, Martin Hauke <mardnh@gmx.de>
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


Name:           diag-parser
Version:        0.0.0.git1511779051.b3707d5
Release:        0
Summary:        DIAG parser and to GSMTAP converter
License:        GPL-3.0+
Group:          Productivity/Telephony/Utilities
Url:            https://github.com/moiji-mobile/diag-parser
Source:         %{name}-%{version}.tar.xz
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libosmocore)
BuildRequires:  pkgconfig(libosmogsm)
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Parse the Qualcomm DIAG format and convert 2G, 3G and 4G radio messages
to Osmocom GSMTAP for analysis in wireshark and other utilities.

%prep
%setup -q

%build
make %{?_smp_mflags}

%install
install -Dpm0755 diag_parser %{buildroot}/%{_bindir}/diag-parser
install -Dpm0644 diag-parser.1 %{buildroot}/%{_mandir}/man1/diag-parser.1

%files
%defattr(-,root,root)
%doc COPYING README.md
%{_bindir}/diag-parser
%{_mandir}/man1/diag-parser.1%{ext_man}

%changelog
