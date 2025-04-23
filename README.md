# 🛡️ AdGuard 广告拦截规则

**维护者**: 酷安 [@那个谁520](http://www.coolapk.com/u/23966654)

## 📥 规则列表

| 类型             | 链接                                                                                       |
|------------------|------------------------------------------------------------------------------------------|
| adguard黑名单规则       | [black.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/black.txt)          |
| adguard白名单规则       | [white.txt](https://raw.githubusercontent.com/qq5460168/dangchu/main/white.txt)          |
| DNS规则          | [dnslist.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt)        |
| Hosts规则        | [hosts.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt)            |
| Clash规则        | [Clash.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml)          |
| Quantumult X规则 | [qx.list](https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list)                |
| SingBox规则      | [singbox.srs](https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs)        |
| 汇总规则列表     | [all_rules.list](https://raw.githubusercontent.com/qq5460168/AD886/main/all_rules.list)  |

## 🚀 快速使用

### AdGuard Home
1. 进入AdGuard管理界面 → **过滤器** → **DNS黑名单**。
2. 添加以下规则URL，并启用定期更新：
   - [dnslist.txt](https://raw.githubusercontent.com/qq5460168/AD886/main/dnslist.txt)

### Clash Premium
1. 下载并导入 [Clash.yaml](https://raw.githubusercontent.com/qq5460168/AD886/main/Clash.yaml) 配置文件。
2. 重启 Clash 应用以使规则生效。

### Quantumult X
1. 添加规则文件 [qx.list](https://raw.githubusercontent.com/qq5460168/AD886/main/qx.list)。
2. 应用规则并重启 Quantumult X。

### SingBox
1. 使用 [singbox.srs](https://raw.githubusercontent.com/qq5460168/AD886/main/singbox.srs) 文件作为规则配置。
2. 重启 SingBox 应用。

### Hosts文件
```bash
curl -o /etc/hosts https://raw.githubusercontent.com/qq5460168/AD886/main/hosts.txt