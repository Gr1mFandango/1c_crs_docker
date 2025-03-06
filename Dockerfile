FROM alpine:latest as downloader

ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION
ENV installer_type=server32

COPY download.sh /download.sh

WORKDIR /tmp

RUN apk --no-cache add bash curl grep \
  && chmod +x /download.sh \
  && sync; /download.sh \
  && for file in *.zip; do unzip "$file"; done \
  && rm -rf *.zip

FROM i386/debian:bookworm-slim as base

ARG ONEC_VERSION
ARG gosu_ver=1.11
ARG nls_enabled=false
ENV nls=$nls_enabled

COPY --from=downloader /tmp/*.deb /tmp/

WORKDIR /tmp

SHELL ["/bin/bash", "-c"]
RUN set -xe; \
  ls -la; \
  if [ "$nls" = true ]; then \
    dpkg -i 1c-enterprise-$ONEC_VERSION-{common,server,ws,crs}*.deb; \
  else \
    dpkg -i 1c-enterprise-$ONEC_VERSION-{common,server,ws,crs}_*.deb; \
  fi
ADD https://github.com/tianon/gosu/releases/download/$gosu_ver/gosu-amd64 /bin/gosu

RUN chmod +x /bin/gosu

ARG onec_uid="999"
ARG onec_gid="999"

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

VOLUME /home/usr1cv8/.1cv8

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh 
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s /usr/local/bin/docker-entrypoint.sh / 
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 1542
CMD ["crserver"]