#
# spec file for package osmo-gsm-manuals-devel
#
# Copyright (c) 2019, Martin Hauke <mardnh@gmx.de>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#

Name:           osmo-gsm-manuals-devel
Version:        0.3.0.10
Release:        0
Summary:        Osmocom manuals shared code
License:        GFDL-1.3-only
Group:          Development/Tools/Doc Generators
URL:            https://git.osmocom.org/osmo-gsm-manuals/
Source:         osmo-gsm-manuals-%{version}.tar.xz
Patch0:         use-local-dtd.patch
Patch1:         use-proper-pkgconfig-dir.patch
Patch2:         bypass-xmllint.patch
Patch3:         adjust-check-bin-nwdiag.patch
BuildRequires:  asciidoc
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  dblatex
BuildRequires:  docbook_5
BuildRequires:  graphviz
BuildRequires:  graphviz-gnome
BuildRequires:  libtool
BuildRequires:  libxslt-tools
BuildRequires:  mscgen
BuildRequires:  pkg-config
BuildRequires:  python3-nwdiag
BuildRequires:  texlive-scheme-medium
Requires:       asciidoc
Requires:       dblatex
Requires:       docbook_5
Requires:       graphviz
Requires:       graphviz-gnome
Requires:       libxslt-tools
Requires:       mscgen
Requires:       pkg-config
Requires:       python3-nwdiag
Requires:       texlive-scheme-medium
BuildArch:      noarch

%description
All Osomocom repositories require this package to build their manuals.

%prep
%setup -q -n osmo-gsm-manuals-%{version}
%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
sed -i 's|#!/usr/bin/env python3|#!/usr/bin/python3|g' build/filter-wrapper.py
sed -i 's|#!/usr/bin/env python3|#!/usr/bin/python3|g' build/unix-time-to-fmt.py

%build
echo "%{version}" >.tarball-version
autoreconf -fiv
%configure
make %{?_smp_mflags}

%install
%make_install

%check
make %{?_smp_mflags} check

%files
%doc INSTALL.txt
%{_bindir}/osmo-gsm-manuals-check-depends
%dir %{_datadir}/osmo-gsm-manuals
%{_datadir}/osmo-gsm-manuals/build/
%{_datadir}/osmo-gsm-manuals/common/
%{_datadir}/osmo-gsm-manuals/merge_doc.xsl
%{_datadir}/osmo-gsm-manuals/vty_reference.xsl
%{_datadir}/pkgconfig/osmo-gsm-manuals.pc

%changelog
