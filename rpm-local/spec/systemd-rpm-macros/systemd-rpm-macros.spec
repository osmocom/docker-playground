#
# spec file for package systemd-rpm-macros
#
# Copyright (c) 2016 SUSE LINUX GmbH, Nuernberg, Germany.
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


Name:           systemd-rpm-macros
Version:        3
Release:        0
Summary:        RPM macros for systemd
License:        LGPL-2.1+
Group:          System/Base
Url:            http://en.opensuse.org/openSUSE:Systemd_packaging_guidelines
Source0:        macros.systemd
Requires:       coreutils
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
#!BuildIgnore:  util-linux

%description
Starting with openSUSE 12.1, several RPM macros must be used to package systemd
services files. This package provides these macros.

%prep

%build

%install
mkdir -p %{buildroot}%{_sysconfdir}/rpm
install -m644 %{S:0} %{buildroot}%{_sysconfdir}/rpm
UNITDIR="`cat %{S:0} | sed -n 's|.*_unitdir[[:blank:]]*||p'`"
for i in $UNITDIR `dirname $UNITDIR`; do
   mkdir -p %{buildroot}$i
   echo $i >> unitdir
done

%files -f unitdir
%defattr(-,root,root)
%config %{_sysconfdir}/rpm/macros.systemd

%changelog
