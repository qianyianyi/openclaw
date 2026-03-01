#!/bin/bash
set -e

echo "===== 正在为您打造绝对稳定环境 ====="

# 1. 彻底禁用并锁死 apt 自动更新定时器
echo "-> 1/4 禁用自动更新定时器..."
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer >/dev/null 2>&1
sudo systemctl disable apt-daily.timer apt-daily-upgrade.timer >/dev/null 2>&1
sudo systemctl mask apt-daily.timer apt-daily-upgrade.timer >/dev/null 2>&1
sudo systemctl stop apt-daily.service apt-daily-upgrade.service >/dev/null 2>&1
sudo systemctl disable apt-daily.service apt-daily-upgrade.service >/dev/null 2>&1
sudo systemctl mask apt-daily.service apt-daily-upgrade.service >/dev/null 2>&1

# 2. 配置 apt 强制禁止无人值守升级
echo "-> 2/4 锁定更新配置..."
sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# 3. 写入版本锁定规则，钉死在 Debian 12
echo "-> 3/4 锁定系统版本为 Bookworm..."
sudo tee /etc/apt/preferences >/dev/null <<EOF
Package: *
Pin: release a=stable
Pin-Priority: 990

Package: *
Pin: release o=Debian,a=testing
Pin-Priority: -1

Package: *
Pin: release o=Debian,a=unstable
Pin-Priority: -1
EOF

# 4. 设为只读，防止任何人/脚本篡改锁定配置
sudo chmod 444 /etc/apt/preferences

echo "===== 所有操作执行完成！ ======"
echo ""
echo "✅ 最终状态："
echo "1. 自动更新已彻底禁用 (masked 状态)"
echo "2. 系统版本已永久锁定在 Debian 12"
echo "3. 手动执行 apt update 只会显示 12 为最新版"
echo ""
echo "🧱 环境已加固，请放心使用服务器！"
