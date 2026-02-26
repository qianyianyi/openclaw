#!/bin/bash
set -e

echo "============================================="
echo "      OpenClaw 彻底卸载 · 清理所有残留"
echo "============================================="

# 1. 停止所有可能的进程
echo "[1/6] 停止 OpenClaw 相关进程..."
pkill -f openclaw 2>/dev/null || true
pkill -f moltbot 2>/dev/null || true

# 2. 卸载服务
echo "[2/6] 卸载系统服务..."
openclaw gateway stop 2>/dev/null || true
openclaw gateway uninstall 2>/dev/null || true

# 3. 删除主配置目录
echo "[3/6] 删除配置与数据目录..."
rm -rf ~/.openclaw
rm -rf /root/.openclaw
rm -rf /usr/local/openclaw
rm -rf /opt/openclaw

# 4. 全局命令卸载
echo "[4/6] 卸载全局 CLI..."
npm rm -g openclaw 2>/dev/null || true
pnpm rm -g openclaw 2>/dev/null || true
yarn global remove openclaw 2>/dev/null || true
bun rm -g openclaw 2>/dev/null || true

# 5. 清理系统链接
echo "[5/6] 清理系统命令链接..."
sudo rm -f /usr/bin/openclaw
sudo rm -f /usr/local/bin/openclaw
sudo rm -f /usr/bin/moltbot
sudo rm -f /usr/local/bin/moltbot

# 6. 全盘搜索清理所有 openclaw 文件夹（谨慎）
echo "[6/6] 全盘清理所有 openclaw 相关目录..."
find / -type d -name "*openclaw*" 2>/dev/null | xargs rm -rf 2>/dev/null || true
find / -type d -name "*moltbot*" 2>/dev/null | xargs rm -rf 2>/dev/null || true

echo ""
echo "✅ OpenClaw 已卸载完成、彻底卸载成功，无任何残留！"
