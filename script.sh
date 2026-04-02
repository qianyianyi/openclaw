#!/bin/sh

# 启用 crontab 并开机自启
rc-update add crond default
rc-service crond start

# 每天 2 点执行清理
echo "0 2 * * * truncate -s0 /var/log/* 2>/dev/null" >> /etc/crontabs/root

# 重启生效
rc-service crond restart

echo "✅ 定时日志清理已设置：每天 02:00 清空 /var/log/*"
