#!/bin/sh

set -e

# 可自定义参数
FRP_VERSION="0.58.0"
INSTALL_DIR="/opt/frps"
BIND_PORT=7000
DASHBOARD_PORT=7500
TOKEN="AIshy980925"

echo "==> 安装依赖"
apk add --no-cache wget tar

echo "==> 创建目录"
mkdir -p ${INSTALL_DIR}
cd /tmp

echo "==> 下载 FRP"
wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz

echo "==> 解压"
tar -zxvf frp_${FRP_VERSION}_linux_amd64.tar.gz

echo "==> 安装"
cp frp_${FRP_VERSION}_linux_amd64/frps ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frps

echo "==> 生成配置文件"
cat > ${INSTALL_DIR}/frps.toml <<EOF
bindPort = ${BIND_PORT}

auth.method = "token"
auth.token = "${TOKEN}"

webServer.addr = "0.0.0.0"
webServer.port = ${DASHBOARD_PORT}
webServer.user = "admin"
webServer.password = "admin"

log.to = "/var/log/frps.log"
log.level = "info"
EOF

echo "==> 创建 OpenRC 服务"
cat > /etc/init.d/frps <<EOF
#!/sbin/openrc-run

name="frps"
description="FRP Server"
command="${INSTALL_DIR}/frps"
command_args="-c ${INSTALL_DIR}/frps.toml"
pidfile="/run/frps.pid"

depend() {
    need net
}
EOF

chmod +x /etc/init.d/frps

echo "==> 设置开机自启"
rc-update add frps default

echo "==> 启动服务"
rc-service frps start

echo "=================================="
echo "FRP 服务端安装完成！"
echo "端口: ${BIND_PORT}"
echo "Dashboard: ${DASHBOARD_PORT}"
echo "账号: admin"
echo "密码: admin"
echo "=================================="
