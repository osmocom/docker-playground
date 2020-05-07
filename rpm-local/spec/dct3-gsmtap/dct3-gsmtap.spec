#
# spec file for package dct3-gsmtap
#
# Copyright (c) 2017, Martin Hauke <mardnh@gmx.de>
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


Name:           dct3-gsmtap
Version:        0.0.0.git1356478582.143a5bb
Release:        0
Summary:        Obtain GSMTAP messages from Nokia DCT3 phones
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
Url:            http://bb.osmocom.org/trac/wiki/dct3-gsmtap
Source:         %{name}-%{version}.tar.xz
Patch0:         0001-build-obey-CFLAGS.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
A tool to obtain GSMTAP messages for SIM and GSM from Nokia DCT3 phones

%prep
%setup -q
%patch0 -p1

%build
export CFLAGS="%{optflags} -Wno-unused-const-variable -Wno-unused-result"
make -C src/ %{?_smp_mflags}

%install
mkdir -p %{buildroot}%{_bindir}/
install -Dpm 0755 src/dct3-gsmtap %{buildroot}%{_bindir}/dct3-gsmtap

%files
%defattr(-,root,root)
%doc COPYING README
%{_bindir}/dct3-gsmtap

%changelog
