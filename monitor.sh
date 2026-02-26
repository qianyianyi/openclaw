#!/bin/bash
# OpenClaw 资源监控脚本

# 检查磁盘使用率
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -gt 80 ]; then
    echo "警告：磁盘使用率超过 80% ($disk_usage%)"
fi

# 检查内存使用率
mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $mem_usage -gt 85 ]; then
    echo "警告：内存使用率超过 85% ($mem_usage%)"
fi

# 检查 OpenClaw 服务状态
if ! systemctl --user is-active openclaw-gateway.service >/dev/null; then
    echo "错误：OpenClaw 网关服务未运行"
else
    echo "OpenClaw 服务运行正常"
fi

echo "监控完成: $(date)"