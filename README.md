# 🛡️ AdGuard 广告拦截规则

**维护者**: 酷安 [@那个谁520](http://www.coolapk.com/u/23966654)  
**最后更新**: ![](https://img.shields.io/badge/dynamic/json?label=Last%20Update&query=lastupdate&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fqq5460168%2FAD886)

---

## 📖 目录
1. [规则列表](#-规则列表)
2. [快速使用指南](#-快速使用指南)
3. [贡献指南](#-贡献与反馈)
4. [注意事项](#-注意事项)

---

## 📥 规则列表

以下为当前维护的规则文件列表：

| 类型                | 用途描述                          | 直链地址                                                                                     |
|---------------------|----------------------------------|--------------------------------------------------------------------------------------------|
| AdGuard 黑名单规则   | 基础广告域名拦截                   | [black.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/black.txt)            |
| AdGuard 白名单规则   | 解除误拦截域名                     | [white.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/white.txt)            |
| DNS规则             | AdGuard Home 等DNS工具专用         | [dnslist.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt)          |
| Hosts规则           | 系统级Hosts文件                    | [hosts.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt)              |
| Clash规则           | Clash Premium 客户端配置           | [Clash.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml)            |
| Clash Meta规则      | Mihomo内核专用配置                 | [clash_meta.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/clash_meta.yaml)  |
| Quantumult X规则    | Quantumult X 分流规则              | [qx.list](https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list)                  |
| SingBox规则         | SingBox 配置文件                   | [singbox.srs](https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs)          |
| Shadowrocket规则    | Shadowrocket 专用配置              | [Shadowrocket.list](https://raw.githubusercontent.com/qq5460168/AD886/main/Shadowrocket.list) |
| Invizible规则       | Invizible Pro 配置                 | [invizible.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/invizible.txt)      |
| AdClose规则         | AdClose 客户端专用                 | [AdClose.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/AdClose.txt)          |

---

## 🚀 快速使用指南

### AdGuard Home
1. 进入管理界面 → **过滤器** → **DNS 黑名单**
2. 添加规则URL并启用自动更新：
   ```bash
   https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt

   Clash Premium
   
# 配置订阅链接
proxy-groups:
  - name: 🛡️ ADGuard
    type: select
    proxies:
      - DIRECT
    url: 'https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml'
    interval: 86400

Quantumult X
在[资源]页面添加规则订阅：
https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list
启用「资源解析器」并重启服务

SingBox
{
  "route": {
    "rules": [
      {
        "type": "remote",
        "url": "https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs",
        "update_interval": "24h"
      }
    ]
  }
}

Hosts 文件
# Linux/macOS
sudo curl -o /etc/hosts https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt

# Windows (管理员权限运行)
curl -o C:\Windows\System32\drivers\etc\hosts https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt

其他客户端
客户端	操作指引
Shadowrocket	设置 → 服务器 → 添加订阅链接
Invizible	Rules → Import from URL → 粘贴规则链接
AdClose	过滤器 → 远程规则 → 添加.txt规则链接




