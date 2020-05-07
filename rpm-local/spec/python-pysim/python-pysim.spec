#
# spec file for package python-pysim
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

Name:           python-pysim
Version:        0.0.0.git1587983340.ee15c77
Release:        0
Summary:        A python tool to program magic SIMs
License:        GPL-2.0-only
Group:          Productivity/Telephony/Utilities
URL:            http://cgit.osmocom.org/pysim/
Source:         pysim-%{version}.tar.xz
BuildRequires:  python2-devel
Requires:       python-pycrypto
Requires:       python-pyserial
Recommends:     python-pyscard
BuildArch:      noarch

%description
Python tool to program a variety of SIM/USIM cards with Ki/ICCID/IMSI/...

%prep
%setup -q -n pysim-%{version}
# HACK: force python2
find ./pySim -type f | xargs sed -i -e '/^#!\//, 1d'
sed -i 's|%{_bindir}/env python|%{_bindir}/python2|g' pySim/*.py
sed -i 's|%{_bindir}/env python2|%{_bindir}/python2|g' pySim-*.py
# Drop shebang from non-execeutables
find ./pySim -type f | xargs sed -i -e '/^#!\//, 1d'

%build

%install
install -Dm 0755 pySim-prog.py %{buildroot}/%{_bindir}/pySim-prog
install -Dm 0755 pySim-read.py %{buildroot}/%{_bindir}/pySim-read
install -d %{buildroot}/%{python_sitelib}/
mv pySim/ %{buildroot}/%{python_sitelib}/

%files
%license COPYING
%doc README.md
%{python_sitelib}/pySim/
%{_bindir}/pySim-prog
%{_bindir}/pySim-read

%changelog
