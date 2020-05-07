%define target arm-elf
%define _prefix /opt/%{target}-toolchain

%define newlib_version 1.19.0
%define gcc_version 4.5.2

Name:           %{target}-gcc
Version:        %gcc_version
Release:        0
License:        GPL-3.0 and LGPL-2.0+ and BSD-3-Clause
Summary:        Cross Compiling GNU GCC targeted at %{target}
Url:            http://gcc.gnu.org/
Group:          Development/Tools/Building
Source0:        http://ftp.gnu.org/gnu/gcc/gcc-%{gcc_version}/gcc-%{gcc_version}.tar.bz2
Source1:        ftp://sources.redhat.com/pub/newlib/newlib-%{newlib_version}.tar.gz
Patch0:         fix-gcc5-build.patch
Patch1:         fix-gcc9-build.patch
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  bison
BuildRequires:  automake
BuildRequires:  autoconf
BuildRequires:  gmp-devel
BuildRequires:  mpfr-devel
BuildRequires:  mpc-devel
BuildRequires:  zlib-devel
BuildRequires:  %{target}-binutils = 2.21.1
BuildRequires:  fdupes
Requires:       %{target}-binutils = 2.21.1
ExclusiveArch:  %ix86 x86_64

%description
This is a Cross Compiling version of GNU GCC, which can be used to
compile programs for the %{target} platform, instead of for the
native %{_arch} platform.

%prep
%setup -q -b 1 -n gcc-%{gcc_version}
%patch0 -p2
%if 0%{?suse_version} >= 1550
%patch1 -p1
%endif

# Patch GCC multilib rules
echo "

MULTILIB_OPTIONS += mno-thumb-interwork/mthumb-interwork
MULTILIB_DIRNAMES += normal interwork

" >> ./gcc/config/arm/t-%{target}

# Copy the C library into GCC's source tree to make a combined tree
ln -s ../newlib-%{newlib_version}/newlib .
ln -s ../newlib-%{newlib_version}/libgloss .

# Touch and update some timestamps etc
./contrib/gcc_update --touch

# Extract %%__os_install_post into os_install_post~
cat << \EOF > os_install_post~
%__os_install_post
EOF

# Generate customized brp-*scripts
cat os_install_post~ | while read a x y; do
case $a in
# Prevent brp-strip* from trying to handle foreign binaries
*/brp-strip*)
  b=$(basename $a)
  sed -e 's,find %{buildroot},find %{buildroot}/%{_bindir} %{buildroot}%{_libexecdir},' $a > $b
  chmod a+x $b
  ;;
esac
done
sed -e 's,^[ ]*/usr/lib/rpm.*/brp-strip,./brp-strip,' < os_install_post~ > os_install_post


%build
mkdir -p build
pushd build
../configure \
	--target=%{target} \
	--host=%{_host} \
	--build=%{_build} \
	--prefix=%{_prefix} \
	--infodir=%{_infodir} \
	--mandir=%{_mandir} \
	--with-local-prefix=%{_prefix}/%{target} \
	--disable-shared \
	--disable-nls \
	--enable-interwork \
	--enable-multilib \
	--with-float=soft \
	--with-newlib \
	--with-system-zlib \
	--enable-languages=c,c++ \
	--disable-werror
make all
popd

%install
pushd build
make install DESTDIR=%{buildroot}
popd

# Delete all .la files
find "%{buildroot}%{_prefix}" -type f -name "*.la" -delete
# We don't want these as we are a cross version
rm    %{buildroot}%{_libdir}/libiberty.a
rm -r %{buildroot}%{_prefix}/lib/gcc/%{target}/%{version}/install-tools
rm -r %{buildroot}%{_prefix}/libexec/gcc/%{target}/%{version}/install-tools
rm -r %{buildroot}%{_prefix}/share/gcc-%{version}
rm -r %{buildroot}%{_infodir}
rm -r %{buildroot}%{_mandir}/man7
# Fix permisssions
find "%{buildroot}%{_prefix}/%{target}/lib/" -type f -name "*.a" | xargs chmod 644
# Relink duplicate files
%fdupes -s %{buildroot}
# Use custom os_install_post
%define __os_install_post . ./os_install_post

%files
%defattr(-,root,root)
%doc COPYING COPYING3 COPYING3.LIB COPYING.LIB COPYING.RUNTIME README
%{_prefix}

%changelog

