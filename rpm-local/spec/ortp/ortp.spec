#
# spec file for package ortp
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
# Copyright (c) 2014 Mariusz Fik <fisiu@opensuse.org>.
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


%define lname libortp9
Name:           ortp
Version:        0.24.2
Release:        0
Summary:        Real-time Transport Protocol Stack
License:        LGPL-2.1+
Group:          System/Libraries
Url:            http://linphone.org/eng/documentation/dev/ortp.html
Source:         http://download.savannah.gnu.org/releases/linphone/ortp/sources/%{name}-%{version}.tar.gz
Source99:       baselibs.conf
BuildRequires:  gcc
BuildRequires:  glibc-devel
BuildRequires:  make
BuildRequires:  pkg-config
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
oRTP is a LGPL licensed C library implementing the RTP protocol
(rfc1889).

%package -n %{lname}
Summary:        Real-time Transport Protocol Stack
Group:          System/Libraries

%description -n %{lname}
oRTP is a LGPL licensed C library implementing the RTP protocol
(rfc1889).

%package devel
Summary:        Headers, libraries and docs for the oRTP library
Group:          Development/Libraries/C and C++
Requires:       %{lname} = %{version}
Provides:       libortp-devel = %{version}
Obsoletes:      libortp-devel < %{version}

%description devel
oRTP is a LGPL licensed C library implementing the RTP protocol
(rfc1889).

This package contains header files and development libraries needed to
develop programs using the oRTP library.

%prep
%setup -q

%build
%configure \
%if %{?_lib} == lib64
  --enable-mode64bit \
%endif
  --disable-static
make %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%post -n %{lname} -p /sbin/ldconfig

%postun -n %{lname} -p /sbin/ldconfig

%files -n %{lname}
%defattr(-,root,root)
%{_libdir}/*.so.9*

%files devel
%defattr(-,root,root)
%doc AUTHORS COPYING ChangeLog NEWS README TODO
%{_includedir}/ortp/
%{_libdir}/*.so
%{_libdir}/pkgconfig/*.pc

%changelog
