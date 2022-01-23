ARG MYSQL_VERSION=8.0.26-16

FROM percona/percona-server:$MYSQL_VERSION

ARG MYSQL_UID=2020
ARG MYSQL_GID=2020

USER root

RUN usermod -u $MYSQL_UID mysql \
  && groupmod -g $MYSQL_GID mysql \
  && bash -c "find / -uid 1001 -exec chown ${MYSQL_UID}:${MYSQL_GID} {} \; || true" \
  && mkdir /var/backup \
  && chown $MYSQL_UID:$MYSQL_GID /var/backup

VOLUME ["/var/backup"]

USER mysql
