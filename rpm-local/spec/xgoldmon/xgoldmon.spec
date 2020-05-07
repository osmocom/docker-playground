#
# spec file for package xgoldmon
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


Name:           xgoldmon
Version:        0.0.0.git1388364764.f2d5372
Release:        0
Summary:        XGold baseband based phones log messages to GSMTAP
License:        GPL-2.0
Group:          Productivity/Telephony/Utilities
Url:            http://bb.osmocom.org/trac/wiki/dct3-gsmtap
Source:         %{name}-%{version}.tar.xz
BuildRequires:  pkg-config
BuildRequires:  pkgconfig(libosmocore)
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
xgoldmon is a small tool to convert the messages output by the USB
logging mode of phones with Intel/Infineon XGold baseband processor
back to the GSM/UMTS radio messages sent over the air so you can watch
them in e.g. Wireshark in realtime.
This includes signalling for calls, SMS, USSD, paging for your and
other phones and so on.

%prep
%setup -q

%build
make %{?_smp_mflags}

%install
mkdir -p %{buildroot}%{_bindir}/
install -Dpm 0755 xgoldmon %{buildroot}%{_bindir}/xgoldmon

%files
%defattr(-,root,root)
%doc COPYING README
%{_bindir}/xgoldmon

%changelog
