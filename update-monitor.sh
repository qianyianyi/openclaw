#!/bin/bash
# OpenClaw 更新状态监控

echo "🔄 OpenClaw 更新状态监控"
echo "========================"

# 显示当前版本
CURRENT_VERSION=$(openclaw --version 2>/dev/null || echo "未知")
echo "📊 当前版本: $CURRENT_VERSION"

# 显示更新通道
echo "📡 更新通道: $(openclaw update status | grep Channel | awk '{print $2}')"

# 显示定时任务状态
echo "⏰ 自动更新计划:"
crontab -l | grep auto-update | while read line; do
    echo "  $line"
done

# 显示最近更新日志
echo ""
echo "📝 最近更新日志:"
if [ -f "/var/log/openclaw-update.log" ]; then
    tail -5 /var/log/openclaw-update.log | sed 's/^/  /'
else
    echo "  暂无更新日志"
fi

# 检查下次更新时间
echo ""
echo "🕐 下次更新时间:"
NEXT_RUN=$(crontab -l | grep auto-update | awk '{print $2 "时" $1 "分 明天"}')
echo "  每天 $NEXT_RUN"

echo ""
echo "💡 手动更新命令:"
echo "  openclaw update          # 执行更新"
echo "  openclaw update --dry-run # 预览更新"
echo "  openclaw update status    # 检查状态"