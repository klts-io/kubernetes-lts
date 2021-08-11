Name: kubernetes-cni
Version: %{_version}
Release: %{_release}
Summary: Binaries required to provision kubernetes container networking
License: ASL 2.0

URL: https://kubernetes.io
Source0: https://storage.googleapis.com/k8s-artifacts-cni/release/v%{version}/cni-plugins-linux-%{_goarch}-v%{version}.tgz

BuildRequires: systemd
BuildRequires: curl
Requires: kubelet

%description
Binaries required to provision container networking.

%prep
%setup -c

install -m 755 -d %{buildroot}%{_sysconfdir}/cni/net.d/
install -m 755 -d %{buildroot}/opt/cni/bin
install -p -m 755 -t %{buildroot}/opt/cni/bin/ *

%files
/opt/cni
