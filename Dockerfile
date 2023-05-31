FROM alpine

ENV WEBDIS_REPO https://github.com/Dexcelerate/webdis.git

RUN apk -U upgrade && \
    apk add alpine-sdk libevent libevent-dev bsd-compat-headers git    && \
    git clone --depth 1 $WEBDIS_REPO /tmp/webdis && \
    cd /tmp/webdis && make clean all && \
    cp webdis /usr/local/bin/        && \
    cp webdis.json /etc/             && \
    cp letsencrypt /etc/             && \
    mkdir -p /usr/share/doc/webdis   && \
    cp README.md /usr/share/doc/webdis/README && \
    cd /tmp && rm -rf /tmp/webdis    && \
    apk del --purge alpine-sdk libevent-dev bsd-compat-headers git && \
    rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /entrypoint.sh
EXPOSE 7379
ENTRYPOINT ["/entrypoint.sh"]
