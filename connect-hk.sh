#!/bin/bash
# 连接中国香港服务器脚本

SERVER="103.117.136.201"
USER="root"
PORT="22"
PASSWORD="AIshy980925."

echo "🔗 正在连接中国香港服务器..."
echo "📍 服务器: $SERVER"
echo "👤 用户: $USER"
echo "🚪 端口: $PORT"
echo ""

# 检查是否可以使用别名连接
if ssh -o ConnectTimeout=5 hk-server "echo '连接成功!'" 2>/dev/null; then
    echo "✅ 使用别名连接成功"
    ssh hk-server
else
    echo "⚠️  使用别名连接失败，使用密码连接"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$SERVER" -p "$PORT"
fi