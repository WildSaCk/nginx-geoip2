FROM nginx:alpine as builder

WORKDIR /root
RUN apk update && apk upgrade && apk add --no-cache git gcc g++ make libmaxminddb-dev pcre-dev zlib-dev && \
    git clone https://github.com/leev/ngx_http_geoip2_module.git && \
    version=`nginx -v 2>&1 | xargs echo | awk -F/ '{print $2}'` && \
    wget http://nginx.org/download/nginx-$version.tar.gz && \
    tar xzf nginx-$version.tar.gz && mv nginx-$version nginx && cd nginx && \
    ./configure  --add-dynamic-module=/root/ngx_http_geoip2_module --with-stream $(nginx -V) --with-compat && \
    make -j$(nproc)

FROM nginx:alpine

RUN apk --no-cache add libmaxminddb
COPY --from=builder /root/nginx/objs/ngx_http_geoip2_module.so /root/nginx/objs/ngx_stream_geoip2_module.so /etc/nginx/modules/
