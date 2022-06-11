# Proxy over VPN

![MEME](res/meme.webp)

Run forward proxy server over VPN with docker.

> **Warning**  
> Since a root container is required, you should not use podman.

This image contains [NGINX](https://www.nginx.com/) server with [ngx_http_proxy_connect_module module](https://github.com/chobits/ngx_http_proxy_connect_module) and [OpenVPN](https://openvpn.net/). User traffics first arrive the forward proxy server, which then forward them over the VPN to the world.

## Usage

Prepare an .ovpn file for OpenVPN config.

Common usage:

```sh
docker run [-it] \
    --cap-add NET_ADMIN \
    -p <exposed-port>:3128 \
    -v /path/to/ovpn:/config.ovpn
    hyperbola/proxy-over-vpn:v1
```

- NGINX server acts as forward proxy server which exposes port on 3128, and therefore you need to set `-p <exposed-port>:3128` to forward the port.
- OpenVPN requires the `NET_ADMIN` capability to work so you need to set `--cap-add NET_ADMIN` flag.
- OpenVPN client reads the config at /config.ovpn so you need to mount that file with `-v /path/to/ovpn:/config.ovpn`.
