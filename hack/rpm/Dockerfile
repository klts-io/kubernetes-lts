FROM fedora:24

RUN dnf install -y rpm-build rpmdevtools createrepo && dnf clean all && rpmdev-setuptree

USER root
ADD entrypoint.sh /root/
COPY ./ /root/rpmbuild/SPECS
ENTRYPOINT ["/root/entrypoint.sh"]
