Name:       ru.bmstu.MobAdaptUi
Summary:    Adaptive UI via DQN
Version:    0.1
Release:    1
License:    BSD-3-Clause
URL:        https://auroraos.ru
Source0:    %{name}-%{version}.tar.bz2

Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(auroraapp)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  cmake
BuildRequires:  ninja

%description
Adaptive UI via DQN.
(C) Dmitry Vidmanov, BMSTU IU-3.

%prep
%autosetup

%build
%cmake -GNinja -DCMAKE_SYSTEM_PROCESSOR=%{_arch} -DBUILD_LIST=core,imgcodecs
%ninja_build

%install
%ninja_install

rm -rf %{buildroot}/%{_bindir}/*ncnn*

%define __requires_exclude ^(libncnn.*|libncnnd.*).*$
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*$

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
