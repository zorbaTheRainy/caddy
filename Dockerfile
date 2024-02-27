ARG CADDY_VERSION=2.7.6

FROM caddy:${CADDY_VERSION}-alpine

ARG TARGETARCH
ARG TARGETVARIANT

ARG BUILD_TIME
ARG WEBPROC_VERSION=0.4.0

ENV WEBPROC_URL_AMD64 https://github.com/jpillora/webproc/releases/download/v$WEBPROC_VERSION/webproc_${WEBPROC_VERSION}_linux_amd64.gz
ENV WEBPROC_URL_ARM64 https://github.com/jpillora/webproc/releases/download/v$WEBPROC_VERSION/webproc_${WEBPROC_VERSION}_linux_arm64.gz
ENV WEBPROC_URL_ARMv7 https://github.com/jpillora/webproc/releases/download/v$WEBPROC_VERSION/webproc_${WEBPROC_VERSION}_linux_armv7.gz
ENV WEBPROC_URL_ARMv6 https://github.com/jpillora/webproc/releases/download/v$WEBPROC_VERSION/webproc_${WEBPROC_VERSION}_linux_armv6.gz

LABEL maintainer="ZorbaTheRainy"
LABEL release-date=${BUILD_TIME}
LABEL source="https://github.com/zorbaTheRainy/caddy_webproc"


# webproc release settings
COPY Caddyfile /etc/caddy/Caddyfile

RUN set -eux  && \
    apk update && apk upgrade  && \
    apk add curl  && \
	case "${TARGETARCH}" in \
		amd64)  curl -sL $WEBPROC_URL_AMD64 | gzip -d - > /usr/local/bin/webproc   ;; \
		arm64)  curl -sL $WEBPROC_URL_ARM64 | gzip -d - > /usr/local/bin/webproc   ;; \
        arm) \
            case "${TARGETVARIANT}" in \
                v6)   curl -sL $WEBPROC_URL_ARMv6 | gzip -d - > /usr/local/bin/webproc   ;; \
                v7)   curl -sL $WEBPROC_URL_ARMv7 | gzip -d - > /usr/local/bin/webproc   ;; \
                v8)   curl -sL $WEBPROC_URL_ARM64 | gzip -d - > /usr/local/bin/webproc   ;; \
                *) echo >&2 "error: unsupported architecture (${TARGETARCH}/${TARGETVARIANT})"; exit 1 ;; \
            esac;  ;; \
		*) echo >&2 "error: unsupported architecture (${TARGETARCH}/${TARGETVARIANT})"; exit 1 ;; \
    esac  && \
	chmod +x /usr/local/bin/webproc  

EXPOSE 8081
EXPOSE 80 443 443/udp 2019

WORKDIR /srv

# launch webproc, which in turn launches caddy
ENTRYPOINT ["webproc","--port","8081","--configuration-file","/etc/caddy/Caddyfile","--","caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
