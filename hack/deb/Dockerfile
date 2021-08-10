FROM debian:10

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update -y \
  && apt-get -yy -q install --no-install-recommends --no-install-suggests --fix-missing \
  aptly \
  dpkg-dev \
  build-essential \
  debhelper \
  dh-systemd \
  curl \
  ca-certificates \
  && apt-get upgrade -y \
  && apt-get autoremove -y \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


USER root
ADD entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
