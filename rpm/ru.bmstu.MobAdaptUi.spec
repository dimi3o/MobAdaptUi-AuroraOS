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

%description
Adaptive UI via DQN.
(C) Dmitry Vidmanov, BMSTU IU-3.

%prep
%autosetup

%build
%cmake -GNinja
%ninja_build

%install

mkdir -p %{buildroot}/%{_datadir}/%{name}/lib/
cp $RPM_SOURCE_DIR/../trainingData.txt %{buildroot}/%{_datadir}/%{name}/lib/
chmod 600 %{buildroot}/%{_datadir}/%{name}/lib/trainingData.txt

%ninja_install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
