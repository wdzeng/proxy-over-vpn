FROM alpine:3.15 AS build-nginx
LABEL maintainer="kzmake <kzmake.i3a@gmail.com>, hyperbola <me@hyperbola.me>"

ENV NGINX_VERSION=1.21.1
ENV PATCH_REPO=https://github.com/chobits/ngx_http_proxy_connect_module.git
ENV PATCH_FILE=https://raw.githubusercontent.com/chobits/ngx_http_proxy_connect_module/master/patch/proxy_connect_rewrite_102101.patch
ARG CONFIG=" \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-Os' \
    --with-ld-opt=-Wl,--as-needed"

# Add user and group and install essential utilities
WORKDIR /tmp
RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache patch build-base pcre-dev openssl-dev zlib-dev git linux-headers

# Download nginx source
WORKDIR /tmp
RUN set -x \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz

# Download patch
WORKDIR /tmp
ADD ${PATCH_FILE} ./patch
RUN set -x \
    && git clone --depth 1 ${PATCH_REPO} ngx_http_proxy_connect_module

# Patch and install nginx
WORKDIR /tmp/nginx-${NGINX_VERSION}
RUN set -x \
    && patch -p1 -i ../patch \
    && ./configure ${CONFIG} --add-module=/tmp/ngx_http_proxy_connect_module \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install


FROM alpine:3.15
LABEL maintainer="kzmake <kzmake.i3a@gmail.com>, hyperbola <me@hyperbola.me>"

RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache ca-certificates openssl pcre tzdata openvpn tini \
    && mkdir -p /var/log/nginx /var/run/nginx /usr/lib/nginx/modules /etc/nginx /var/cache/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --from=build-nginx /usr/sbin/nginx /usr/sbin/nginx
COPY --from=build-nginx /etc/nginx /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
COPY run-proxy-server.sh /run-proxy-server.sh

EXPOSE 3128
STOPSIGNAL SIGTERM
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
