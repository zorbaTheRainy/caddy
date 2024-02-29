ARG CADDY_VERSION=2.7.6
ARG BUILD_TIME

FROM caddy:${CADDY_VERSION=}-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/godaddy \
    --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

FROM caddy:${CADDY_VERSION=}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
