#!/bin/sh
set -e

INSTALL_DIR="/opt/komari"
LISTEN_ADDR="0.0.0.0:25774"
ADMIN_USER="AIshy"
ADMIN_PASS="AIshy980925."
PORT="25774"

apk update
apk add --no-cache wget curl tar

ARCH=$(uname -m)
case "$ARCH" in
x86_64) BIN_ARCH="amd64" ;;
aarch64) BIN_ARCH="arm64" ;;
*) echo "不支持架构 $ARCH"; exit 1 ;;
esac

# 使用 ghproxy 加速 GitHub API
API_URL="https://ghproxy.net/https://api.github.com/repos/komari-monitor/komari/releases/latest"
DOWNLOAD_RAW=$(curl -s --connect-timeout 15 "$API_URL" | grep -o "https.*linux-$BIN_ARCH.tar.gz\"" | sed 's/"$//')

if [ -z "$DOWNLOAD_RAW" ]; then
    echo "API获取失败，改用固定最新版v1.1.9下载"
    DOWNLOAD_RAW="https://github.com/komari-monitor/komari/releases/download/v1.1.9/komari-linux-$BIN_ARCH.tar.gz"
fi
DOWNLOAD_URL="https://ghproxy.net/$DOWNLOAD_RAW"

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR
echo "下载: $DOWNLOAD_URL"
wget -q --timeout=20 "$DOWNLOAD_URL" -O komari.tar.gz
tar -zxf komari.tar.gz
rm -f komari.tar.gz
chmod +x komari

# OpenRC 启动脚本
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
rc-update add komari default

# 放行端口
if nft list ruleset >/dev/null 2>&1; then
    nft add rule inet filter input tcp dport $PORT accept
else
    iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
    apk add --no-cache iptables-save
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules-save
fi

rc-service komari restart

echo "========================================"
echo "部署完成"
echo "访问地址: http://$(hostname -i):$PORT"
echo "账号: $ADMIN_USER"
echo "密码: $ADMIN_PASS"
echo "启停: rc-service komari start|stop|restart|status"
echo "数据目录: $INSTALL_DIR/data"
echo "========================================"
