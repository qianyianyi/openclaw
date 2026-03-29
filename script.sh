#!/bin/sh

# 停止所有 frp 进程
killall -9 frps frpc 2>/dev/null

# 停止并禁用服务
rc-service frps stop 2>/dev/null
rc-service frpc stop 2>/dev/null
rc-update del frps 2>/dev/null
rc-update del frpc 2>/dev/null

# 删除服务文件
rm -rf /etc/init.d/frp*
rm -rf /etc/frp*

# 删除二进制文件
rm -f /usr/local/bin/frps
rm -f /usr/local/bin/frpc

# 删除日志、缓存、残留
rm -rf /var/log/frp*
rm -rf /tmp/frp*
rm -rf /opt/frp /usr/local/frp

# 重载服务
rc-update -u

echo "✅ Alpine 上 frp 已完全清理"
