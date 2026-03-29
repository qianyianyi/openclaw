#!/bin/bash
echo "========== 开始彻底卸载frp =========="

# 停止并禁用frp相关服务
echo "停止并禁用frps、frpc服务..."
systemctl stop frps >/dev/null 2>&1
systemctl stop frpc >/dev/null 2>&1
systemctl disable frps >/dev/null 2>&1
systemctl disable frpc >/dev/null 2>&1

# 删除系统服务配置文件
echo "删除frp服务文件..."
rm -f /etc/systemd/system/frp*.service
rm -f /usr/lib/systemd/system/frp*.service
systemctl daemon-reload
systemctl reset-failed

# 删除frp程序、配置、日志文件
echo "清理frp程序、配置及日志..."
rm -rf /usr/local/bin/frp*
rm -rf /opt/frp /usr/local/frp
rm -rf /etc/frp
rm -rf /var/log/frp*
rm -rf /tmp/frp*

# 杀死残留进程
echo "结束残留frp进程..."
ps aux | grep -i frp | grep -v grep | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1

# 验证卸载结果
echo "========== 卸载完成 =========="
if ! command -v frps &> /dev/null && ! command -v frpc &> /dev/null; then
    echo "✅ frp已彻底卸载，无残留文件"
else
    echo "⚠️  检测到残留，可手动检查剩余文件"
fi
