FROM debian:12

# Install docker, ddev and other dependencies.
USER root

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends \
      ca-certificates \
      curl \
      gpg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
 && curl -fsSL https://pkg.ddev.com/apt/gpg.key | gpg --dearmor > /etc/apt/keyrings/ddev.gpg \
 && chmod a+r /etc/apt/keyrings/ddev.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/ddev.gpg] https://pkg.ddev.com/apt/ * *" > /etc/apt/sources.list.d/ddev.list \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends \
      btrfs-progs \
      iptables \
      net-tools \
      openssl \
      docker-ce=5:27.* \
      ddev=1.* \
      sudo \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean -yqq \
 && apt-get autoremove -yqq -o=Dpkg::Use-Pty=0

#RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

RUN sed -i 's/ulimit -Hn/# ulimit -Hn/g' /etc/init.d/docker \
 && update-alternatives --set iptables /usr/sbin/iptables-legacy \
 && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# btrfs storage
ENV BTRFS_FILE=/var/lib/docker-btrfs.img
RUN dd if=/dev/zero of=$BTRFS_FILE bs=1G count=5 \
 && echo '{"storage-driver": "btrfs"}' > /etc/docker/daemon.json

# ddev
RUN mkcert -install \
 && useradd --system --create-home --home-dir /home/ddev --shell /bin/bash --groups docker ddev
COPY ddev-download-images.sh /usr/local/bin
RUN chmod +x /usr/local/bin/ddev-download-images.sh

# entrypoint
COPY ["entrypoint.sh", "btrfs-mount.sh", "btrfs-umount.sh", "/usr/local/bin"]
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/btrfs-mount.sh /usr/local/bin/btrfs-umount.sh

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []

EXPOSE 2375
