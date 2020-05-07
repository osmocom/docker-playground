#
# spec file for package arm-elf-binutils
#
# Copyright (c) 2015, Martin Hauke <mardnh@gmx.de>
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


%define target arm-elf
%define _prefix /opt/%{target}-toolchain

Name:           %{target}-binutils
Version:        2.21.1
Release:        0
Summary:        Cross Compiling GNU Binutils targeted at %{target}
License:        GFDL-1.3 and GPL-3.0+
Group:          Development/Tools/Building
Url:            http://www.gnu.org/software/binutils/
Source:         http://ftp.gnu.org/gnu/binutils/binutils-%{version}a.tar.bz2
BuildRequires:  bison
BuildRequires:  flex
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
ExclusiveArch:  %ix86 x86_64

%description
This is a Cross Compiling version of GNU binutils, which can be used to
assemble and link binaries for the %{target} platform, instead of for the
native %{_arch} platform.

%prep
%setup -q -n binutils-%{version}

%build
./configure \
	--target=%{target} \
	--prefix=%{_prefix} \
	--infodir=%{_infodir} \
	--mandir=%{_mandir} \
	--enable-interwork \
	--enable-threads=posix \
	--enable-multilib \
	--with-float=soft \
	--disable-werror \
	--disable-nls
make %{?_smp_mflags} all

%install
make DESTDIR=%{buildroot} install %{?_smp_mflags}
rm -f %{buildroot}/%{_mandir}/man1/%{target}-{dlltool,nlmconv,windres,windmc}.1
rm -r %{buildroot}/%{_infodir}
rm -r %{buildroot}/%{_libdir}
%ifarch x86_64
rm -r %{buildroot}/%{_prefix}/lib
%endif

%files
%defattr(-,root,root)
%{_prefix}

%changelog
