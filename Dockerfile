ARG IMAGE_VERSION=8.0.26-17

FROM registry.n-os.org:5000/root-ca:20220205 AS certs

FROM percona/percona-server:$MYSQL_VERSION

ARG IMAGE_UID=2020
ARG IMAGE_GID=2020

USER root

COPY --from=certs /CA/certs/mysqldb/ /etc/ssl/certs/mysqldb/
ADD require_tls.cnf /etc/my.cnf.d/require_tls.cnf

RUN usermod -u $IMAGE_UID mysql \
  && groupmod -g $IMAGE_GID mysql \
  && bash -c "find / -uid 1001 -exec chown ${IMAGE_UID}:${IMAGE_GID} {} \; || true" \
  && mkdir /var/backup \
  && chown $IMAGE_UID:$IMAGE_GID /var/backup \
  && /etc/ssl/certs/mysqldb/setup.sh ${IMAGE_UID}

VOLUME ["/var/backup"]

USER mysql
