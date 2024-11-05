ARG CADDY_VERSION=2.8.4
ARG BUILD_TIME

FROM caddy:${CADDY_VERSION}-builder AS builder

# ------------------------------------------------------------------
# Modules required
# ------------------------------------------------------------------
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
# [07] https://github.com/hairyhenderson/caddy-teapot-module
		# http.handlers.teapot
### Not used
# https://github.com/mholt/caddy-l4

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/WeidiDeng/caddy-cloudflare-ip \
    --with github.com/zhangjiayin/caddy-geoip2 \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/hslatman/caddy-crowdsec-bouncer \
    --with github.com/corazawaf/coraza-caddy \
    --with github.com/mholt/caddy-l4 \
#    --with github.com/hslatman/caddy-crowdsec-bouncer \
#    --with github.com/hslatman/caddy-crowdsec-bouncer \
#    --with github.com/hslatman/caddy-crowdsec-bouncer \
    --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
