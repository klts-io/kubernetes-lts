Name: kubelet
Version: %{_version}
Release: %{_release}
Summary: Container cluster management
License: ASL 2.0

URL: https://kubernetes.io
Source0: %{name}-%{version}.tar.gz

BuildRequires: systemd
# BuildRequires: curl
Requires: iptables >= 1.4.21
Requires: kubernetes-cni >= 0.8.6
Requires: socat
Requires: util-linux
Requires: ethtool
Requires: iproute
Requires: ebtables
Requires: conntrack

%description
The node agent of Kubernetes, the container cluster manager.

%prep
%setup -n %{name}-%{version}
 
install -m 755 -d %{buildroot}%{_unitdir}
install -m 755 -d %{buildroot}%{_unitdir}/kubelet.service.d/
install -m 755 -d %{buildroot}%{_bindir}
install -m 755 -d %{buildroot}/var/lib/kubelet/
install -p -m 755 -t %{buildroot}%{_bindir}/ kubelet
install -p -m 644 -t %{buildroot}%{_unitdir}/ kubelet.service
install -m 755 -d %{buildroot}%{_sysconfdir}/sysconfig/
install -p -m 644 -T kubelet.env %{buildroot}%{_sysconfdir}/sysconfig/kubelet

 

%files
%{_bindir}/kubelet
%{_unitdir}/kubelet.service

%config(noreplace) %{_sysconfdir}/sysconfig/kubelet
