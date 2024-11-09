ARG CADDY_VERSION=2.8.4
ARG BUILD_TIME
ARG XCADDY_STRING

# ------------------------------------------------------------------
# Modules required
# ------------------------------------------------------------------
# [__] https://github.com/hairyhenderson/caddy-teapot-module
		# http.handlers.teapot
# [01] https://github.com/caddy-dns/cloudflare
		# dns.providers.cloudflare
# [02] https://github.com/WeidiDeng/caddy-cloudflare-ip
		# http.ip_sources.cloudflare
# [03] https://github.com/zhangjiayin/caddy-geoip2
		# geoip2
		# http.handlers.geoip2
# [04] https://github.com/caddyserver/transform-encoder
		# caddy.logging.encoders.formatted
		# caddy.logging.encoders.transform
# [05] https://github.com/hslatman/caddy-crowdsec-bouncer
		# crowdsec
		# http.handlers.crowdsec
		# layer4.matchers.crowdsec
# [06] https://github.com/corazawaf/coraza-caddy
		# http.handlers.waf 
# [07] https://github.com/mholt/caddy-l4
		# layer4.handlers.*
		# layer4.matchers.*
		# layer4.proxy.*
		# tls.handshake_match.alpn
# [08] https://github.com/tailscale/caddy-tailscale
		# http.authentication.providers.tailscale
		# http.reverse_proxy.transport.tailscale
		# tailscale


# FROM caddy:${CADDY_VERSION}-builder AS builder
# ARG XCADDY_STRING
# RUN xcaddy build ${XCADDY_STRING}

# RUN xcaddy build \
#     --with github.com/caddy-dns/cloudflare \
#     --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

# The Tailscale module needs the latest veriosn of go, which caddy-builder does not use.
# So, we will build this a bit more manually.
FROM golang:1 AS builder
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
ENV XCADDY_SETCAP 0
ARG XCADDY_STRING
ARG CADDY_VERSION
RUN xcaddy build v${CADDY_VERSION} ${XCADDY_STRING} --output /usr/bin/caddy

# caddy list-modules --packages --versions


# --------------------------------------------------------

# there is only alpine and windows based images.
FROM caddy:${CADDY_VERSION}-alpine 

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# quality of life improvements
RUN \
	apk add --no-cache \
	bash \
	nano \
	curl 
COPY  support_files/.bashrc /root/.bashrc

ARG BUILD_TIME
ARG XCADDY_LABEL
LABEL release-date=${BUILD_TIME}
LABEL source="https://github.com/zorbaTheRainy/caddy"
LABEL xcaddy_cmd=${XCADDY_LABEL}
