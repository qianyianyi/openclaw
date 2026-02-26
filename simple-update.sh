#!/bin/bash
# OpenClaw 简单自动更新

echo "[$(date)] 检查 OpenClaw 更新..."

# 检查当前版本
CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "未知")
echo "当前版本: $CURRENT_VERSION"

# 执行更新检查
echo "执行更新检查..."
openclaw update --dry-run

if [ $? -eq 0 ]; then
    echo "有可用更新，执行更新..."
    openclaw update --yes --no-restart
    
    if [ $? -eq 0 ]; then
        echo "更新成功，重启服务..."
        systemctl --user restart openclaw-gateway.service
        echo "新版本: $(openclaw --version)"
    else
        echo "更新失败"
    fi
else
    echo "已是最新版本"
fi

echo "[$(date)] 更新检查完成"