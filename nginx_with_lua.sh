#!/usr/bin/bash
#
# (Original gist from https://gist.github.com/jmervine/5407622/raw/nginx_w_lua.bash)

set -x
cd /tmp

if ! test -d /usr/local/include/luajit-2.0; then
    echo "Installing LuaJIT-2.0.1."
    wget "http://luajit.org/download/LuaJIT-2.0.1.tar.gz"
    tar -xzvf LuaJIT-2.0.1.tar.gz
    cd LuaJIT-2.0.1
    make
    sudo make install
else
    echo "Skipping LuaJIT-2.0.1, as it's already installed."
fi

mkdir ngx_devel_kit
cd ngx_devel_kit
wget "https://github.com/simpl/ngx_devel_kit/archive/v0.2.18.tar.gz"
tar -xzvf v0.2.18.tar.gz

NGX_DEV="/tmp/ngx_devel_kit/ngx_devel_kit-0.2.18"

cd /tmp
mkdir lua-nginx-module
cd lua-nginx-module
wget "https://github.com/chaoslawful/lua-nginx-module/archive/v0.7.21.tar.gz"
tar -xzvf v0.7.21.tar.gz

LUA_MOD="/tmp/lua-nginx-module/lua-nginx-module-0.7.21"

cd /tmp
wget 'http://nginx.org/download/nginx-1.2.8.tar.gz'
tar -xzvf nginx-1.2.8.tar.gz
cd ./nginx-1.2.8

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0

./configure --prefix=/opt/nginx \
        --add-module=$NGX_DEV \
        --add-module=$LUA_MOD

make -j2
sudo make install

unset LUAJIT_LIB
unset LUAJIT_INC