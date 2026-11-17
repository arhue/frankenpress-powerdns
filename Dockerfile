# FrankenPress (https://github.com/bb/frankenpress) with a FrankenPHP binary that also
# includes the PowerDNS DNS-01 module (https://github.com/caddy-dns/powerdns).
#
# Only the frankenphp binary is rebuilt, with FrankenPHP's documented custom-build recipe;
# PHP (libphp.so), WordPress and everything else come unchanged from FrankenPress. The
# builder must match the FrankenPHP, PHP and Caddy versions inside the FrankenPress image:
# the CI workflow reads them from `frankenphp version` and passes them as build args.
ARG FRANKENPRESS
ARG FRANKENPHP_BUILDER
ARG CADDY_BUILDER

FROM ${CADDY_BUILDER} AS xcaddy

FROM ${FRANKENPHP_BUILDER} AS builder
ARG CADDY_VERSION
ARG POWERDNS_VERSION
COPY --from=xcaddy /usr/bin/xcaddy /usr/bin/xcaddy
# The official build's modules (FrankenPHP, Brotli, Mercure, Vulcain), plus PowerDNS
RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    CGO_CFLAGS="$(php-config --includes)" \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build ${CADDY_VERSION} \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp=./ \
        --with github.com/dunglas/frankenphp/caddy=./caddy/ \
        --with github.com/dunglas/caddy-cbrotli \
        --with github.com/dunglas/mercure/caddy \
        --with github.com/dunglas/vulcain/caddy \
        --with github.com/caddy-dns/powerdns@${POWERDNS_VERSION}

FROM ${FRANKENPRESS}
ARG FRANKENPRESS
ARG POWERDNS_VERSION
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
LABEL org.opencontainers.image.title="FrankenPress + PowerDNS" \
      org.opencontainers.image.description="FrankenPress (WordPress on FrankenPHP) with the caddy-dns/powerdns DNS-01 module" \
      org.opencontainers.image.source="https://github.com/arhue/frankenpress-powerdns" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="docker.io/${FRANKENPRESS}" \
      io.github.arhue.powerdns-module.version="${POWERDNS_VERSION}"
