# v2ray

支持vmess aead, trojan, ss

# 联系我

直接提issus吧或者
https://t.me/v2ray_1234

# 提示
自行解压libvpn_a.zip放入工程中

# 爱好
这个项目纯属技术探究，用于任何作用都与本人无关，各位自行斟酌

# 配置
```yaml
---
port: 8888
socks-port: 8889
mixed-port: 8899

tun:
  enable: false
  device-id: "dev://utun1989"

mode: rule
log-level: debug

proxy-groups:
  - name: "relay"
    type: relay
    proxies:
      - "plain-vmess"
      - "ws-vmess"
      - "auto"
      - "fallback-auto"
      - "load-balance"
      - "select"
      - DIRECT
  
  - name: "relay-one"
    type: relay
    use:
      - "file-provider"

  - name: "auto"
    type: url-test
    use:
      - "file-provider"
    proxies:
      - DIRECT
    url: "http://www.gstatic.com/generate_204"
    interval: 300

  - name: "fallback-auto"
    type: fallback
    use:
      - "file-provider"
    proxies:
      - DIRECT
    url: "http://www.gstatic.com/generate_204"
    interval: 300

  - name: "load-balance"
    type: load-balance
    use:
      - "file-provider"
    proxies:
      - DIRECT
    strategy: round-robin
    url: "http://www.gstatic.com/generate_204"
    interval: 300

  - name: select
    type: select
    use:
      - "file-provider"

  - name: test 🌏
    type: select
    use:
      - "file-provider"
    proxies:
      - DIRECT

proxies:
  - name: plain-vmess
    type: vmess
    server: 10.0.0.13
    port: 16823
    uuid: b831381d-6324-4d53-ad4f-8cda48b30811
    alterId: 0
    cipher: auto
    udp: true
    skip-cert-verify: true

  - name: ws-vmess
    type: vmess
    server: 10.0.0.13
    port: 16824
    uuid: b831381d-6324-4d53-ad4f-8cda48b30811
    alterId: 0
    cipher: auto
    udp: true
    skip-cert-verify: true
    network: ws
    ws-opts:
      path: /api/v3/download.getFile
      headers:
        Host: www.amazon.com

  - name: tls-vmess
    type: vmess
    server: 10.0.0.13
    port: 8443
    uuid: 23ad6b10-8d1a-40f7-8ad0-e3e35cd38297
    alterId: 0
    cipher: auto
    udp: true
    skip-cert-verify: true
    tls: true

  - name: h2-vmess
    type: vmess
    server: 10.0.0.13
    port: 8444
    uuid: b831381d-6324-4d53-ad4f-8cda48b30811
    alterId: 0
    cipher: auto
    udp: true
    skip-cert-verify: true
    tls: true
    network: h2
    h2-opts:
      path: /ray

  - name: grpc-vmess
    type: vmess
    server: 10.0.0.13
    port: 19443
    uuid: b831381d-6324-4d53-ad4f-8cda48b30811
    alterId: 0
    cipher: auto
    udp: true
    skip-cert-verify: true
    tls: true
    network: grpc
    grpc-opts:
      grpc-service-name: abc

  - name: "ss-simple"
    type: ss
    server: 10.0.0.13
    port: 8388
    cipher: aes-256-gcm
    password: "password"
    udp: true

  - name: "trojan"
    type: trojan
    server: 10.0.0.13
    port: 9443
    password: password1
    udp: true
    # sni: example.com # aka server name
    alpn:
      - h2
      - http/1.1
    skip-cert-verify: true

  - name: "trojan-grpc"
    type: trojan
    server: 10.0.0.13
    port: 19443
    password: password1
    udp: true
    # sni: example.com # aka server name
    alpn:
      - h2
    skip-cert-verify: true
    network: grpc
    grpc-opts:
      grpc-service-name: def

proxy-providers:
  file-provider:
    type: file
    path: ./ss.yaml
    interval: 300
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300

rule-providers:
  file-provider:
    type: file
    path: ./rule-set.yaml
    interval: 300
    behavior: domain

rules:
  - DOMAIN,google.com,relay
  - DOMAIN-KEYWORD,httpbin,trojan-grpc
  - DOMAIN,ipinfo.io,trojan-grpc
#  - RULE-SET,file-provider,trojan
  - GEOIP,CN,relay
  - DOMAIN-SUFFIX,facebook.com,REJECT
  - DOMAIN-KEYWORD,google,grpc-vmess
  - DOMAIN,google.com,select
  - SRC-IP-CIDR,192.168.1.1/24,DIRECT
  - GEOIP,CN,DIRECT
  - IP-CIDR,10.0.0.11/32,select
  - DST-PORT,53,trojan
  - SRC-PORT,7777,DIRECT
  - MATCH, DIRECT
...
```

# 请我喝杯咖啡

trc20: TH85QavuDrp7v3otYXVd6MRr1CfJ9DPKDQ

BEP20: 0x566630Dd2b4F15C91659e3e911DF217751727486
