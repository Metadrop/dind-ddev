#
# Sample system container with alpine + supervisord + sshd + docker
#
# Run with:
#
# $ docker run --runtime=sysbox-runc -d -P <this-image>
#

FROM alpine:latest

# docker
RUN apk add --update docker && \
    rm  -rf /tmp/* /var/cache/apk/*

# supervisord
RUN apk add --update supervisor && rm  -rf /tmp/* /var/cache/apk/*
RUN mkdir -p /var/log/supervisor
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord.conf /etc/

# ddev
COPY ddev-download-images.sh /usr/local/bin
RUN chmod +x /usr/local/bin/ddev-download-images.sh

# entrypoint
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
