# 🛡️ AdGuard 广告拦截规则

本项目提供一系列高效的广告拦截规则，适用于多种工具（如 AdGuard Home、Clash Premium 等），帮助用户在各种设备上屏蔽广告，提升浏览体验。

**维护者**: 酷安 [@那个谁520](http://www.coolapk.com/u/23966654)

---

## 📖 目录

1. [规则列表](#规则列表)
2. [快速使用指南](#快速使用指南)
   - AdGuard Home
   - Clash Premium
   - Clash Meta (Mihomo)
   - Quantumult X
   - SingBox
   - Hosts 文件
3. [贡献与反馈](#贡献与反馈)
4. [许可证](#许可证)

---

## 📥 规则列表

以下是提供的广告拦截规则文件及其用途：

| **类型**              | **用途**                                | **链接**                                                                                     |
|-----------------------|----------------------------------------|--------------------------------------------------------------------------------------------|
| **AdGuard 黑名单规则** | 拦截大部分广告域名                       | [black.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/black.txt)            |
| **AdGuard 白名单规则** | 允许部分误拦截的域名                     | [white.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/white.txt)            |
| **DNS规则**            | 用于 AdGuard Home 或其他支持 DNS 规则的工具 | [dnslist.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt)          |
| **Hosts规则**          | 可直接用于系统 Hosts 文件                | [hosts.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt)              |
| **Clash规则**          | Clash Premium 配置                      | [Clash.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml)            |
| **Clash Meta规则**     | Clash Meta (Mihomo) 配置，支持高级规则匹配 | [ClashMeta.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/ClashMeta.yaml)    |
| **Quantumult X规则**   | Quantumult X 配置                       | [qx.list](https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list)                  |
| **SingBox规则**        | SingBox 配置                            | [singbox.srs](https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs)          |

---

## 🚀 快速使用指南

### 1. AdGuard Home
1. 打开 AdGuard Home 管理界面 → **过滤器** → **DNS 黑名单**。
2. 添加以下规则 URL，并启用定期更新：
   - [dnslist.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt)

### 2. Clash Premium
1. 下载并导入以下文件作为配置：
   - [Clash.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml)
2. 打开 Clash Premium 应用并重启以生效。

### 3. Clash Meta (Mihomo)
1. 下载并导入以下文件作为配置：
   - [ClashMeta.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/ClashMeta.yaml)
2. 打开 Clash Meta 应用并导入配置文件。
3. 启用规则，重启 Clash Meta，以生效配置。

### 4. Quantumult X
1. 添加规则文件：
   - [qx.list](https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list)
2. 应用规则并重启 Quantumult X。

### 5. SingBox
1. 下载配置文件：
   - [singbox.srs](https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs)
2. 使用该文件作为配置，重启 SingBox。

### 6. Hosts 文件
运行以下命令以更新系统 Hosts 文件：
```bash
curl -o /etc/hosts https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt


