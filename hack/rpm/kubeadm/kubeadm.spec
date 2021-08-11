Name: kubeadm
Version: %{_version}
Release: %{_release}
Summary: Command-line utility for administering a Kubernetes cluster.
License: ASL 2.0

URL: https://kubernetes.io
Source0: %{name}-%{version}.tar.gz

BuildRequires: systemd

Requires: kubelet >= %{_version}
Requires: kubectl >= %{_version}
Requires: kubernetes-cni >= 0.8.6
Requires: cri-tools >= 1.13.0

%description
Command-line utility for administering a Kubernetes cluster.

%prep
%setup

install -m 755 -d %{buildroot}%{_sysconfdir}/kubernetes/manifests/
install -m 755 -d %{buildroot}%{_unitdir}/kubelet.service.d/
install -m 755 -d %{buildroot}%{_bindir}
install -p -m 755 -t %{buildroot}%{_bindir}/ kubeadm
install -p -m 644 -t %{buildroot}%{_unitdir}/kubelet.service.d/ 10-kubeadm.conf

%files
%{_bindir}/kubeadm
%{_unitdir}/kubelet.service.d/10-kubeadm.conf
