#!/bin/bash
#########################################################################
# File Name: kcptun-socks5-ss-server.sh
# Version:1.0.20160915
# Created Time: 2016-09-15
#########################################################################

set -e
RUNENV=${RUNENV:-kcptunsocks-kcptunss}                        #"RUNENV": kcptunsocks-kcptunss, kcptunsocks, kcptunss, ss
KCPTUN_CONF="/usr/local/conf/kcptun_config.json"
KCPTUN_SS_CONF="/usr/local/conf/kcptun_ss_config.json"
SS_CONF="/usr/local/conf/ss_config.json"
# ======= SS CONFIG ======
SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0}                     #"server": "0.0.0.0",
SS_SERVER_PORT=${SS_SERVER_PORT:-8388}                        #"server_port": 8388,
SS_PASSWORD=${SS_PASSWORD:-password}                          #"password":"password",
SS_METHOD=${SS_METHOD:-aes-256-cfb}                           #"method":"aes-256-cfb",
SS_TIMEOUT=${SS_TIMEOUT:-600}                                 #"timeout":600,
SS_DNS_ADDR=${SS_DNS_ADDR:-8.8.8.8}                           #-d "8.8.8.8",
SS_UDP=${SS_UDP:-true}                                        #-u support,
SS_ONETIME_AUTH=${SS_ONETIME_AUTH:-true}                      #-A support,
SS_FAST_OPEN=${SS_FAST_OPEN:-true}                            #--fast-open support,
# ======= KCPTUN CONFIG ======
KCPTUN_LISTEN=${KCPTUN_LISTEN:-45678}                         #"listen": ":45678",
KCPTUN_SS_LISTEN=${KCPTUN_SS_LISTEN:-34567}                   #"listen": ":45678", kcptun for ss listen port
KCPTUN_SOCKS5_PORT=${KCPTUN_SOCKS5_PORT:-12948}               #"socks_port": 12948,
KCPTUN_KEY=${KCPTUN_KEY:-password}                            #"key": "password",
KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes}                             #"crypt": "aes",
KCPTUN_MODE=${KCPTUN_MODE:-fast2}                             #"mode": "fast2",
KCPTUN_MTU=${KCPTUN_MTU:-1350}                                #"mtu": 1350,
KCPTUN_SNDWND=${KCPTUN_SNDWND:-1024}                          #"sndwnd": 1024,
KCPTUN_RCVWND=${KCPTUN_RCVWND:-1024}                          #"rcvwnd": 1024,
KCPTUN_NOCOMP=${KCPTUN_NOCOMP:-false}                         #"nocomp": false

[ ! -f ${SS_CONF} ] && cat > ${SS_CONF}<<-EOF
{
    "server":"${SS_SERVER_ADDR}",
    "server_port":${SS_SERVER_PORT},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${SS_PASSWORD}",
    "timeout":${SS_TIMEOUT},
    "method":"${SS_METHOD}"
}
EOF
if [[ "${SS_UDP}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    SS_UDP_FLAG="-u "
else
    SS_UDP_FLAG=""
fi
if [[ "${SS_ONETIME_AUTH}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    SS_ONETIME_AUTH_FLAG="-A "
else
    SS_ONETIME_AUTH_FLAG=""
fi
if [[ "${SS_FAST_OPEN}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    SS_FAST_OPEN_FLAG="--fast-open"
else
    SS_FAST_OPEN_FLAG=""
fi

[ ! -f ${KCPTUN_CONF} ] && cat > ${KCPTUN_CONF}<<-EOF
{
    "listen": ":${KCPTUN_LISTEN}",
    "target": "127.0.0.1:${KCPTUN_SOCKS5_PORT}",
    "key": "${KCPTUN_KEY}",
    "crypt": "${KCPTUN_CRYPT}",
    "mode": "${KCPTUN_MODE}",
    "mtu": ${KCPTUN_MTU},
    "sndwnd": ${KCPTUN_SNDWND},
    "rcvwnd": ${KCPTUN_RCVWND},
    "nocomp": false
}
EOF
[ ! -f ${KCPTUN_SS_CONF} ] && cat > ${KCPTUN_SS_CONF}<<-EOF
{
    "listen": ":${KCPTUN_SS_LISTEN}",
    "target": "127.0.0.1:${SS_SERVER_PORT}",
    "key": "${KCPTUN_KEY}",
    "crypt": "${KCPTUN_CRYPT}",
    "mode": "${KCPTUN_MODE}",
    "mtu": ${KCPTUN_MTU},
    "sndwnd": ${KCPTUN_SNDWND},
    "rcvwnd": ${KCPTUN_RCVWND},
    "nocomp": false
}
EOF

kcptun_nocomp_flag=""
if [[ "${KCPTUN_NOCOMP}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Yy]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
    sed -ri "s/(\"nocomp\":).*/\1 true/" ${KCPTUN_CONF}
    kcptun_nocomp_flag=" --nocomp"
fi

echo "+---------------------------------------------------------+"
echo "|   Manager for Kcptun-Socks5 & Kcptun-Shadowsocks-libev  |"
echo "+---------------------------------------------------------+"
echo "|     Images: cndocker/kcptun-socks5-ss-server:latest     |"
echo "+---------------------------------------------------------+"
echo "|         Intro: https://github.com/cndocker              |"
echo "+---------------------------------------------------------+"
echo ""
# kcptunsocks-kcptunss
if [[ "${RUNENV}" =~ ^[Kk][Cc][Pp][Tt][Uu][Nn][Ss][Oo][Cc][Kk][Ss]-[Kk][Cc][Pp][Tt][Uu][Nn][Ss][Ss]$ ]]; then
    echo "Starting Shadowsocks-libev..."
    nohup ss-server -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG} >/dev/null 2>&1 &
    sleep 0.3
    echo "ss-server (pid `pidof ss-server`)is running."
    netstat -ntlup | grep ss-server
    echo "Starting Kcptun for Shadowsocks-libev..."
    nohup kcp-server -c ${KCPTUN_SS_CONF}  >/dev/null 2>&1 &
    sleep 0.3
    echo "kcptun for Shadowsocks-libev (pid `pidof kcp-server`)is running."
    netstat -ntlup | grep kcp-server
    echo "+---------------------------------------------------------+"
    echo "KCP Port     : ${KCPTUN_SS_LISTEN}"
    echo "KCP Parameter: --crypt ${KCPTUN_CRYPT} --key ${KCPTUN_KEY} --mtu ${KCPTUN_MTU} --sndwnd ${KCPTUN_RCVWND} --rcvwnd ${KCPTUN_SNDWND} --mode ${KCPTUN_MODE}${kcptun_nocomp_flag}"
    echo "+---------------------------------------------------------+"
    echo "Starting socks5..."
    nohup socks5 127.0.0.1:${KCPTUN_SOCKS5_PORT}  >/dev/null 2>&1 &
    sleep 0.3
    echo "Socks5 (pid `pidof socks5`)is running."
    netstat -ntlup | grep socks5
    echo "Starting Kcptun for socks5..."
    kcp-server -v
    exec "kcp-server" -c ${KCPTUN_CONF}
# kcptunsocks
elif [[ "${RUNENV}" =~ ^[Kk][Cc][Pp][Tt][Uu][Nn][Ss][Oo][Cc][Kk][Ss]$ ]]; then
    echo "Starting socks5..."
    nohup socks5 127.0.0.1:${KCPTUN_SOCKS5_PORT}  >/dev/null 2>&1 &
    sleep 0.3
    echo "Socks5 (pid `pidof socks5`)is running."
    netstat -ntlup | grep socks5
    echo "Starting kcptun for socks5..."
    kcp-server -v
    exec "kcp-server" -c ${KCPTUN_CONF}
# kcptunss
elif [[ "${RUNENV}" =~ ^[Kk][Cc][Pp][Tt][Uu][Nn][Ss][Ss]$ ]]; then
    echo "Starting Shadowsocks-libev..."
    nohup ss-server -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG} >/dev/null 2>&1 &
    sleep 0.3
    echo "ss-server (pid `pidof ss-server`)is running."
    netstat -ntlup | grep ss-server
    echo "Starting Kcptun for Shadowsocks-libev..."
    kcp-server -v
    echo "+---------------------------------------------------------+"
    echo "KCP Port     : ${KCPTUN_SS_LISTEN}"
    echo "KCP Parameter: --crypt ${KCPTUN_CRYPT} --key ${KCPTUN_KEY} --mtu ${KCPTUN_MTU} --sndwnd ${KCPTUN_RCVWND} --rcvwnd ${KCPTUN_SNDWND} --mode ${KCPTUN_MODE}${kcptun_nocomp_flag}"
    echo "+---------------------------------------------------------+"
    exec "kcp-server" -c ${KCPTUN_SS_CONF}
# ss
elif [[ "${RUNENV}" =~ ^[Ss][Ss]$ ]]; then
    echo "Starting Shadowsocks-libev..."
    exec "ss-server" -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG}
else
    echo "RUNENV is ${RUNENV} setting error, start failed!"
fi

