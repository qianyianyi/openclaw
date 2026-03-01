#!/bin/bash
set -e

echo "===== 开始禁用 Debian 12 自动更新 ====="

# 停止并屏蔽 apt-daily 计时器
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer
sudo systemctl disable apt-daily.timer apt-daily-upgrade.timer
sudo systemctl mask apt-daily.timer apt-daily-upgrade.timer

# 停止并屏蔽 apt-daily 服务
sudo systemctl stop apt-daily.service apt-daily-upgrade.service
sudo systemctl disable apt-daily.service apt-daily-upgrade.service
sudo systemctl mask apt-daily.service apt-daily-upgrade.service

# 停止并禁用无人值守升级（如果存在）
if systemctl list-unit-files | grep -q unattended-upgrades.service; then
  sudo systemctl stop unattended-upgrades.service
  sudo systemctl disable unattended-upgrades.service
  sudo systemctl mask unattended-upgrades.service
fi

# 强制关闭自动更新检查与无人升级
echo -e "APT::Periodic::Update-Package-Lists \"0\";\nAPT::Periodic::Unattended-Upgrade \"0\";" | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

echo "===== 禁用完成！ ====="
echo ""
echo "验证状态（应显示 masked）："
systemctl status apt-daily.timer apt-daily-upgrade.timer
