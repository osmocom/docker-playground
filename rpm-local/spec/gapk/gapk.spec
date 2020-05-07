#
# spec file for package gapk
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

%define with_amr 1
%define with_gsmhr 1
%define sover 0

Name:           gapk
Version:        0.4.79
Release:        0
Summary:        GSM Audio Pocket Knife
License:        GPL-3.0-only
Group:          Productivity/Multimedia/Sound/Editors and Convertors
URL:            http://www.osmocom.org
Source:         gapk-%{version}.tar.xz
# License: for libgsmhr see 3gpp website
Source1:        0606_421.zip
Patch1:         gapk-disable-codec-dl-during-build.diff
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libgsm-devel
BuildRequires:  libtool
BuildRequires:  pkgconfig
BuildRequires:  python
BuildRequires:  pkgconfig(alsa)
BuildRequires:  pkgconfig(libosmocodec)
BuildRequires:  pkgconfig(libosmocore)
# Benchmarking is currently only supported on intel platforms...
ExclusiveArch:  %{ix86} x86_64
%if 0%{with_amr}
BuildRequires:  libopencore-amr-devel
%endif

%description
gapk is intented to be the GSM Audio Pocket Knife.
It encodes/decodes several GSM-related audio-codes (HR,FR,EFR)

%if 0%{with_gsmhr}
%package -n libgsmhr0
Summary:        Shared Library part of libgsmhr
License:        NonFree
Group:          Development/Libraries/C and C++

%description -n libgsmhr0
libgsmhr contains a standard implementation of the European GSM 06.20
provisional standard for GSM Half Rate speech speech transcoding.

%package -n libgsmhr-devel
Summary:        Development files for the gsmhr library
License:        NonFree
Group:          Development/Libraries/C and C++
Requires:       libgsmhr0 = %{version}

%description -n libgsmhr-devel
libgsmhr contains a standard implementation of the European GSM 06.20
provisional standard for GSM Half Rate speech speech transcoding.

This subpackage contains libraries and header files for developing
applications that want to make use of libgsmhr.
%endif

%package -n libosmogapk%{sover}
Summary:        Shared library part of GSM Audio Pocket Knife (GAPK)
License:        GPL-3.0-only
Group:          Development/Libraries/C and C++

%description -n libosmogapk%{sover}
Shared library part of GSM Audio Pocket Knife (GAPK).

%package -n libosmogapk-devel
Summary:        Development files for the GAPK library
License:        GPL-3.0-only
Group:          Development/Libraries/C and C++
Requires:       libosmogapk%{sover} = %{version}

%description -n libosmogapk-devel
Shared library part of GSM Audio Pocket Knife (GAPK).

This subpackage contains the development files for the Osmocom GAPK
library.

%prep
%setup -q
%if 0%{with_gsmhr}
%patch1 -p1
cp %{SOURCE1} libgsmhr/
%endif

%build
echo "%{version}" >.tarball-version
autoreconf -fi
%configure \
%if 0%{with_gsmhr}
    --enable-gsmhr \
%endif
    --disable-static
make V=1 %{?_smp_mflags}

%install
%make_install
find %{buildroot} -type f -name "*.la" -delete -print

%check
%if 0%{with_gsmhr}
## GSM HR tests (6,9,13,14) are known to be broken - https://osmocom.org/issues/2514
make %{?_smp_mflags} check || :
%else
make %{?_smp_mflags} check || (find . -name testsuite.log -exec cat {} +)
%endif

%if 0%{with_gsmhr}
%post   -n libgsmhr0 -p /sbin/ldconfig
%postun -n libgsmhr0 -p /sbin/ldconfig
%endif

%post   -n libosmogapk%{sover} -p /sbin/ldconfig
%postun -n libosmogapk%{sover} -p /sbin/ldconfig

%files
%doc gpl-3.0.txt
%{_bindir}/osmo-gapk

%if 0%{with_gsmhr}
%files -n libgsmhr0
%{_libdir}/libgsmhr.so.0*

%files -n libgsmhr-devel
%{_libdir}/libgsmhr.so
%endif

%files -n libosmogapk%{sover}
%{_libdir}/libosmogapk.so.%{sover}*

%files -n libosmogapk-devel
%dir %{_includedir}/osmocom/
%{_includedir}/osmocom/%{name}/
%{_libdir}/libosmogapk.so
%{_libdir}/pkgconfig/libosmogapk.pc

%changelog
