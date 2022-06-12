# Proxy over VPN

[![github](https://badgen.net/badge/icon/github?icon=github&label=&color=black)](https://github.com/wdzeng/proxy-over-vpn/)
[![docker](https://badgen.net/badge/icon/docker?icon=docker&label=)](https://hub.docker.com/repository/docker/hyperbola/proxy-over-vpn)
[![release](https://badgen.net/github/release/wdzeng/proxy-over-vpn?color=red)](https://github.com/wdzeng/proxy-over-vpn/releases/latest)

![MEME](res/meme.webp)

Run HTTP forward proxy server over VPN in docker container.

> **Warning**  
> Since a root container is required, you should not use podman.

> **Warning**  
> This project aims at HTTP proxy only.

This image contains [NGINX](https://www.nginx.com/) server with [ngx_http_proxy_connect_module module](https://github.com/chobits/ngx_http_proxy_connect_module) and [OpenVPN](https://openvpn.net/). User traffics first arrive the forward proxy server, which then forward them over the VPN to the world.

## Usage

Prepare an .ovpn file for OpenVPN config.

Common usage:

```sh
docker run [-it] \
    --cap-add NET_ADMIN \
    -p <exposed-port>:3128 \
    -v /path/to/ovpn:/config.ovpn
    hyperbola/proxy-over-vpn:1
```

- NGINX server acts as forward proxy server which exposes port on 3128, and therefore you need to set `-p <exposed-port>:3128` to forward the port.
- OpenVPN requires the `NET_ADMIN` capability to work so you need to set `--cap-add NET_ADMIN` flag.
- OpenVPN client reads the config at /config.ovpn so you need to mount that file with `-v /path/to/ovpn:/config.ovpn`.

## Logs

By default, logs of nginx server are output to stdout and stderr. Mount to /var/log/nginx/access.log and /var/log/nginx/error.log to collect logs.
