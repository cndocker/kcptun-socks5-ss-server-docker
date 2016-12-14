[![](https://images.microbadger.com/badges/version/cndocker/kcptun-socks5-ss-server.svg)](http://microbadger.com/images/cndocker/kcptun-socks5-ss-server "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/image/cndocker/kcptun-socks5-ss-server.svg)](http://microbadger.com/images/cndocker/kcptun-socks5-ss-server "Get your own version badge on microbadger.com")

# 一、Docker Kcptun for socks5 & Kcptun for Shadowsocks-libev 服务端
##1、介绍
基于Dockerfile文件编译出一个kcptun for socks5&Shadowsocks-libev服务端的容器镜像。
##2、版本
[cndocker/kcptun-socks5-ss-server:latest](https://hub.docker.com/r/cndocker/kcptun-socks5-ss-server/)

[kcptun 20161111](https://github.com/xtaci/kcptun/releases/latest)

[shadowsocks-libev 2.5.6](https://github.com/shadowsocks/shadowsocks-libev/releases/latest)
##3、问题
如何安装Docker

1)官网安装地址
```bash
curl -Lk https://get.docker.com/ | sh
```
2)阿里云安装地址
```bash
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
```
RHEL、CentOS、Fedora的用户可以使用`setenforce 0`来禁用selinux以达到解决一些问题

如果你已经禁用了selinux并且使用的是最新版的Docker。

当你在issue 提交问题的时候请注意提供一下信息:
- 宿主机的发行版和版本号.
- 使用 `docker version` 命令来给出Docker版本信息.
- 使用 `docker info` 命令来给出进一步信息.
- 提供 `docker run` 命令的详情 (注意打码你的隐私信息).

# 二、安装
##1、基于docker的cndocker/kcptun-socks5-ss-server服务端安装方法
直接使用我们在 [Dockerhub](https://hub.docker.com/r/cndocker/kcptun-socks5-ss-server/) 上通过自动构建生成的镜像是最为推荐的方式

```bash
docker pull cndocker/kcptun-socks5-ss-server:latest
```
##2、下载镜像导入
从我们的项目中下载docker images后导入，镜像下载地址：
```bash
wget --no-check-certificate https://github.com/cndocker/kcptun-socks5-ss-server-docker/raw/master/images/docker-kcptun-socks5-ss-server.tar
```
镜像导入命令
```bash
docker load < docker-kcptun-socks5-ss-server.tar
```

# 三、使用
##启动命令
```bash
docker run -ti --name=kcptun-socks5-ss-server \
-p 8388:8388 \
-p 8388:8388/udp \
-p 34567:34567/udp \
-p 45678:45678/udp \
-e RUNENV=kcptunsocks-kcptunss \
-e SS_SERVER_ADDR=0.0.0.0 \
-e SS_SERVER_PORT=8388 \
-e SS_PASSWORD=password \
-e SS_METHOD=aes-256-cfb \
-e SS_DNS_ADDR=8.8.8.8 \
-e SS_UDP=true \
-e SS_ONETIME_AUTH=true \
-e SS_FAST_OPEN=true \
-e KCPTUN_LISTEN=45678 \
-e KCPTUN_SS_LISTEN=34567 \
-e KCPTUN_SOCKS5_PORT=12948 \
-e KCPTUN_KEY=password \
-e KCPTUN_CRYPT=aes \
-e KCPTUN_MODE=fast2 \
-e KCPTUN_MTU=1350 \
-e KCPTUN_SNDWND=1024 \
-e KCPTUN_RCVWND=1024 \
-e KCPTUN_NOCOMP=false \
cndocker/kcptun-socks5-ss-server:latest
```
---
##变量说明（变量名区分大小写）
| 变量名 | 默认值  | 描述 |
| :----------------- |:--------------------:| :---------------------------------- |
| RUNENV             | kcptunsocks-kcptunss | 运行模式（见备注1）：kcptunsocks-kcptunss, kcptunsocks, kcptunss, ss |
| SS_SERVER_ADDR     | 0.0.0.0              | 提供服务的IP地址，建议使用默认的0.0.0.0  |
| SS_SERVER_PORT     | 8388                 | SS提供服务的端口，TCP和UDP协议。        |
| SS_PASSWORD        | password             | 服务密码                              |
| SS_METHOD          | aes-256-cfb          | 加密方式，可选参数：table, rc4, rc4-md5, aes-128-cfb, aes-192-cfb, aes-256-cfb, bf-cfb, camellia-128-cfb, camellia-192-cfb, camellia-256-cfb, cast5-cfb, des-cfb, idea-cfb, rc2-cfb, seed-cfb, salsa20, chacha20 and chacha20-ietf |
| SS_TIMEOUT         | 600                  | 连接超时时间                          |
| SS_DNS_ADDR        | 8.8.8.8              | SS服务器的DNS地址                     |
| SS_UDP             | true                 | 开启SS服务器 UDP relay                |
| SS_ONETIME_AUTH    | true                 | 开启SS服务器 onetime authentication.  |
| SS_FAST_OPEN       | true                 | 开启SS服务器  TCP fast open.          |
| KCPTUN_LISTEN      | 45678                | kcptunsocks模式提供服务的端口，UDP协议   |
| KCPTUN_SS_LISTEN   | 34567                | kcptunss模式提供服务的端口，UDP协议           |
| KCPTUN_SOCKS5_PORT | 12948                | socks5透明代理端口，不需要对外开放。      |
| KCPTUN_KEY         | password             | 服务密码                              |
| KCPTUN_CRYPT       | aes                  | 加密方式，可选参数：aes, aes-128, aes-192, salsa20, blowfish, twofish, cast5, 3des, tea, xtea, xor |
| KCPTUN_MODE        | fast2                | 加速模式，可选参数：fast3, fast2, fast, normal |
| KCPTUN_MTU         | 1350                 | MTU值，建议范围：900~1400              |
| KCPTUN_SNDWND      | 1024                 | 服务器端发送参数，对应客户端rcvwnd       |
| KCPTUN_RCVWND      | 1024                 | 服务器端接收参数，对应客户端sndwnd        |
| KCPTUN_DATASHARD   | 10                   | 数据块，需与客户端保持一致              |
| KCPTUN_PARITYSHARD | 3                    | 校验块，需与客户端保持一致          |
| KCPTUN_DSCP        | 0                    | 数据包优先级                          |
| KCPTUN_NOCOMP      | false                | 是否开启压缩，值为false时开启压缩，为true时禁用压缩，需与客户端保持一致。 |
---
###备注1：运行模式
    * kcptunsocks-kcptunss：同时提供kcptun & socks5（路由器kcptun插件）与kcptun & ss(手机ss客户端)服务，kcptun & socks5服务的对应端口是“KCPTUN_LISTEN”，kcptun & ss服务的SS对应端口“SS_SERVER_PORT”、kcp端口对应“KCPTUN_SS_LISTEN”。
    * kcptunsocks：提供kcptun & socks5（路由器kcptun插件）服务，kcptun & socks5服务的对应端口是“KCPTUN_LISTEN”。
    * kcptunss：提供kcptun & ss(手机ss客户端)服务，SS对应端口“SS_SERVER_PORT”、kcp端口对应“KCPTUN_SS_LISTEN”。
    * ss：提供shadowsocks-libev服务，SS对应端口“SS_SERVER_PORT”。
###

###备注2：手机客户端kcp参数
    --crypt ${KCPTUN_CRYPT} --key ${KCPTUN_KEY} --mtu ${KCPTUN_MTU} --sndwnd ${KCPTUN_RCVWND} --rcvwnd ${KCPTUN_SNDWND} --mode ${KCPTUN_MODE}
###

###备注3：带宽计算方法
    简单的计算带宽方法，以服务器发送带宽为例，其他类似：
    服务器发送带宽=SNDWND*MTU*8/1024/1024=1024*1350*8/1024/1024≈10M
###

