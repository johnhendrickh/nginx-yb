# FROM ubuntu/nginx:latest
FROM ubuntu
USER root

RUN mkdir -p /home
WORKDIR /home

RUN apt-get update && apt-get install -y curl
# RUN apt-get install wget -y
# RUN apt-get install nginx-extra -y
RUN apt-get install -y libpcre3-dev libssl-dev perl make build-essential
# RUN apt-get install -y luajit libluajit-5.1-dev
# RUN apt-get install libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev libgd-dev libgeoip-dev lua5.3 liblua5.3-dev make build-essential -y
COPY yugabyte-client-2.6-linux.tar.gz /home
COPY lua-nginx-module-0.10.19.tar.gz /home
COPY LuaJIT-2.1.0-beta3.tar.gz /home
COPY lua-resty-core-0.1.21.tar.gz /home
RUN tar -xvf lua-resty-core-0.1.21.tar.gz
COPY lua-resty-lrucache-0.09.tar.gz /home
RUN tar -xvf lua-resty-lrucache-0.09.tar.gz
COPY nginx-1.22.1.tar.gz /home
RUN mkdir /etc/nginx
RUN tar -xvf nginx-1.22.1.tar.gz
RUN mv /home/nginx-1.22.1 /home/nginx

RUN tar -xvf yugabyte-client-2.6-linux.tar.gz
RUN mv /home/yugabyte-client-2.6 /home/yugabyte

RUN /home/yugabyte/bin/post_install.sh


RUN tar -xvf LuaJIT-2.1.0-beta3.tar.gz
WORKDIR /home/LuaJIT-2.1.0-beta3
RUN make && make install

RUN mv /home/lua-resty-core-0.1.21/lib/resty /usr/local/share/lua/5.1/
RUN cp -r /home/lua-resty-lrucache-0.09/lib/resty/* /usr/local/share/lua/5.1/resty/

# WORKDIR /home/nginx
# RUN ./configure --without-http_gzip_module
# RUN make && make


ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_LIB_DIR=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1
# ENV LUAJIT_INCDIR=/home/LuaJIT-2.1.0-beta3   

WORKDIR /home
RUN tar -xvf lua-nginx-module-0.10.19.tar.gz
# WORKDIR /home/lua-nginx-module-0.10.19
# RUN chmod +x ./config
# RUN ./configure --prefix=/usr/local/nginx --add-module=/home/lua-nginx-module-0.10.19/
WORKDIR /home/nginx
# RUN ./configure --with-http_ssl_module --add-module=/home/lua-nginx-module-0.10.19/

RUN ./configure --add-module=/home/lua-nginx-module-0.10.19/ --prefix=/usr/local/nginx --without-http_gzip_module --with-ld-opt="-Wl,-rpath,/usr/local/lib" --with-http_stub_status_module --with-http_ssl_module 
RUN make && make install

WORKDIR /home/yugabyte
RUN mkdir -p /var/cache/nginx/client_temp
RUN mkdir -p /var/cache/nginx/proxy_temp
RUN mkdir -p /var/cache/nginx/fastcgi_temp
RUN mkdir -p /var/cache/nginx/uwsgi_temp
RUN mkdir -p /var/cache/nginx/scgi_temp

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/yugabyte/bin:/usr/local/nginx/sbin:
ENV YB_HOME=/etc/nginx
ENV container=yugabyte
LABEL maintainer=YugaByte
# RUN sed -i '/http {/a lua_shared_dict jit_locks 10m;' /usr/local/nginx/conf/nginx.conf

EXPOSE 8080:8080

CMD ["nginx", "-g", "daemon off;"]