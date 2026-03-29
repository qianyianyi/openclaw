#!/bin/sh

set -e

FRP_VERSION="0.51.3"
DIR="/opt/frp"

echo "[+] 安装依赖..."
if command -v apk >/dev/null 2>&1; then
    apk update && apk add wget tar curl gcompat
elif command -v apt >/dev/null 2>&1; then
    apt update && apt install -y wget tar curl
elif command -v yum >/dev/null 2>&1; then
    yum install -y wget tar curl
fi

echo "[+] 下载 FRP..."
cd /opt
rm -rf frp*
wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz
tar -zxf frp_${FRP_VERSION}_linux_amd64.tar.gz
mv frp_${FRP_VERSION}_linux_amd64 frp

TOKEN=$(head -c 16 /dev/urandom | md5sum | cut -c1-8)
IP=$(curl -s ifconfig.me || echo "YOUR_IP")

echo "[+] 写入配置..."
cat > $DIR/frps.ini <<EOF
[common]
bind_port = 7000
token = $TOKEN
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = admin
EOF

echo "[+] 创建服务..."

if command -v systemctl >/dev/null 2>&1; then
cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
ExecStart=$DIR/frps -c $DIR/frps.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frps
systemctl restart frps

else
cat > /etc/init.d/frps <<EOF
#!/sbin/openrc-run
command="$DIR/frps"
command_args="-c $DIR/frps.ini"
pidfile="/var/run/frps.pid"
depend() { need net; }
EOF

chmod +x /etc/init.d/frps
rc-update add frps default
service frps restart
fi

echo "=================================="
echo "FRP 服务端安装完成"
echo "IP: $IP"
echo "端口: 7000"
echo "TOKEN: $TOKEN"
echo "面板: http://$IP:7500"
echo "=================================="
