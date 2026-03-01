#!/bin/bash
set -e

echo "===== 正在锁定系统版本为 Debian 12 (Bookworm) ====="

# 创建 Preference 文件，强制优先级
sudo tee /etc/apt/preferences >/dev/null <<EOF
Package: *
Pin: release a=stable
Pin-Priority: 990

# 禁止任何非稳定版/安全更新的包进入
Package: *
Pin: release o=Debian,a=testing
Pin-Priority: -1

Package: *
Pin: release o=Debian,a=unstable
Pin-Priority: -1
EOF

# 同时锁定 apt 源配置，防止脚本覆盖
sudo chmod 444 /etc/apt/preferences
echo "===== 锁定完成！ ====="
