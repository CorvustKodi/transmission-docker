FROM alpine:latest
MAINTAINER CorvustKodi

# Update packages and install software
RUN apk add --update \
    transmission-daemon transmission-cli \
    && rm -rf /var/cache/apk/*

COPY settings.json /settings.json
COPY torrent_done.sh /torrent_done.sh
COPY start.sh /start.sh

RUN mkdir /Torrent-Downloads && \
    mkdir /Torrent-Incomplete && \
    mkdir /pf && \
    mkdir /done-torrents && \
    chmod +xr /torrent_done.sh

ENV USE_VPN 0
ENV RPC_USERNAME user
ENV RPC_PASSWORD pass
ENV RPC_PORT 8880
ENV BLOCKLIST_ENABLED 0

HEALTHCHECK --start-period=60s CMD transmission-remote localhost:${RPC_PORT} -n "${RPC_USERNAME}:${RPC_PASSWORD}" -pt || exit 1

CMD ["/start.sh"]


