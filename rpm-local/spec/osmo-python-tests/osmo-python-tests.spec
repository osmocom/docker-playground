#
# spec file for package osmo-python-tests
#
# Copyright (c) 2018, Martin Hauke <mardnh@gmx.de>
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

%{?!python_module:%define python_module() python-%{**} python3-%{**}}
Name:           osmo-python-tests
Version:        0.0.0.git1576583006.4a7a208
Release:        0
Summary:        Osmopython: Osmocom testing scripts
License:        AGPL-3.0-or-later AND GPL-2.0-or-later
Group:          Development/Languages/Python
URL:            https://git.osmocom.org/python/osmo-python-tests/
Source:         %{name}-%{version}.tar.xz
BuildRequires:  %{python_module Twisted}
BuildRequires:  %{python_module setuptools}
BuildRequires:  fdupes
BuildRequires:  python-rpm-macros
BuildArch:      noarch
%python_subpackages

%description
Python code (not only) for testing of Osmocom programs.

%prep
%setup -q
# drop shebang
find osmopy/ -name "*.py" -exec sed -i -e '/^#!\//, 1d' {} \;

%build
%python_build

%install
%python_install
%python_expand %fdupes %{buildroot}%{$python_sitelib}

%check
%python_exec setup.py test

%files %{python_files}
%doc README
%python3_only %{_bindir}/osmo_ctrl.py
%python3_only %{_bindir}/osmo_interact_ctrl.py
%python3_only %{_bindir}/osmo_interact_vty.py
%python3_only %{_bindir}/osmo_rate_ctr2csv.py
%python3_only %{_bindir}/osmo_verify_transcript_ctrl.py
%python3_only %{_bindir}/osmo_verify_transcript_vty.py
%python3_only %{_bindir}/osmodumpdoc.py
%python3_only %{_bindir}/osmotestconfig.py
%python3_only %{_bindir}/osmotestvty.py
%python3_only %{_bindir}/soap.py
%python3_only %{_bindir}/ctrl2cgi.py
%python3_only %{_bindir}/osmo_trap2cgi.py
%{python_sitelib}/*

%changelog
