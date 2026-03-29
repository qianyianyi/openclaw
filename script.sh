#!/bin/sh

set -e

echo "=== 开始清理 Alpine Linux 系统垃圾 ==="

# 1. 清理 apk 缓存
echo "清理 apk 缓存..."
rm -rf /var/cache/apk/*
apk cache clean 2>/dev/null

# 2. 卸载无用依赖
echo "卸载孤立依赖包..."
apk autoremove --purge

# 3. 清理临时文件
echo "清理临时目录..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# 4. 清空系统日志（不删除文件，只清空内容）
echo "清空系统日志..."
truncate -s0 /var/log/messages 2>/dev/null
truncate -s0 /var/log/syslog 2>/dev/null
truncate -s0 /var/log/dmesg 2>/dev/null
truncate -s0 /var/log/auth.log 2>/dev/null

# 5. 清理归档日志
echo "清理归档日志..."
rm -rf /var/log/*.gz
rm -rf /var/log/*.old
rm -rf /var/log/*.bz2
rm -rf /var/log/*.log.*

# 6. 清理 root 缓存
echo "清理 root 缓存..."
rm -rf /root/.cache/*
rm -rf /root/.local/share/Trash/*

# 7. 清理 bash 历史
echo "清空命令历史..."
truncate -s0 /root/.ash_history 2>/dev/null

echo ""
echo "✅ Alpine 系统清理完成！"
df -h /
