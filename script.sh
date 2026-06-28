#!/bin/bash
echo "====================================="
echo "        哪吒面板一键彻底卸载脚本"
echo "====================================="

# 杀掉所有哪吒相关进程
echo "[1/8] 终止所有哪吒进程..."
pkill -f nezha 2>/dev/null
pkill -f nezha-agent 2>/dev/null
pkill -f nezha-dashboard 2>/dev/null
sleep 1

# 停止并禁用 systemd 服务
echo "[2/8] 停止并移除 systemd 服务..."
systemctl stop nezha-agent 2>/dev/null
systemctl stop nezha-agent.service 2>/dev/null
systemctl disable nezha-agent 2>/dev/null
systemctl disable nezha-agent.service 2>/dev/null

# 删除服务文件
rm -f /etc/systemd/system/nezha-agent.service
rm -f /usr/lib/systemd/system/nezha-agent.service
rm -f /lib/systemd/system/nezha-agent.service

# 删除主目录
echo "[3/8] 删除哪吒所有程序目录..."
rm -rf /opt/nezha
rm -rf /etc/nezha

# 重载systemd配置
systemctl daemon-reload
systemctl reset-failed

# 清理Docker部署的哪吒
echo "[4/8] 清理Docker版哪吒容器镜像..."
if command -v docker &> /dev/null; then
docker rm -f nezha-dashboard 2>/dev/null
docker rmi nezhahq/nezha 2>/dev/null
docker-compose down 2>/dev/null
rm -rf ./nezha-dashboard ~/nezha-dashboard
fi

# 删除安装脚本残留
echo "[5/8] 删除安装脚本残留文件..."
rm -f ~/nezha.sh
rm -f ~/agent.sh
rm -f /root/nezha.sh
rm -f /root/agent.sh

# Alpine OpenRC 兼容清理（防止OpenRC系统残留）
if [ -f /sbin/openrc-run ]; then
echo "[6/8] 清理Alpine OpenRC自启动..."
rc-service nezha-agent stop 2>/dev/null
rc-update del nezha-agent default 2>/dev/null
rm -f /etc/init.d/nezha-agent
fi

# 自检
echo -e "\n====================================="
echo "卸载完成，正在检查残留："
echo "【残留进程】"
ps aux | grep nezha | grep -v grep
echo "【残留服务】"
systemctl list-unit-files | grep nezha
echo "【/opt/nezha目录状态】"
if [ -d "/opt/nezha" ]; then
    echo "⚠️ /opt/nezha 仍然存在，删除失败"
else
    echo "✅ /opt/nezha 已删除"
fi
echo "====================================="
echo "哪吒卸载操作全部执行完毕"
