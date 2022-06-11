#!/bin/sh -e

# Create tunnel
if [[ ! -d /dev/net ]]; then
    mkdir /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi


# Set route tables
echo 200 proxy_outgoing >> /etc/iproute2/rt_tables
ip route add $(ip route | grep default) table proxy_outgoing
ip rule add ipproto tcp sport 3128 lookup proxy_outgoing

# Run OpenVPN server
/usr/sbin/openvpn --config /config.ovpn --up /run-proxy-server.sh --script-security 2
