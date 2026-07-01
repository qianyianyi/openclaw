#!/bin/sh
set -e

# 配置项，按需修改
INSTALL_DIR="/opt/komari"
LISTEN_ADDR="0.0.0.0:25774"
ADMIN_USER="AIshy"
ADMIN_PASS="AIshy980925."
PORT="25774"

# 更新源+安装依赖
apk update
apk add --no-cache wget curl tar

# 判断CPU架构
ARCH=$(uname -m)
case "$ARCH" in
x86_64)
    BIN_ARCH="amd64"
    ;;
aarch64)
    BIN_ARCH="arm64"
    ;;
armv7l|armhf)
    echo "暂未适配armv7，退出"
    exit 1
    ;;
*)
    echo "不支持架构: $ARCH"
    exit 1
    ;;
esac

# 获取最新版本下载地址
API_URL="https://raw.githubusercontent.com/komari-monitor/komari/main/install-komari.sh"
DOWNLOAD_URL=$(curl -s $API_URL | grep -o "https.*linux-$BIN_ARCH.tar.gz\"" | sed 's/"$//')

if [ -z "$DOWNLOAD_URL" ]; then
    echo "获取下载链接失败，请手动下载二进制"
    exit 1
fi

# 创建目录并下载
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR
echo "开始下载: $DOWNLOAD_URL"
wget -q $DOWNLOAD_URL -O komari.tar.gz
tar -zxf komari.tar.gz
rm -f komari.tar.gz
chmod +x komari

# 写入OpenRC启动脚本
cat > /etc/init.d/komari <<EOF
#!/sbin/openrc-run
name="komari"
command="$INSTALL_DIR/komari"
command_args="server -l $LISTEN_ADDR"
command_background="yes"
pidfile="/run/\${name}.pid"
directory="$INSTALL_DIR"

export ADMIN_USERNAME=$ADMIN_USER
export ADMIN_PASSWORD=$ADMIN_PASS

depend() {
    need net
    after firewall
}
EOF

chmod +x /etc/init.d/komari

# 设置开机自启
rc-update add komari default

# 放行端口 nftables(默认) / iptables 兼容
if nft list ruleset >/dev/null 2>&1; then
    nft add rule inet filter input tcp dport $PORT accept
else
    iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
    apk add --no-cache iptables-save
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules-save
fi

# 启动服务
rc-service komari restart

echo "============================================="
echo "Komari 部署完成"
echo "安装目录: $INSTALL_DIR"
echo "访问地址: http://本机IP:$PORT"
echo "管理员账号: $ADMIN_USER"
echo "管理员密码: $ADMIN_PASS"
echo "数据目录: $INSTALL_DIR/data"
echo "启停命令:"
echo "  rc-service komari start|stop|restart|status"
echo "============================================="
