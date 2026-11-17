# frankenpress-powerdns

[FrankenPress](https://github.com/bb/frankenpress) (WordPress on FrankenPHP) with the
[caddy-dns/powerdns](https://github.com/caddy-dns/powerdns) module compiled into FrankenPHP's
Caddy, so the built-in Caddy can get certificates through **ACME DNS-01 with PowerDNS**. That
matters when a site is served from several places (geoDNS or anycast), where HTTP-01
validation can reach a node other than the one that asked for the certificate.

```
docker pull ghcr.io/arhue/frankenpress-powerdns:php-8.5-trixie-powerdns
```

## Tags

| Tag | Meaning |
|---|---|
| `<frankenpress tag>-powerdns-<module version>`, e.g. `php-8.5-trixie-wp7.1.4-20261116-1732-powerdns-v1.0.2` | Immutable: that FrankenPress release plus that PowerDNS module release |
| `php-8.5-trixie-powerdns` | Floating: the newest build |

Images are multi-arch (`linux/amd64`, `linux/arm64`).

## How it's built

A GitHub Actions workflow runs every night. It:

1. resolves FrankenPress's floating `php-8.5-trixie` tag to the dated tag it points at;
2. takes the latest `caddy-dns/powerdns` release;
3. reads the FrankenPHP, PHP and Caddy versions from inside that FrankenPress image and picks
   the matching `dunglas/frankenphp` builder;
4. skips the build if that tag combination already exists. Otherwise it rebuilds only the
   `frankenphp` binary (FrankenPHP's
   [custom build](https://frankenphp.dev/docs/docker/#how-to-install-more-caddy-modules)
   recipe: the official modules plus PowerDNS) on top of the unchanged FrankenPress image;
5. smoke-tests each architecture (modules present, the same PHP version, WordPress
   answering), then publishes both architectures under one tag.

## Using DNS-01

Everything else is configured exactly as in FrankenPress. For example, to issue the site's
certificates through a PowerDNS API:

```yaml
environment:
  SERVER_NAME: example.com
  CADDY_GLOBAL_OPTIONS: |
    email you@example.com
    acme_dns powerdns {
      server_url https://pdns.example.net
      api_token {env.PDNS_API_TOKEN}
    }
  PDNS_API_TOKEN: ...
```

## License

MIT, like FrankenPress. FrankenPress, FrankenPHP, Caddy and the PowerDNS module keep their
own licenses.
