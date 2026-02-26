#!/bin/bash
# Cloudflare Tunnel 状态监控

echo "🌐 Cloudflare Tunnel 系统服务状态"
echo "================================"

# 服务状态
echo "🔧 系统服务状态:"
if systemctl is-active --quiet cloudflared-tunnel.service; then
    echo "  🟢 服务运行中"
else
    echo "  🔴 服务未运行"
fi

# 进程状态
echo ""
echo "⚡ 进程状态:"
PROCESS_COUNT=$(ps aux | grep cloudflared | grep -v grep | wc -l)
if [ $PROCESS_COUNT -gt 0 ]; then
    echo "  🟢 有 $PROCESS_COUNT 个 cloudflared 进程运行"
    ps aux | grep cloudflared | grep -v grep | awk '{print "    PID:" $2 " 内存:" $6/1024 "MB"}'
else
    echo "  🔴 无 cloudflared 进程"
fi

# 服务详细信息
echo ""
echo "📊 服务详情:"
systemctl status cloudflared-tunnel.service --no-pager -l | grep -E "(Active|Main PID|Memory|Tasks)" | head -4 | sed 's/^/  /'

# 管理命令
echo ""
echo "🛠️ 管理命令:"
echo "  systemctl status cloudflared-tunnel.service  # 查看状态"
echo "  systemctl restart cloudflared-tunnel.service # 重启服务"
echo "  journalctl -u cloudflared-tunnel.service -f  # 查看日志"
echo "  systemctl stop cloudflared-tunnel.service    # 停止服务"

# 自动启动状态
echo ""
echo "🔗 自动启动:"
if systemctl is-enabled --quiet cloudflared-tunnel.service; then
    echo "  🟢 已启用开机自启动"
else
    echo "  🔴 未启用开机自启动"
fi