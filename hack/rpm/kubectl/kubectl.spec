Name: kubectl
Version: %{_version}
Release: %{_release}
Summary: Command-line utility for interacting with a Kubernetes cluster.
License: ASL 2.0

URL: https://kubernetes.io
Source0: %{name}-%{version}.tar.gz

BuildRequires: systemd
# BuildRequires: curl

%description
Command-line utility for interacting with a Kubernetes cluster.

%prep
%setup -n %{name}-%{version}

install -m 755 -d %{buildroot}%{_bindir}
install -p -m 755 -t %{buildroot}%{_bindir}/ kubectl

%files
%{_bindir}/kubectl
