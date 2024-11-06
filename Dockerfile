ARG CADDY_VERSION=2.8.4
ARG BUILD_TIME
ARG XCADDY_STRING

FROM caddy:${CADDY_VERSION}-builder AS builder

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
### Not used
# [08] https://github.com/mholt/caddy-l4
# [09] https://github.com/tailscale/caddy-tailscale

# RUN xcaddy build \
#     --with github.com/caddy-dns/cloudflare \
#     --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

ARG XCADDY_STRING
RUN xcaddy build ${XCADDY_STRING}
# caddy list-modules --packages --versions


# --------------------------------------------------------

# there is only alpine and windows based images.
FROM caddy:${CADDY_VERSION}-alpine 

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# quality of life improvements
RUN \
	apk add --no-cache \
	bash \
	curl 
COPY  support_files/.bashrc /root/.bashrc

ARG BUILD_TIME
LABEL release-date=${BUILD_TIME}
LABEL source="https://github.com/zorbaTheRainy/caddy"
