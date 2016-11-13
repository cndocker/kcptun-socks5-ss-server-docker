# kcp-server & shadowsocks-libev for Dockerfile
FROM alpine:latest
MAINTAINER cnDocker

ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev/archive/v2.5.6.tar.gz \
    SS_DIR=shadowsocks-libev-2.5.6 \
    libsodium_latest="https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz" \
    CONF_DIR="/usr/local/conf" \
    kcptun_latest="https://github.com/xtaci/kcptun/releases/latest" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN set -ex && \
    apk add --no-cache pcre bash && \
    apk add --no-cache  --virtual TMP autoconf build-base wget curl tar libtool linux-headers openssl-dev pcre-dev && \
    curl -sSL $SS_URL | tar xz && \
    cd $SS_DIR && \
    ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf $SS_DIR && \
    mkdir /tmp/libsodium && \
    curl -Lk ${libsodium_latest}|tar xz -C /tmp/libsodium --strip-components=1 && \
    cd /tmp/libsodium && \
    ./configure && \
    make -j $(awk '/processor/{i++}END{print i}' /proc/cpuinfo) && \
    make install && \
    [ ! -d ${CONF_DIR} ] && mkdir -p ${CONF_DIR} && \
    [ ! -d ${KCPTUN_DIR} ] && mkdir -p ${KCPTUN_DIR} && cd ${KCPTUN_DIR} && \
    wget https://raw.githubusercontent.com/clangcn/kcp-server/master/socks5_latest/socks5_linux_amd64 -O ${KCPTUN_DIR}/socks5 && \
    kcptun_latest_release=`curl -s ${kcptun_latest} | cut -d\" -f2` && \
    kcptun_latest_download=`curl -s ${kcptun_latest} | cut -d\" -f2 | sed 's/tag/download/'` && \
    kcptun_latest_filename=`curl -s ${kcptun_latest_release} | sed -n '/<strong>kcptun-linux-amd64/p' | cut -d">" -f2 | cut -d "<" -f1` && \
    wget ${kcptun_latest_download}/${kcptun_latest_filename} -O ${KCPTUN_DIR}/${kcptun_latest_filename} && \
    tar xzf ${KCPTUN_DIR}/${kcptun_latest_filename} -C ${KCPTUN_DIR}/ && \
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64 ${KCPTUN_DIR}/${kcptun_latest_filename} && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache /tmp/libsodium

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

