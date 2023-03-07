FROM ubuntu/nginx:latest
# FROM ubuntu
USER root

RUN mkdir -p /home
WORKDIR /home

RUN apt-get update && apt-get install -y curl
# RUN apt-get install nginx-extra -y
# RUN apt-get install -y libpcre3-dev libssl-dev perl make build-essential
# RUN apt-get install -y libluajit-5.1-dev -y
RUN apt-get install libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev libgd-dev libgeoip-dev lua5.3 liblua5.3-dev make build-essential -y
COPY yugabyte-client-2.6-linux.tar.gz /home
COPY lua-nginx-module-0.10.19.tar.gz /home

RUN tar -xvf yugabyte-client-2.6-linux.tar.gz
RUN mv /home/yugabyte-client-2.6 /home/yugabyte
RUN /home/yugabyte/bin/post_install.sh

RUN tar -xvf lua-nginx-module-0.10.19.tar.gz
WORKDIR /home/lua-nginx-module-0.10.19
RUN chmod +x ./config && \
    ./configure --with-http_ssl_module --add-module=/home/lua-nginx-module-0.10.19/
RUN make && make install

WORKDIR /home/yugabyte
RUN mkdir -p /var/cache/nginx/client_temp
RUN mkdir -p /var/cache/nginx/proxy_temp
RUN mkdir -p /var/cache/nginx/fastcgi_temp
RUN mkdir -p /var/cache/nginx/uwsgi_temp
RUN mkdir -p /var/cache/nginx/scgi_temp
RUN chmod 700 /etc/nginx

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/yugabyte/bin
ENV YB_HOME=/etc/nginx
ENV container=yugabyte
LABEL maintainer=YugaByte

EXPOSE 8080:8080

CMD ["nginx", "-g", "daemon off;"]