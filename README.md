# 🚀 MTProxy 一键安装脚本

<div align="center">

![MTProxy](https://img.shields.io/badge/MTProxy-Telegram-blue?style=for-the-badge&logo=telegram)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux-orange?style=for-the-badge&logo=linux)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash)

**无需 systemd，一键部署 Telegram MTProxy 代理服务器**

[English](#english) | [中文](#中文)

</div>

---

## 中文

### ✨ 特性

- 🎯 **一键安装** - 单条命令完成全部部署
- 🐳 **无需 Docker** - 直接编译运行，无容器依赖
- ⚡ **无需 systemd** - 适用于容器、VPS、云服务器
- 🔧 **自动配置** - 自动生成密钥和管理脚本
- 🌍 **多系统支持** - Ubuntu/Debian/CentOS/Alpine
- 📱 **即用链接** - 安装完成直接输出可导入的代理链接

### 📋 系统要求

| 系统 | 版本 |
|------|------|
| Ubuntu | 16.04+ |
| Debian | 9+ |
| CentOS | 7+ |
| Alpine | 3.10+ |

### 🚀 快速开始

#### 方式一：一键安装（推荐）

```bash
bash <(curl -sL https://raw.githubusercontent.com/1837620622/mtproxy/main/install.sh)
```

#### 方式二：手动下载运行

```bash
wget https://raw.githubusercontent.com/1837620622/mtproxy/main/install.sh
chmod +x install.sh
./install.sh
```

### 📖 安装流程

```
[1/5] 安装依赖包...      ✓
[2/5] 下载MTProxy源码... ✓
[3/5] 编译MTProxy...     ✓
[4/5] 配置代理...        ✓
[5/5] 启动MTProxy...     ✓
```

### 🎮 管理命令

安装完成后，使用以下命令管理服务：

| 命令 | 说明 |
|------|------|
| `~/mtproxy.sh start` | 启动服务 |
| `~/mtproxy.sh stop` | 停止服务 |
| `~/mtproxy.sh restart` | 重启服务 |
| `~/mtproxy.sh status` | 查看状态 |
| `~/mtproxy.sh link` | 显示代理链接 |
| `~/mtproxy.sh log` | 查看日志 |

### 🔗 使用代理

安装完成后会显示类似以下链接：

```
tg://proxy?server=YOUR_IP&port=443&secret=YOUR_SECRET
```

**使用方法：**
1. 复制完整链接
2. 在 Telegram 中打开该链接
3. 点击"连接"即可使用

### 🔧 配置文件

| 文件 | 说明 |
|------|------|
| `~/mtproxy.conf` | 配置信息（IP、端口、密钥） |
| `~/mtproxy.sh` | 管理脚本 |
| `~/mtproxy.log` | 运行日志 |
| `~/MTProxy/` | 程序目录 |

### ❓ 常见问题

<details>
<summary><b>Q: 端口443被占用怎么办？</b></summary>

编辑 `~/mtproxy.conf`，修改 `PORT=443` 为其他端口（如 `PORT=8443`），然后重启：
```bash
~/mtproxy.sh restart
```
</details>

<details>
<summary><b>Q: 如何更换密钥？</b></summary>

```bash
# 生成新密钥
NEW_SECRET=$(head -c 16 /dev/urandom | xxd -ps)
echo $NEW_SECRET

# 编辑配置文件
nano ~/mtproxy.conf
# 将 SECRET= 后面的值替换为新密钥

# 重启服务
~/mtproxy.sh restart
```
</details>

<details>
<summary><b>Q: 如何卸载？</b></summary>

```bash
~/mtproxy.sh stop
rm -rf ~/MTProxy ~/mtproxy.sh ~/mtproxy.conf ~/mtproxy.log
```
</details>

### 📄 开源协议

本项目基于 [MIT License](LICENSE) 开源。

---

## English

### ✨ Features

- 🎯 **One-Click Install** - Complete deployment with a single command
- 🐳 **No Docker Required** - Direct compilation and execution
- ⚡ **No systemd Required** - Works on containers, VPS, cloud servers
- 🔧 **Auto Configuration** - Automatically generates keys and management scripts
- 🌍 **Multi-OS Support** - Ubuntu/Debian/CentOS/Alpine
- 📱 **Ready-to-Use Link** - Outputs importable proxy link after installation

### 🚀 Quick Start

```bash
bash <(curl -sL https://raw.githubusercontent.com/1837620622/mtproxy/main/install.sh)
```

### 🎮 Management Commands

| Command | Description |
|---------|-------------|
| `~/mtproxy.sh start` | Start service |
| `~/mtproxy.sh stop` | Stop service |
| `~/mtproxy.sh restart` | Restart service |
| `~/mtproxy.sh status` | Check status |
| `~/mtproxy.sh link` | Show proxy link |
| `~/mtproxy.sh log` | View logs |

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star！**

Made with ❤️ by [传康kk](https://github.com/1837620622)

**联系方式：**
- 微信: 1837620622
- 邮箱: 2040168455@qq.com
- 咸鱼/B站: 万能程序员

</div>
