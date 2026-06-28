#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# 必须root执行
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ 请使用 root 权限运行此脚本"
    exit 1
fi

echo "==================== 哪吒面板 深度彻底卸载清理 ===================="

# 1. 强制查杀所有含nezha进程（多次兜底查杀）
echo "[1] 查杀所有哪吒相关进程"
pkill -9 -f "nezha" || true
pkill -9 -f "nezha-agent" || true
pkill -9 -f "nezha-dashboard" || true
sleep 0.5

# 2. systemd 服务清理
echo "[2] 清理 systemd 服务单元"
systemctl stop nezha-agent nezha-agent.service nezha-dashboard 2>/dev/null || true
systemctl disable nezha-agent nezha-agent.service nezha-dashboard 2>/dev/null || true
rm -f /etc/systemd/system/nezha-agent.service
rm -f /etc/systemd/system/multi-user.target.wants/nezha-agent.service
rm -f /usr/lib/systemd/system/nezha-agent.service
rm -f /lib/systemd/system/nezha-agent.service
systemctl daemon-reload
systemctl reset-failed

# 3. Alpine OpenRC 启动项清理
if [ -x /sbin/openrc-run ]; then
    echo "[3] 清理 Alpine OpenRC 开机自启"
    rc-service nezha-agent stop 2>/dev/null || true
    rc-update del nezha-agent default 2>/dev/null || true
    rm -f /etc/init.d/nezha-agent
fi

# 4. 删除所有安装目录、配置、缓存
echo "[4] 删除所有哪吒目录文件"
rm -rf /opt/nezha
rm -rf /etc/nezha
rm -rf /var/lib/nezha
rm -rf /var/log/nezha
rm -rf /root/.nezha
rm -rf /home/*/.nezha

# 5. 删除安装脚本、残留脚本
echo "[5] 删除安装脚本残留"
find / -maxdepth 3 -name "nezha.sh" -o -name "agent.sh" | xargs rm -f 2>/dev/null

# 6. Docker 容器+镜像+配置清理
echo "[6] 清理 Docker 部署版本"
if command -v docker &>/dev/null; then
    docker rm -f nezha-dashboard nezha-agent 2>/dev/null || true
    docker rmi -f nezhahq/nezha nezhahq/agent 2>/dev/null || true
    rm -rf /root/nezha-dashboard ./nezha-dashboard ~/nezha-dashboard
    if command -v docker-compose &>/dev/null; then
        docker-compose down 2>/dev/null || true
    fi
fi

# 7. 全盘搜索残留文件并删除（兜底扫残余）
echo "[7] 全盘扫描删除nezha命名残留文件（稍慢）"
find / \( -name "*nezha*" \) -type f,d 2>/dev/null | grep -v /proc | grep -v /sys | while read -r file; do
    rm -rf "$file" 2>/dev/null
done

# 8. 最终校验
echo -e "\n==================== 卸载校验结果 ===================="
echo "1. 残留进程："
ps aux | grep -i nezha | grep -v grep || echo "✅ 无进程残留"

echo -e "\n2. systemd 残留服务："
systemctl list-unit-files | grep -i nezha || echo "✅ 无systemd服务残留"

echo -e "\n3. /opt/nezha 目录："
[ -d /opt/nezha ] && echo "❌ 目录仍存在" || echo "✅ 已彻底删除"

echo -e "\n4. 全盘nezha关键词检索："
res=$(find / -name "*nezha*" 2>/dev/null | grep -v /proc | grep -v /sys | head -5)
if [ -z "$res" ]; then
    echo "✅ 系统无任何哪吒相关残留文件"
else
    echo "⚠️ 发现少量残余："
    echo "$res"
fi

echo -e "\n==================== 清理完成 ===================="
