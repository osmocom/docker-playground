# rootforbuild

Name:           opencore-amr
Summary:        Adaptive Multi-Rate (AMR) Speech Codec
Version:        0.1.3
Release:        1.1
License:        Apache License, Version 2.0
Group:          System/Libraries
Url:            http://opencore-amr.sourceforge.net/
Source0:        http://downloads.sourceforge.net/project/opencore-amr/opencore-amr/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires:  gcc-c++
BuildRequires:  pkgconfig

%description
Library of OpenCORE Framework implementation of Adaptive Multi Rate
Narrowband and Wideband speech codec.

%package -n libopencore-amrnb0
Group:          System/Libraries
Summary:        OpenCore AMR - Shared Library 

%description -n libopencore-amrnb0
Library of OpenCORE Framework implementation of Adaptive Multi Rate
Narrowband speech codec.

%package -n libopencore-amrwb0
Group:          System/Libraries
Summary:        OpenCore AMR - Shared Library

%description -n libopencore-amrwb0
Library of OpenCORE Framework implementation of Adaptive Multi Rate
Wideband speech codec.

%package -n libopencore-amr-devel
Summary:        Adaptive Multi-Rate (AMR) Speech Codec Developer Package
Group:          Development/Libraries/C and C++
Requires:       libopencore-amrnb0 = %{version}
Requires:       libopencore-amrwb0 = %{version}

%description -n libopencore-amr-devel
Library of OpenCORE Framework implementation of Adaptive Multi Rate
Narrowband and Wideband speech codec.
Developer Package.

%prep
%setup -q

%build
%configure --disable-static
%__make %{?_smp_mflags}

%install
%{makeinstall}
find %{buildroot}%{_libdir} -name '*.la' -delete -print

%clean
rm -rf %{buildroot}

%post -n libopencore-amrnb0 -p /sbin/ldconfig

%postun -n libopencore-amrnb0 -p /sbin/ldconfig

%post -n libopencore-amrwb0 -p /sbin/ldconfig

%postun -n libopencore-amrwb0 -p /sbin/ldconfig

%files -n libopencore-amrnb0
%defattr(-,root,root)
%{_libdir}/libopencore-amrnb.so.0*

%files -n libopencore-amrwb0
%defattr(-,root,root)
%{_libdir}/libopencore-amrwb.so.0*

%files -n libopencore-amr-devel
%defattr (-, root, root)
%doc opencore/ChangeLog opencore/NOTICE opencore/README
%{_includedir}/opencore-amrnb/
%{_includedir}/opencore-amrwb/
%{_libdir}/libopencore-amr*.so
%{_libdir}/pkgconfig/opencore-amr*.pc

%changelog
* Fri May 25 2012 dimstar@opensuse.org
- Update to version 0.1.3:
  + Adjusted libtool flags for building DLLs for windows
  + Update to the latest upstream opencore source
  + Updated and improved example applications
  + Add options for enabling the arm inline assembly
  + Add options for disabling the encoder or decoder in the amrnb
    library
  + Avoid dependencies on libstdc++ if building the source as C
  + Hide internal symbols in shared libraries
  + Minor tweaks
  + Remove old static makefiles and corresponding build scrip
* Thu Feb  3 2011 dominique-vlc.suse@leuenberger.net
- BuildRequire pkgconfig instead of pkg-config.
* Mon Sep  6 2010 dominique-vlc.suse@leuenberger.net
- Initial package, version 0.1.2
