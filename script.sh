#!/bin/sh

echo "[+] 停止 FRP 服务..."

# systemd
if command -v systemctl >/dev/null 2>&1; then
    systemctl stop frps 2>/dev/null
    systemctl stop frpc 2>/dev/null
    systemctl disable frps 2>/dev/null
    systemctl disable frpc 2>/dev/null
    rm -f /etc/systemd/system/frps.service
    rm -f /etc/systemd/system/frpc.service
    systemctl daemon-reload
fi

# OpenRC (Alpine)
if command -v rc-service >/dev/null 2>&1; then
    rc-service frps stop 2>/dev/null
    rc-service frpc stop 2>/dev/null
    rc-update del frps default 2>/dev/null
    rc-update del frpc default 2>/dev/null
    rm -f /etc/init.d/frps
    rm -f /etc/init.d/frpc
fi

echo "[+] 杀掉残留进程..."
pkill -f frps 2>/dev/null
pkill -f frpc 2>/dev/null

echo "[+] 删除程序文件..."
rm -rf /opt/frp

echo "[+] 清理日志和残留..."
rm -rf /var/run/frps.pid
rm -rf /var/run/frpc.pid

echo "================================="
echo "FRP 已彻底卸载完成"
echo "================================="
