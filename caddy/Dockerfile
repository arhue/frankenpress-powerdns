# Caddy with the PowerDNS DNS-01 module (https://github.com/caddy-dns/powerdns), the HTTP
# cache handler (https://github.com/caddyserver/cache-handler) and its simplefs storage (a
# disk cache with a byte limit, github.com/darkweak/storages/simplefs), for caching reverse
# proxies (CDN edges) that get their certificates through PowerDNS.
#
# Built with xcaddy on the official caddy builder image; the result replaces the caddy
# binary in the official alpine image. Versions come from the CI workflow as build args.
ARG CADDY_VERSION

FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CADDY_VERSION
ARG POWERDNS_VERSION
ARG CACHE_HANDLER_VERSION
ARG SIMPLEFS_VERSION
RUN xcaddy build v${CADDY_VERSION} \
        --with github.com/caddy-dns/powerdns@${POWERDNS_VERSION} \
        --with github.com/caddyserver/cache-handler@${CACHE_HANDLER_VERSION} \
        --with github.com/darkweak/storages/simplefs/caddy@${SIMPLEFS_VERSION}

FROM caddy:${CADDY_VERSION}-alpine
ARG CADDY_VERSION
ARG POWERDNS_VERSION
ARG CACHE_HANDLER_VERSION
ARG SIMPLEFS_VERSION
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
LABEL org.opencontainers.image.title="Caddy + PowerDNS + cache-handler" \
      org.opencontainers.image.description="Caddy with the caddy-dns/powerdns DNS-01 module and the caddyserver/cache-handler HTTP cache (simplefs disk storage)" \
      org.opencontainers.image.source="https://github.com/arhue/frankenpress-powerdns" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.base.name="docker.io/library/caddy:${CADDY_VERSION}-alpine" \
      io.github.arhue.powerdns-module.version="${POWERDNS_VERSION}" \
      io.github.arhue.cache-handler.version="${CACHE_HANDLER_VERSION}" \
      io.github.arhue.simplefs.version="${SIMPLEFS_VERSION}"
