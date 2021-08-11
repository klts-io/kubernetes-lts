Name: cri-tools
Version: %{_version}
Release: %{_release}
Summary: Command-line utility for interacting with a container runtime.
License: ASL 2.0

URL: https://kubernetes.io
Source0: https://storage.googleapis.com/k8s-artifacts-cri-tools/release/v%{version}/crictl-v%{version}-linux-%{_goarch}.tar.gz

BuildRequires: systemd
BuildRequires: curl

%description
Command-line utility for interacting with a container runtime.

%prep
%setup -c

install -m 755 -d %{buildroot}%{_bindir}
install -p -m 755 -t %{buildroot}%{_bindir}/ crictl

%files
%{_bindir}/crictl
