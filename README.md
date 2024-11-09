# Fork-ish

This is yet another custom build of Caddy, the reverse proxy.

It creates a version of Caddy that can <b>*not*</b> be downloaded from [Caddy Download](https://caddyserver.com/download) 

Annoying, I know. It is the Tailscale module.  Tailscale requires being built directly from the image `golang` instead of `caddy:2.8.4-builder` as that does't include the latest vesion of `go`, which Tailscale itself requires.

Since I went to the trouble of building the image, I added `bash`, `nano`, and `curl`; and a simple `.bashrc`.

# Tags

## Simple Tags

Tags come in 2 general varies: Testing & Production (a.k.a "latest").

The main difference is (a) the platforms (e.g., amd64) I spend time building for, and (b) the chance that the imgae will be functional.

* `testing`: Includes lesser tags values that state the datestamp (%Y-%m-%d--%H-%M) when the image was built.
* `latest`: Includes the `caddy` image from which this build is derived (e.g. 2,8.4-alpine). I do not make any Windows images, and Caddy only builds their Linux images on Alpine.

## Bit flagged Tags

The image tags (aside from "testing" and "latest") include a bit-flag that lets you know what modules have been added to the base `caddy` program.

### Bit Positions and Meanings

Describe the purpose of each bit position and what it represents.

| Bit Position | Meaning |
| ------------ | ------- |
| 0 & 1| [caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare) <br>This package contains a DNS provider module for Caddy. It can be used to manage DNS records with Cloudflare accounts. <br> [caddy-cloudflare-ip](https://github.com/WeidiDeng/caddy-cloudflare-ip) <br> This module retrieves cloudflare ips from their offical website\, ipv4 and ipv6\. It is supported from caddy v2\.6\.3 onwards. |
| 2 | [caddy-geoip2](https://github.com/zhangjiayin/caddy-geoip2) <br> Provides middleware for resolving a users IP address against the Maxmind Geo IP Database.|
| 3 | [transform-encoder](https://github.com/caddyserver/transform-encoder) <br> This module adds logging encoder named transform. The module accepts a template with the placeholders are surrounded by braces {} and filled by values extracted from the stucture of the JSON log encoder. |
| 4 | [caddy-crowdsec-bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) <br> A Caddy module that blocks malicious traffic based on decisions made by CrowdSec.|
| 5 | [coraza-caddy](https://github.com/corazawaf/coraza-caddy) <br>  Caddy Module provides Web Application Firewall capabilities for Caddy, OWASP Corazaia OWASP Coraza |
| 6 |  [Layer 4](https://github.com/mholt/caddy-l4) <br>  An experimental layer 4 app for Caddy. It facilitates composable handling of raw TCP/UDP connections based on properties of the connection or the beginning of the stream. <br> [caddy-json-schema](https://github.com/abiosoft/caddy-json-schema) <br> JSON schema generator for Caddy v2.  <br> The generated schema can be integrated with editors for intellisense and better experience with configuration and plugin development. |
| 7 | [caddy-tailscale](https://github.com/tailscale/caddy-tailscale) <br> Allows running a Tailscale node directly inside of the Caddy web server. This allows a caddy server to join your Tailscale network directly without needing a separate Tailscale client. |
| Always installed | [teapot](https://github.com/hairyhenderson/caddy-teapot-module) <br> Its only purpose is to respond with `418 I'm a teapot` to every request. |

Read the bit-flag right-to-left (e.g., 7654-3210).  For example, the bit-falg 1011-1000 means that bits 3, 4, 5, and 7 are set.


### Example tags

| Full tag | Bit flag portion | Flags Set | Other Meaning |
| ------------- | --------------------- | --------- | --------- |
| `2.8.4-alpine-1100-1011` | 1100-1011 | Cloudflare (both DNS & IP), Log encoder, Layer 4, and Tailscale | Production image, based on caddy 2.8.4 |
| `0000-1011-2024-11-09--20-27` | 0000-1011 | Cloudflare (both DNS & IP), Log encoder| Testing image, built on Nov 9, 2024 at 20:07 UTC |
| `2.8.4-alpine-1111-1111` | 1111-1111  | Everything above | Production image, based on caddy 2.8.4 |
| `2.8.4-alpine-0000-0000` | 0000-0000 | No extra modules, except `teapot`.  <br> No reason to use this over the official `caddy` image (aside from the additonal install of `bash`, `nano`, and `teapot`) | Production image, based on caddy 2.8.4 |



# What is Caddy?

[Caddy 2](https://caddyserver.com/) is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go.

## How to use this image

#### ⚠️ A note about persisted data

Caddy requires write access to two locations: a [data directory](https://caddyserver.com/docs/conventions#data-directory), and a [configuration directory](https://caddyserver.com/docs/conventions#configuration-directory). While it's not necessary to persist the files stored in the configuration directory, it can be convenient. However, it's very important to persist the data directory.

From the docs:

> The data directory must not be treated as a cache. Its contents are not ephemeral or merely for the sake of performance. Caddy stores TLS certificates, private keys, OCSP staples, and other necessary information to the data directory. It should not be purged without an understanding of the implications.

This image provides for two mount-points for volumes: `/data` and `/config`.

In the examples below, a [named volume](https://docs.docker.com/storage/volumes/) `caddy_data` is mounted to `/data`, so that data will be persisted.

Note that named volumes are persisted across container restarts and terminations, so if you move to a new image version, the same data and config directories can be re-used.

### Basic Usage

The default config file simply serves files from `/usr/share/caddy`, so if you want to serve `index.html` from the current working directory:

``` console
$ echo "hello world" > index.html
$ docker run -d -p 80:80 \
    -v $PWD/index.html:/usr/share/index.html \
    -v caddy_data:/data \
    caddy
...
$ curl http://localhost/
hello world
```

To override the default [`Caddyfile`](https://github.com/caddyserver/dist/blob/master/config/Caddyfile), you can mount a new one at `/etc/Caddyfile`:

``` console
$ docker run -d -p 80:80 \
    -v $PWD/Caddyfile:/etc/Caddyfile \
    -v caddy_data:/data \
    caddy
```

### Automatic TLS with the Caddy image

The default `Caddyfile` only listens to port `80`, and does not set up automatic TLS. However, if you have a domain name for your site, and its A/AAAA DNS records are properly pointed to this machine's public IP, then you can use this command to simply serve a site over HTTPS:

``` console
$ docker run -d --cap-add=NET_ADMIN -p 80:80 -p 443:443 -p 443:443/udp \
    -v /site:/srv \
    -v caddy_data:/data \
    -v caddy_config:/config \
    caddy caddy file-server --domain example.com
```

The key here is that Caddy is able to listen to ports `80` and `443`, both required for the ACME HTTP challenge.

See [Caddy's docs](https://caddyserver.com/docs/automatic-https) for more information on automatic HTTPS support!

### Building your own Caddy-based image

Most users deploying production sites will not want to rely on mounting files into a container, but will instead base their own images on `caddy`:

``` Dockerfile
# note: never use the :latest tag in a production site
FROM caddy:<version>

COPY Caddyfile /etc/Caddyfile
COPY site /srv
```

#### Adding custom Caddy modules

Caddy is extendable through the use of "modules". See https://caddyserver.com/docs/extending-caddy for full details. You can find a list of available modules on [the Caddy website's download page](https://caddyserver.com/download).

You can use the `:builder` image as a short-cut to building a new Caddy binary:

``` Dockerfile
FROM caddy:<version>-builder AS builder

RUN xcaddy build \
    --with github.com/caddyserver/nginx-adapter \
    --with github.com/hairyhenderson/caddy-teapot-module@v0.0.3-0

FROM caddy:<version>

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

Note the second `FROM` instruction - this produces a much smaller image by simply overlaying the newly-built binary on top of the regular `caddy` image.

The [`xcaddy`](https://caddyserver.com/docs/build#xcaddy) tool is used to [build a new Caddy entrypoint](https://github.com/caddyserver/blob/4217217badf220d7d2c25f43f955fdc8454f2c64/cmd/main.go#L15..L25), with the provided modules. You can specify just a module name, or a name with a version (separated by `@`). You can also specify a specific version (can be a version tag or commit hash) of Caddy to build from. Read more about [`xcaddy` usage](https://github.com/caddyserver/xcaddy#command-usage).

Note that the "standard" Caddy modules ([`github.com/caddyserver/master/modules/standard`](https://github.com/caddyserver/tree/master/modules/standard)) are always included.

### Graceful reloads

Caddy does not require a full restart when configuration is changed. Caddy comes with a [`caddy reload`](https://caddyserver.com/docs/command-line#caddy-reload) command which can be used to reload its configuration with zero downtime.

When running Caddy in Docker, the recommended way to trigger a config reload is by executing the `caddy reload` command in the running container.

First, you'll need to determine your container ID or name. Then, pass the container ID to `docker exec`. The working directory is set to `/etc/caddy` so Caddy can find your Caddyfile without additional arguments.

``` console
$ caddy_container_id=$(docker ps | grep caddy | awk '{print $1;}')
$ docker exec -w /etc/caddy $caddy_container_id caddy reload
```

### Linux capabilities

Caddy ships with HTTP/3 support enabled by default. To improve the performance of this UDP based protocol, the underlying quic-go library tries to increase the buffer sizes for its socket. The `NET_ADMIN` capability allows it to override the low default limits of the operating system without having to change kernel parameters via sysctl.

Giving the container this capability is optional and has potential, though unlikely, to have [security implications](https://unix.stackexchange.com/a/508816).

See https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes for more details.

### Docker Compose example

If you prefer to use `docker-compose` to run your stack, here's a sample service definition.

``` yaml
version: "3.7"

services:
  caddy:
    image: caddy:<version>
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - $PWD/Caddyfile:/etc/Caddyfile
      - $PWD/site:/srv
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
    external: true
  caddy_config:
```

Defining the data volume as [`external`](https://docs.docker.com/compose/compose-file/compose-file-v3/#external) makes sure `docker-compose down` does not delete the volume. You may need to create it manually using `docker volume create [project-name]_caddy_data`.

# Image Variants

The `caddy` images come in many flavors, each designed for a specific use case.

## `caddy:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

## `caddy:<version>-alpine`

This image is based on the popular [Alpine Linux project](https://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (\~5MB), and thus leads to much slimmer images in general.

This variant is useful when final image size being as small as possible is your primary concern. The main caveat to note is that it does use [musl libc](https://musl.libc.org) instead of [glibc and friends](https://www.etalabs.net/compare_libcs.html), so software will often run into issues depending on the depth of their libc requirements/assumptions. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).

## `caddy:<version>-windowsservercore`

This image is based on [Windows Server Core (`microsoft/windowsservercore`)](https://hub.docker.com/r/microsoft/windowsservercore/). As such, it only works in places which that image does, such as Windows 10 Professional/Enterprise (Anniversary Edition) or Windows Server 2016.

For information about how to get Docker running on Windows, please see the relevant "Quick Start" guide provided by Microsoft:

* [Windows Server Quick Start](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_server)
* [Windows 10 Quick Start](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_10)

# License

View [license information](https://github.com/caddyserver/blob/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in [the `repo-info` repository's directory](https://github.com/docker-library/repo-info/tree/master/repos/caddy).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
