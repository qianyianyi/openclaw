#!/bin/sh

# 确保以 root 身份运行
if [ "$(id -u)" != "0" ]; then
    echo "错误：此脚本需要 root 权限。"
    exit 1
fi

echo "正在获取 FRP 最新版本号..."
FRP_VERSION=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
if [ -z "$FRP_VERSION" ]; then
    FRP_VERSION="0.56.0"
    echo "获取失败，使用默认版本 v$FRP_VERSION"
else
    echo "检测到最新版本: v$FRP_VERSION"
fi

# 检测架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)  FRP_ARCH="amd64" ;;
    aarch64) FRP_ARCH="arm64" ;;
    armv7l)  FRP_ARCH="arm" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

FRP_NAME="frp_${FRP_VERSION}_linux_${FRP_ARCH}"
DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FRP_NAME}.tar.gz"

echo "================================================="
echo "       Alpine FRP 交互式安装与配置脚本 (OpenRC)"
echo "================================================="
echo "请选择你要安装的组件："
echo "1. 安装 FRP 服务端 (frps)"
echo "2. 安装 FRP 客户端 (frpc)"
printf "请输入对应数字 (1/2): "
read INSTALL_TYPE

echo "正在下载并解压 FRP..."
curl -L -o ${FRP_NAME}.tar.gz $DOWNLOAD_URL
tar -zxvf ${FRP_NAME}.tar.gz > /dev/null
mkdir -p /etc/frp

if [ "$INSTALL_TYPE" = "1" ]; then
    # ==================== 安装服务端 ====================
    printf "请输入服务端监听端口 (默认 7000): "
    read BIND_PORT
    BIND_PORT=${BIND_PORT:-7000}
    
    printf "请输入用于认证的 Token 密码 (默认随机生成): "
    read FRP_TOKEN
    FRP_TOKEN=${FRP_TOKEN:-$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)}

    cp ${FRP_NAME}/frps /usr/local/bin/frps
    chmod +x /usr/local/bin/frps

    cat > /etc/frp/frps.toml <<EOF
bindPort = $BIND_PORT

[auth]
method = "token"
token = "$FRP_TOKEN"
EOF

    # 创建 OpenRC 服务
    cat > /etc/init.d/frps <<'EOF'
#!/sbin/openrc-run

name="frps"
description="FRP Server"
command="/usr/local/bin/frps"
command_args="-c /etc/frp/frps.toml"
command_background="yes"
pidfile="/run/${RC_SVCNAME}.pid"

depend() {
    need net
    after firewall
}
EOF
    chmod +x /etc/init.d/frps
    rc-update add frps default
    rc-service frps start

    echo -e "\n✅ FRP 服务端 (frps) 安装并启动成功！"
    echo "监听端口: $BIND_PORT"
    echo "认证 Token: $FRP_TOKEN"
    echo "查看状态: rc-service frps status"

elif [ "$INSTALL_TYPE" = "2" ]; then
    # ==================== 安装客户端 ====================
    printf "请输入 FRP 服务端的 IP 地址: "
    read SERVER_IP
    printf "请输入 FRP 服务端的端口 (默认 7000): "
    read SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-7000}
    printf "请输入服务端的 Token 密码: "
    read FRP_TOKEN

    cp ${FRP_NAME}/frpc /usr/local/bin/frpc
    chmod +x /usr/local/bin/frpc

    cat > /etc/frp/frpc.toml <<EOF
serverAddr = "$SERVER_IP"
serverPort = $SERVER_PORT

[auth]
method = "token"
token = "$FRP_TOKEN"

[[proxies]]
name = "ssh-example"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
EOF

    # 创建 OpenRC 服务
    cat > /etc/init.d/frpc <<'EOF'
#!/sbin/openrc-run

name="frpc"
description="FRP Client"
command="/usr/local/bin/frpc"
command_args="-c /etc/frp/frpc.toml"
command_background="yes"
pidfile="/run/${RC_SVCNAME}.pid"

depend() {
    need net
    after firewall
}
EOF
    chmod +x /etc/init.d/frpc
    rc-update add frpc default
    rc-service frpc start

    echo -e "\n✅ FRP 客户端 (frpc) 安装并启动成功！"
    echo "配置文件: /etc/frp/frpc.toml"
    echo "重启服务: rc-service frpc restart"
    echo "查看状态: rc-service frpc status"

else
    echo "无效的选择。"
fi

# 清理
rm -rf ${FRP_NAME} ${FRP_NAME}.tar.gz
