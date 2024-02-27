# [caddy](https://hub.docker.com/_/caddy)

This is the repo where an **un**-official `caddy` Docker image sources live.

**Please see https://hub.docker.com/_/caddy for documentation.**

If you have an issue or suggestion for the official Docker image, please [open an issue](https://github.com/caddyserver/caddy-docker/issues/new).

If you'd like to suggest updates to the [image documentation](https://hub.docker.com/_/caddy), see https://github.com/docker-library/docs/tree/master/caddy.

## Changes to the Official Release

I have added a web UI to edit the Caddyfile, using [Jaime Pillora's webproc](https://github.com/jpillora/webproc/).

Per the instrucitons below, you'll be able to easily edit the Caddyfile and then restart caddy.


## Usage

Visit [http://localhost:8080](http://localhost:8080) and view the process configuration, status and logs.

Below is an image of webproc running DNSmasq

You'll notice the screen is split in 2.  One half shows an edittable veriosn of the config file (Caddyfile), the other STDOUT/STDERR.

<img width="747" alt="screen shot 2016-09-22 at 1 39 01 am" src="https://cloud.githubusercontent.com/assets/633843/18718069/7d515392-8065-11e6-8ba5-86b6e59f3992.png">

## Docker Compose file

```

```


