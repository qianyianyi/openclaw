#!/bin/sh

echo "[+] 停止所有 FRP 相关服务..."

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

# OpenRC
if command -v rc-service >/dev/null 2>&1; then
    rc-service frps stop 2>/dev/null
    rc-service frpc stop 2>/dev/null
    rc-update del frps default 2>/dev/null
    rc-update del frpc default 2>/dev/null
    rm -f /etc/init.d/frps
    rm -f /etc/init.d/frpc
fi

echo "[+] 杀掉所有 FRP 进程..."
pkill -f frps 2>/dev/null
pkill -f frpc 2>/dev/null

echo "[+] 删除常见目录..."
rm -rf /opt/frp
rm -rf /usr/local/frp
rm -rf /usr/local/bin/frps
rm -rf /usr/local/bin/frpc
rm -rf /etc/frp
rm -rf /var/log/frp

echo "[+] 删除 PID / 临时文件..."
rm -f /var/run/frps.pid
rm -f /var/run/frpc.pid
rm -f /tmp/frp*

echo "[+] 全盘搜索并删除残留文件（可能较慢）..."

find / -type f \( -name "frps" -o -name "frpc" -o -name "frps.ini" -o -name "frpc.ini" \) 2>/dev/null | while read file
do
    echo "删除: $file"
    rm -f "$file"
done

echo "[+] 清理可能的目录..."

find / -type d -name "*frp*" 2>/dev/null | while read dir
do
    echo "删除目录: $dir"
    rm -rf "$dir"
done

echo "======================================"
echo "🔥 FRP 已从系统彻底清除（全盘级）"
echo "======================================"
