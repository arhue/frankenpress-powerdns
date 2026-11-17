# frankenpress-powerdns

Two container images with the [caddy-dns/powerdns](https://github.com/caddy-dns/powerdns)
module, so Caddy can get certificates through **ACME DNS-01 with PowerDNS**. That matters
when a site is served from several places (geoDNS or anycast), where HTTP-01 validation can
reach a node other than the one that asked for the certificate.

| Image | Contents | Use |
|---|---|---|
| `ghcr.io/arhue/frankenpress-powerdns` | [FrankenPress](https://github.com/bb/frankenpress) (WordPress on FrankenPHP) + PowerDNS | The WordPress origin |
| `ghcr.io/arhue/caddy-powerdns-cache` | [Caddy](https://caddyserver.com) + PowerDNS + [cache-handler](https://github.com/caddyserver/cache-handler) | Caching reverse proxies (CDN edges) in front of it |

Both are multi-arch (`linux/amd64`, `linux/arm64`) and rebuilt nightly when anything they're
made of has a new release.

## Tags

**frankenpress-powerdns**

| Tag | Meaning |
|---|---|
| `<frankenpress tag>-powerdns-<module version>`, e.g. `php-8.5-trixie-wp7.1.4-20261116-1732-powerdns-v1.0.2` | Immutable: that FrankenPress release plus that PowerDNS module release |
| `php-8.5-trixie-powerdns` | Floating: the newest build |

**caddy-powerdns-cache**

| Tag | Meaning |
|---|---|
| `<caddy version>-powerdns-<module version>-cache-<cache-handler version>`, e.g. `2.11.9-powerdns-v1.0.2-cache-v0.17.0` | Immutable |
| `latest` | Floating: the newest build |

## How they're built

Each image has a GitHub Actions workflow that runs every night at 2 AM Pacific time. It:

1. resolves the newest upstream versions:
   - **frankenpress:** the dated tag behind FrankenPress's floating `php-8.5-trixie`, and
     the FrankenPHP, PHP and Caddy versions inside it (from `frankenphp version`), which pick
     the matching `dunglas/frankenphp` builder;
   - **caddy:** the latest Caddy, caddy-dns/powerdns and cache-handler releases;
2. skips the build if that tag already exists. Otherwise it rebuilds the Caddy binary with
   xcaddy (for FrankenPress, FrankenPHP's
   [custom build](https://frankenphp.dev/docs/docker/#how-to-install-more-caddy-modules)
   recipe: the official modules plus PowerDNS) on top of the unchanged upstream image;
3. smoke-tests each architecture:
   - **frankenpress:** the modules are present, PHP is the same version, WordPress answers;
   - **caddy:** the modules are present, and a repeated request is served from the cache;
4. publishes both architectures under one tag;
5. sends a heartbeat to an Uptime Kuma push monitor, if the repository secret
   `KUMA_PUSH_FRANKENPRESS` / `KUMA_PUSH_CADDY` is set: up when the run succeeded (built or
   nothing new), down with a link to the run when it failed.

## Using DNS-01

**FrankenPress:** everything else is configured exactly as in FrankenPress, e.g.

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

**Caddy edge** with caching:

```
{
	email you@example.com
	acme_dns powerdns {
		server_url https://pdns.example.net
		api_token {env.PDNS_API_TOKEN}
	}
	order cache before rewrite
	cache {
		ttl 300s
	}
}

example.com {
	cache
	reverse_proxy https://origin.example.com
}
```

## License

MIT for this repository. FrankenPress, FrankenPHP, Caddy and the modules keep their own
licenses.
