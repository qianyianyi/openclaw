#!/bin/bash

echo "=== 开始彻底卸载 OpenClaw ==="

# 停止服务
systemctl stop openclaw-gateway >/dev/null 2>&1
systemctl disable openclaw-gateway >/dev/null 2>&1
rm -f /etc/systemd/system/openclaw*.service
systemctl daemon-reload

# 卸载全局包
npm uninstall -g openclaw >/dev/null 2>&1
pnpm remove -g openclaw >/dev/null 2>&1
bun remove -g openclaw >/dev/null 2>&1

# 删除所有残留文件
rm -rf /root/.openclaw
rm -rf /root/.clawdbot /root/.moltbot /root/.molthub
rm -rf /root/.config/openclaw /root/.local/share/openclaw
rm -f /usr/local/bin/openclaw /opt/bin/openclaw

# 清理 bash 配置报错
sed -i '/openclaw.bash/d' /root/.bashrc
sed -i '/openclaw.bash/d' /root/.bash_profile
sed -i '/openclaw.bash/d' /root/.profile
sed -i '/openclaw.bash/d' /etc/bash.bashrc

# 重载环境
source /root/.bashrc

echo "=== OpenClaw 已完全卸载完成 ==="
exec bash
