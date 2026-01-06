#!/bin/bash
# ============================================
# MTProxy 一键安装脚本 (无systemd版本)
# 适用于: Ubuntu 16.04+ / Debian 9+ / CentOS 7+
# 项目地址: https://github.com/1837620622/mtproxy
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     ███╗   ███╗████████╗██████╗ ██████╗  ██████╗ ██╗  ██╗  ║"
echo "║     ████╗ ████║╚══██╔══╝██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝  ║"
echo "║     ██╔████╔██║   ██║   ██████╔╝██████╔╝██║   ██║ ╚███╔╝   ║"
echo "║     ██║╚██╔╝██║   ██║   ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ║"
echo "║     ██║ ╚═╝ ██║   ██║   ██║     ██║  ██║╚██████╔╝██╔╝ ██╗  ║"
echo "║     ╚═╝     ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝  ║"
echo "║                                                            ║"
echo "║              Telegram MTProxy 一键安装脚本                 ║"
echo "║                   无需systemd版本                          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# 检测系统类型
detect_os() {
    if [ -f /etc/debian_version ]; then
        OS="debian"
        PKG_UPDATE="apt-get update"
        PKG_INSTALL="apt-get install -y"
        PACKAGES="git curl build-essential libssl-dev zlib1g-dev xxd"
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
        PKG_UPDATE="yum update -y"
        PKG_INSTALL="yum install -y"
        PACKAGES="git curl gcc make openssl-devel zlib-devel vim-common"
    elif [ -f /etc/alpine-release ]; then
        OS="alpine"
        PKG_UPDATE="apk update"
        PKG_INSTALL="apk add"
        PACKAGES="git curl build-base linux-headers openssl-dev zlib-dev"
    else
        echo -e "${RED}[错误] 不支持的操作系统${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] 检测到系统: ${OS}${NC}"
}

# 安装依赖
install_deps() {
    echo -e "${YELLOW}[1/5] 安装依赖包...${NC}"
    if [ "$EUID" -eq 0 ]; then
        $PKG_UPDATE > /dev/null 2>&1 || true
        $PKG_INSTALL $PACKAGES > /dev/null 2>&1
    else
        sudo $PKG_UPDATE > /dev/null 2>&1 || true
        sudo $PKG_INSTALL $PACKAGES > /dev/null 2>&1
    fi
    echo -e "${GREEN}      ✓ 依赖安装完成${NC}"
}

# 下载源码
download_source() {
    echo -e "${YELLOW}[2/5] 下载MTProxy源码...${NC}"
    cd ~
    rm -rf MTProxy 2>/dev/null || true
    git clone https://github.com/TelegramMessenger/MTProxy.git > /dev/null 2>&1
    echo -e "${GREEN}      ✓ 源码下载完成${NC}"
}

# 编译
compile() {
    echo -e "${YELLOW}[3/5] 编译MTProxy...${NC}"
    cd ~/MTProxy
    make > /dev/null 2>&1
    echo -e "${GREEN}      ✓ 编译完成${NC}"
}

# 配置
configure() {
    echo -e "${YELLOW}[4/5] 配置代理...${NC}"
    cd ~/MTProxy/objs/bin
    
    # 下载配置文件
    curl -s https://core.telegram.org/getProxySecret -o proxy-secret
    curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
    
    # 生成密钥
    SECRET=$(head -c 16 /dev/urandom | xxd -ps)
    
    # 获取公网IP
    IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ip.sb 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)
    
    # 保存配置
    echo "SECRET=${SECRET}" > ~/mtproxy.conf
    echo "IP=${IP}" >> ~/mtproxy.conf
    echo "PORT=443" >> ~/mtproxy.conf
    
    # 创建管理脚本
    cat > ~/mtproxy.sh << 'SCRIPT'
#!/bin/bash
source ~/mtproxy.conf

case "$1" in
    start)
        cd ~/MTProxy/objs/bin
        curl -s https://core.telegram.org/getProxySecret -o proxy-secret
        curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
        nohup ./mtproto-proxy -u nobody -p 8888 -H ${PORT} -S ${SECRET} --aes-pwd proxy-secret proxy-multi.conf -M 1 > ~/mtproxy.log 2>&1 &
        sleep 1
        if pgrep -x "mtproto-proxy" > /dev/null; then
            echo "MTProxy 启动成功"
        else
            echo "MTProxy 启动失败"
        fi
        ;;
    stop)
        pkill mtproto-proxy 2>/dev/null && echo "MTProxy 已停止" || echo "MTProxy 未运行"
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        if pgrep -x "mtproto-proxy" > /dev/null; then
            echo "MTProxy 运行中"
            pgrep -a mtproto
        else
            echo "MTProxy 未运行"
        fi
        ;;
    link)
        echo ""
        echo "tg://proxy?server=${IP}&port=${PORT}&secret=${SECRET}"
        echo ""
        ;;
    log)
        tail -f ~/mtproxy.log
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|link|log}"
        exit 1
        ;;
esac
SCRIPT
    chmod +x ~/mtproxy.sh
    
    echo -e "${GREEN}      ✓ 配置完成${NC}"
}

# 启动服务
start_service() {
    echo -e "${YELLOW}[5/5] 启动MTProxy...${NC}"
    cd ~/MTProxy/objs/bin
    source ~/mtproxy.conf
    nohup ./mtproto-proxy -u nobody -p 8888 -H 443 -S ${SECRET} --aes-pwd proxy-secret proxy-multi.conf -M 1 > ~/mtproxy.log 2>&1 &
    sleep 2
    
    if pgrep -x "mtproto-proxy" > /dev/null; then
        echo -e "${GREEN}      ✓ 启动成功${NC}"
    else
        echo -e "${RED}      ✗ 启动失败，请查看日志: ~/mtproxy.log${NC}"
        exit 1
    fi
}

# 显示结果
show_result() {
    source ~/mtproxy.conf
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}              ${GREEN}MTProxy 安装成功!${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC} ${YELLOW}服务器信息${NC}                                                 ${PURPLE}│${NC}"
    echo -e "${PURPLE}├──────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${PURPLE}│${NC}   IP地址:  ${GREEN}${IP}${NC}"
    echo -e "${PURPLE}│${NC}   端口:    ${GREEN}443${NC}"
    echo -e "${PURPLE}│${NC}   密钥:    ${GREEN}${SECRET}${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${BLUE}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${YELLOW}Telegram代理链接 (点击直接导入)${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├──────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}   ${GREEN}tg://proxy?server=${IP}&port=443&secret=${SECRET}${NC}"
    echo -e "${BLUE}│${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}管理命令${NC}                                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}   启动:    ${GREEN}~/mtproxy.sh start${NC}"
    echo -e "${CYAN}│${NC}   停止:    ${GREEN}~/mtproxy.sh stop${NC}"
    echo -e "${CYAN}│${NC}   重启:    ${GREEN}~/mtproxy.sh restart${NC}"
    echo -e "${CYAN}│${NC}   状态:    ${GREEN}~/mtproxy.sh status${NC}"
    echo -e "${CYAN}│${NC}   链接:    ${GREEN}~/mtproxy.sh link${NC}"
    echo -e "${CYAN}│${NC}   日志:    ${GREEN}~/mtproxy.sh log${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# 主流程
main() {
    detect_os
    install_deps
    download_source
    compile
    configure
    start_service
    show_result
}

main
