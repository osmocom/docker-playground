#%%global git_commit c52f3f41806622c95573de21be042f966f675543
#%%global git_date 201904023

#%%global git_short_commit %%(echo %{git_commit} | cut -c -8)
#%%global git_suffix %%{git_date}git%{git_short_commit}

# By default include binary_firmware, otherwise try to rebuild
# the firmware from sources. If you want to rebuild all firmware
# images you need to install appropriate tools (e.g. Xilinx ISE).
%bcond_without binary_firmware

# By default do not build with wireshark support, it's currently
# broken (upstream ticket #268)
%bcond_with wireshark

# NEON support is by default disabled on ARMs
# building with --with=neon will enable auto detection
%bcond_with neon

%global wireshark_dissectors chdr zpu octoclock
%global wireshark_ver %((%{__awk} '/^#define VERSION[ \t]+/ { print $NF }' /usr/include/wireshark/config.h 2>/dev/null||echo none)|/usr/bin/tr -d '"')

%ifarch %{arm} aarch64
%if ! %{with neon}
%global have_neon -DHAVE_ARM_NEON_H=0
%endif
%endif

%global ver 3.15.0.0
%global verd 3.14.1.1

Name:           uhd
URL:            http://github.com/EttusResearch/uhd
Version:        %{ver}
Release:        0.3.rc2%{?dist}
License:        GPLv3+
BuildRequires:  gcc-c++
BuildRequires:  cmake
BuildRequires:  boost-devel, libusb1-devel, python3-cheetah, ncurses-devel
BuildRequires:  python3-docutils, doxygen, pkgconfig, libpcap-devel
BuildRequires:  python3-numpy, vim-common
%if %{with wireshark}
BuildRequires:  wireshark-devel
%endif
BuildRequires:  python3-mako, python3-requests, python3-devel, tar
%if ! %{with binary_firmware}
BuildRequires:  sdcc sed
%endif
Requires(pre):  shadow-utils, glibc-common
Requires:       python3-tkinter
Summary:        Universal Hardware Driver for Ettus Research products
#Source0:       %%{url}/archive/v%%{version}/uhd-%%{version}.tar.gz
Source0:        %{url}/archive/v%{ver}-rc2/uhd-%{ver}-rc2.tar.gz
Source1:        %{name}-limits.conf
Source2:        %{url}/releases/download/v%{verd}/uhd-images_%{verd}.tar.xz

%description
The UHD is the universal hardware driver for Ettus Research products.
The goal of the UHD is to provide a host driver and API for current and
future Ettus Research products. It can be used standalone without GNU Radio.

%package firmware
Summary:        Firmware files for UHD
Requires:       %{name} = %{version}-%{release}
BuildArch:      noarch

%description firmware
Firmware files for the Universal Hardware driver (UHD).

%package devel
Summary:        Development files for UHD
Requires:       %{name} = %{version}-%{release}

%description devel
Development files for the Universal Hardware Driver (UHD).

%package doc
Summary:        Documentation files for UHD
BuildArch:      noarch

%description doc
Documentation for the Universal Hardware Driver (UHD).

%package tools
Summary:        Tools for working with / debugging USRP device
Requires:       %{name} = %{version}-%{release}

%description tools
Tools that are useful for working with and/or debugging USRP device.

%if %{with wireshark}
%package wireshark
Summary:        Wireshark dissector plugins
Requires:       %{name} = %{version}-%{release}
Requires:       wireshark = %{wireshark_ver}

%description wireshark
Wireshark dissector plugins.
%endif

%prep
%setup -q -n %{name}-%{ver}-rc2

# firmware
%if %{with binary_firmware}
# extract binary firmware
mkdir -p images/images
tar -xJf %{SOURCE2} -C images/images --strip-components=1
rm -f images/images/{LICENSE.txt,*.tag}
# remove Windows drivers
rm -rf images/winusb_driver
%endif

# fix python shebangs
find . -type f -name "*.py" -exec sed -i '/^#!/ s|.*|#!%{__python3}|' {} \;

%build
# firmware
%if ! %{with binary_firmware}
# rebuilt from sources
export PATH=$PATH:%{_libexecdir}/sdcc
pushd images
sed -i '/-name "\*\.twr" | xargs grep constraint | grep met/ s/^/#/' Makefile
make %{?_smp_mflags} images
popd
%endif

mkdir -p host/build
pushd host/build
%cmake %{?have_neon} -DPYTHON_EXECUTABLE="%{__python3}" \
  -DUHD_VERSION="%{version}" \
  -DENABLE_TESTS=off ../
make %{?_smp_mflags}
#make -j1
popd

# tools
pushd tools/uhd_dump
make %{?_smp_mflags} CFLAGS="%{optflags}" LDFLAGS="%{?__global_ldflags}"
popd

%if %{with wireshark}
# wireshark dissectors
pushd tools/dissectors
for d in %{wireshark_dissectors}
do
  mkdir "build_$d"
  pushd "build_$d"
  %cmake -DETTUS_DISSECTOR_NAME="$d" ../
  make %{?_smp_mflags}
  popd
done
popd
%endif

#%%check
#cd host/build
#make test

%install
# fix python shebangs (run again for generated scripts)
find . -type f -name "*.py" -exec sed -i '/^#!/ s|.*|#!%{__python3}|' {} \;

pushd host/build
make install DESTDIR=%{buildroot}

# Fix udev rules and use dynamic ACL management for device
sed -i 's/BUS==/SUBSYSTEM==/;s/SYSFS{/ATTRS{/;s/MODE:="0666"/GROUP:="usrp" MODE:="0660", ENV{ID_SOFTWARE_RADIO}="1"/' %{buildroot}%{_libdir}/uhd/utils/uhd-usrp.rules
mkdir -p %{buildroot}%{_prefix}/lib/udev/rules.d
mv %{buildroot}%{_libdir}/uhd/utils/uhd-usrp.rules %{buildroot}%{_prefix}/lib/udev/rules.d/10-usrp-uhd.rules

# Remove tests, examples binaries
rm -rf %{buildroot}%{_libdir}/uhd/{tests,examples}

# Move the utils stuff to libexec dir
mkdir -p %{buildroot}%{_libexecdir}/uhd
mv %{buildroot}%{_libdir}/uhd/utils/* %{buildroot}%{_libexecdir}/uhd

popd
# Package base docs to base package
mkdir _tmpdoc
mv %{buildroot}%{_docdir}/%{name}/{LICENSE,README.md} _tmpdoc

install -m 644 -D %{SOURCE1} %{buildroot}%{_sysconfdir}/security/limits.d/99-usrp.conf

# firmware
mkdir -p %{buildroot}%{_datadir}/uhd/images
cp -r images/images/* %{buildroot}%{_datadir}/uhd/images

# remove win stuff
rm -rf %{buildroot}%{_datadir}/uhd/images/winusb_driver

# convert hardlinks to symlinks (to not package the file twice)
pushd %{buildroot}%{_bindir}
for f in uhd_images_downloader usrp2_card_burner
do
  unlink $f
  ln -s ../..%{_libexecdir}/uhd/${f}.py $f
done
popd

# tools
install -Dpm 0755 tools/usrp_x3xx_fpga_jtag_programmer.sh %{buildroot}%{_bindir}/usrp_x3xx_fpga_jtag_programmer.sh
install -Dpm 0755 tools/uhd_dump/chdr_log %{buildroot}%{_bindir}/chdr_log

%if %{with wireshark}
# wireshark dissectors
pushd tools/dissectors
for d in %{wireshark_dissectors}
do
  pushd "build_$d"
  %make_install
  popd
done
popd
mv %{buildroot}${HOME}/.wireshark %{buildroot}%{_libdir}/wireshark
%endif

# add directory for modules
mkdir -p %{buildroot}%{_libdir}/uhd/modules

%ldconfig_scriptlets

%pre
getent group usrp >/dev/null || \
  %{_sbindir}/groupadd -r usrp >/dev/null 2>&1
exit 0

%files
%exclude %{_docdir}/%{name}/doxygen
%exclude %{_datadir}/uhd/images
%doc _tmpdoc/*
%dir %{_libdir}/uhd
%{_bindir}/uhd_*
%{_bindir}/usrp2_*
%{_prefix}/lib/udev/rules.d/10-usrp-uhd.rules
%config(noreplace) %{_sysconfdir}/security/limits.d/*.conf
%{_libdir}/lib*.so.*
%{_libdir}/uhd/modules
%{_libexecdir}/uhd
%{_mandir}/man1/*.1*
%{_datadir}/uhd
%{python3_sitearch}/uhd

%files firmware
%dir %{_datadir}/uhd/images
%{_datadir}/uhd/images/*

%files devel
%{_includedir}/*
%{_libdir}/lib*.so
%{_libdir}/cmake/uhd/*.cmake
%{_libdir}/pkgconfig/*.pc

%files doc
%doc %{_docdir}/%{name}/doxygen

%files tools
%doc tools/README.md
%{_bindir}/usrp_x3xx_fpga_jtag_programmer.sh
%{_bindir}/chdr_log

%if %{with wireshark}
%files wireshark
%{_libdir}/wireshark/plugins/*
%endif

%changelog
* Thu Apr 16 2020 Jaroslav Škarvada <jskarvad@redhat.com> - 3.15.0.0-0.3.rc2
- Provided uhd modules directory

* Fri Jan 31 2020 Fedora Release Engineering <releng@fedoraproject.org> - 3.15.0.0-0.2.rc2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Fri Nov  8 2019 Jaroslav Škarvada <jskarvad@redhat.com> - 3.15.0.0-0.1.rc2
- New version
- Switched to Python 3
  Resolves: rhbz#1738157

* Fri Aug  2 2019 Jaroslav Škarvada <jskarvad@redhat.com> - 3.14.1.0-1
- New version
- Disabled tests
  Resolves: rhbz#1736932

* Sat Jul 27 2019 Fedora Release Engineering <releng@fedoraproject.org> - 3.14.0.0-3.201904023gitc52f3f41
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Tue Apr 23 2019 Jaroslav Škarvada <jskarvad@redhat.com> - 3.14.0.0-2.201904023gitc52f3f41
- New git snapshot
- Added python2-numpy build requirement
- Re-enabled tests for upstream to easily reproduce the problem

* Mon Apr 15 2019 Jaroslav Škarvada <jskarvad@redhat.com> - 3.14.0.0-1.20190401gitac96d055
- New version, switched to git snapshot
- Conditionalized wireshark support
- Disabled wireshark support, it's currently broken (upstream ticket #268)
- Disabled tests, it's currently broken (upstream ticket #267)
- Dropped boost169 patch (not needed)

* Mon Apr  1 2019 Jaroslav Škarvada <jskarvad@redhat.com> - 3.12.0.0-5
- Re-introduced usrp group
  Resolves: rhbz#1694665

* Sun Feb 03 2019 Fedora Release Engineering <releng@fedoraproject.org> - 3.12.0.0-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Tue Jan 29 2019 Jonathan Wakely <jwakely@redhat.com> - 3.12.0.0-3
- Add upstream patches for Boost 1.69.0 header changes

* Fri Jan 25 2019 Jonathan Wakely <jwakely@redhat.com> - 3.12.0.0-3
- Rebuilt for Boost 1.69

* Mon Dec 10 2018 Jaroslav Škarvada <jskarvad@redhat.com> - 3.12.0.0-2
- Rebuilt for new gnuradio
  Resolves: rhbz#1625012
- Fixed python shebangs

* Fri Jul 20 2018 Jaroslav Škarvada <jskarvad@redhat.com> - 3.12.0.0-1
- New version
  Resolves: rhbz#1606606
- Dropped sdcc-3-fix patch (upstreamed)
- Dropped boost-gcc8-compile-fix patch (not needed)
- Packaged wireshark dissectors

* Sat Jul 14 2018 Fedora Release Engineering <releng@fedoraproject.org> - 3.10.3.0-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Wed Feb 28 2018 Iryna Shcherbina <ishcherb@redhat.com> - 3.10.3.0-3
- Update Python 2 dependency declarations to new packaging standards
  (See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3)

* Fri Feb 09 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 3.10.3.0-2
- Escape macros in %%changelog

* Fri Feb  2 2018 Jaroslav Škarvada <jskarvad@redhat.com> - 3.10.3.0-1
- New version

* Fri Feb  2 2018 Jaroslav Škarvada <jskarvad@redhat.com> - 3.10.1.0-10
- Rebuilt for new boost

* Tue Jan 23 2018 Jonathan Wakely <jwakely@redhat.com> - 3.10.1.0-9
- Rebuilt for Boost 1.66

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.10.1.0-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.10.1.0-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Wed Jul 19 2017 Jonathan Wakely <jwakely@redhat.com> - 3.10.1.0-6
- Rebuilt for s390x binutils bug

* Tue Jul 04 2017 Jonathan Wakely <jwakely@redhat.com> - 3.10.1.0-5
- Rebuilt for Boost 1.64

* Mon May 15 2017 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.1.0-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_27_Mass_Rebuild

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.10.1.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Mon Jan 30 2017 Jonathan Wakely <jwakely@redhat.com> - 3.10.1.0-2
- Rebuilt for Boost 1.63

* Tue Nov 22 2016 Jaroslav Škarvada <jskarvad@redhat.com> - 3.10.1.0-1
- New version
- Dropped base64-decode-fix-off-by-one patch (upstreamed)
- Switched to new version numbering
- Switched image archive to xz

* Wed May 25 2016 Jaroslav Škarvada <jskarvad@redhat.com> - 3.9.4-2
- Fixed off by one in base64_decode by base64-decode-fix-off-by-one patch
  Related: rhbz#1308204

* Tue May 10 2016 Jaroslav Škarvada <jskarvad@redhat.com> - 3.9.4-1
- New version
- Dropped 0001-fix-build patch (upstreamed)

* Mon May  9 2016 Jaroslav Škarvada <jskarvad@redhat.com> - 3.8.2-12
- Rebuilt to fix Boost ABI problem

* Fri Feb 05 2016 Fedora Release Engineering <releng@fedoraproject.org> - 3.8.2-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Sat Jan 16 2016 Jonathan Wakely <jwakely@redhat.com> - 3.8.2-10
- Rebuilt for Boost 1.60

* Thu Aug 27 2015 Jonathan Wakely <jwakely@redhat.com> - 3.8.2-9
- Rebuilt for Boost 1.59

* Thu Aug 06 2015 Jonathan Wakely <jwakely@redhat.com> 3.8.2-8
- Bump %%release to match f23 branch

* Wed Jul 29 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.8.2-7
- Rebuilt for https://fedoraproject.org/wiki/Changes/F23Boost159

* Wed Jul 22 2015 David Tardon <dtardon@redhat.com> - 3.8.2-6
- rebuild for Boost 1.58

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.8.2-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Sat May 02 2015 Kalev Lember <kalevlember@gmail.com> - 3.8.2-4
- Rebuilt for GCC 5 C++11 ABI change

* Thu Mar 12 2015 Jaroslav Škarvada <jskarvad@redhat.com> - 3.8.2-3
- Enabled build on ppc64 on RHEL

* Wed Mar 11 2015 Jaroslav Škarvada <jskarvad@redhat.com> - 3.8.2-2
- Fixed building without NEON, especially on aarch64
  Resolves: rhbz#1200836

* Fri Mar  6 2015 Jaroslav Škarvada <jskarvad@redhat.com> - 3.8.2-1
- New version
- Dropped uhd-dump-libs and wireshark-1.12-fix patches (both upstreamed)

* Tue Jan 27 2015 Petr Machata <pmachata@redhat.com> - 3.7.2-2
- Rebuild for boost 1.57.0

* Mon Sep  1 2014 Jaroslav Škarvada <jskarvad@redhat.com> - 3.7.2-1
- New version
- Added tools subpackage (wireshark plugin disabled due to rhbz#1129419)
- Minor packaging fixes

* Fri Aug 29 2014 Jaroslav Škarvada <jskarvad@redhat.com> - 3.6.2-6
- Migrated udev rule to dynamic ACL management
- Fixed udev rule location
- Group usrp is no more used / created

* Mon Aug 18 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.6.2-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Fri Aug  8 2014 Jaroslav Škarvada <jskarvad@redhat.com> - 3.6.2-4
- Added workaround for build failure on RHEL-7

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.6.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Thu May 22 2014 Petr Machata <pmachata@redhat.com> - 3.6.2-2
- Rebuild for boost 1.55.0

* Tue Feb 11 2014 Jaroslav Škarvada <jskarvad@redhat.com> - 3.6.2-1
- New version
  Resolves: rhbz#1063587

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.5.3-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Sat Jul 27 2013 pmachata@redhat.com - 3.5.3-2
- Rebuild for boost 1.54.0

* Wed Jun 05 2013 Jaroslav Škarvada <jskarvad@redhat.com> - 3.5.3-1
- New version
- Defuzzified no-neon patch

* Sun Feb 10 2013 Denis Arnaud <denis.arnaud_fedora@m4x.org> - 3.4.3-3
- Rebuild for Boost-1.53.0

* Sat Feb 09 2013 Denis Arnaud <denis.arnaud_fedora@m4x.org> - 3.4.3-2
- Rebuild for Boost-1.53.0

* Wed Aug 22 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.4.3-1
- New version

* Fri Aug 10 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.4.2-4
- Rebuilt for new boost

* Sun Jul 22 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Wed Jun  6 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.4.2-2
- Added firmware subpackage
  Resolves: rhbz#769684

* Wed May 23 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.4.2-1
- New version
- Removed usrp1-r45-dbsrx-i2c-fix patch (upstreamed)
- Fixed convert_test failure on ARM by no-neon patch
  Resolves: rhbz#813393

* Tue Mar 27 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.4.0-1
- New version
- Fixed lockup on USRP1 r4.5 + DBSRX + another i2c board combo
  (usrp1-r45-dbsrx-i2c-fix patch)
  Resolves: rhbz#804440

* Mon Mar 19 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.2-1
- New version

* Tue Feb 28 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.3.1-4
- Rebuilt for c++ ABI breakage

* Fri Feb 10 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.1-3
- Allowed UHD to boost the thread's scheduling priority
  Resolves: rhbz#781540

* Wed Jan 11 2012 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.1-2
- Minor tweaks to %%pre scriptlet
- Fixed udev rules
- Added tkinter requires
  Resolves: rhbz#769678

* Fri Dec  2 2011 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.1-1
- New version

* Thu Dec  1 2011 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.0-3
- Updated summary to be more descriptive

* Wed Nov 30 2011 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.0-2
- Fixed according to reviewer comments

* Tue Nov 01 2011 Jaroslav Škarvada <jskarvad@redhat.com> - 3.3.0-1
- Initial version
