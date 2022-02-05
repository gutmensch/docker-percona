ARG MYSQL_VERSION=8.0.26-17

FROM registry.n-os.org:5000/root-ca:20220205 AS certs

FROM percona/percona-server:$MYSQL_VERSION

ARG MYSQL_UID=2020
ARG MYSQL_GID=2020

USER root

COPY --from=certs /CA/certs/mysqldb/ /etc/ssl/certs/mysqldb/
ADD require_tls.cnf /etc/my.cnf.d/require_tls.cnf

RUN usermod -u $MYSQL_UID mysql \
  && groupmod -g $MYSQL_GID mysql \
  && bash -c "find / -uid 1001 -exec chown ${MYSQL_UID}:${MYSQL_GID} {} \; || true" \
  && mkdir /var/backup \
  && chown $MYSQL_UID:$MYSQL_GID /var/backup \
  && chown -R $MYSQL_UID:$MYSQL_GID /etc/ssl/certs/mysqldb \
  && chmod 400 /etc/ssl/certs/mysqldb/server.key \
  # centos specific trust update \
  && ln -s /etc/ssl/certs/mysqldb/ca.crt /etc/pki/ca-trust/source/anchors/docker_root_ca.crt \
  && update-ca-trust \
  # fail build if verify fails \
  && openssl verify -verbose /etc/ssl/certs/mysqldb/server.crt

VOLUME ["/var/backup"]

USER mysql
