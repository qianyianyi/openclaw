#!/bin/bash

###############################################################################
# 脚本名称：nuclear_lockdown.sh
# 级别：核毁灭 (Nuclear Meltdown)
# 功能：替换 apt 二进制 + 锁定包数据库 + 清除更新守护进程
# 警告：执行后 apt 命令将永久失效，直到手动恢复！
###############################################################################

set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ 必须使用 root 权限运行"
  exit 1
fi

echo "☠️  你正在请求彻底破坏包管理功能..."
echo "☠️  系统将在 10 秒后开始自锁..."
echo "☠️  按 Ctrl+C 取消..."
sleep 10

BACKUP_DIR="/root/nuclear-backup-$(date +%F-%H%M)"
mkdir -p "$BACKUP_DIR"

# 1. 备份关键二进制文件
echo "💾 [1/7] 备份 apt 二进制文件..."
binaries=(
    "/usr/bin/apt"
    "/usr/bin/apt-get"
    "/usr/bin/apt-cache"
    "/usr/bin/apt-key"
    "/usr/bin/apt-config"
    "/usr/bin/unattended-upgrade"
    "/usr/bin/unattended-upgrades"
)

for bin in "${binaries[@]}"; do
    if [ -f "$bin" ]; then
        cp "$bin" "$BACKUP_DIR/$(basename $bin).bak"
    fi
done

# 2. 替换二进制为“拒绝服务”脚本
echo "🚫 [2/7] 替换二进制文件为_stub..."
for bin in "${binaries[@]}"; do
    if [ -f "$bin" ]; then
        cat > "$bin" <<EOF
#!/bin/bash
echo "❌ 错误：系统已锁定，禁止任何包管理操作！"
echo "🔒 请联系管理员解锁。"
exit 1
EOF
        chmod +x "$bin"
    fi
done

# 3. 锁定包数据库 (dpkg lock)
echo "🔒 [3/7] 锁定 dpkg 数据库..."
dpkg_locks=(
    "/var/lib/dpkg/lock"
    "/var/lib/dpkg/lock-frontend"
    "/var/lib/apt/lists/lock"
    "/var/cache/apt/archives/lock"
)

for lock in "${dpkg_locks[@]}"; do
    if [ -e "$lock" ]; then
        # 确保锁文件存在
        touch "$lock"
        # 设为不可变
        chattr +i "$lock"
    fi
done

# 4. 锁定 apt 列表目录
echo "🔒 [4/7] 锁定 apt 列表目录..."
chattr +i /var/lib/apt/lists 2>/dev/null || true
chattr -R +i /var/lib/apt/lists 2>/dev/null || true

# 5. 清除更新相关守护进程
echo "🗑️  [5/7] 卸载更新守护进程..."
# 注意：由于 apt 已被替换，这里只能用 dpkg 强制移除配置，或者仅停止服务
# 为了安全，我们只停止并禁用服务，不强制卸载包以免破坏依赖
services=(
    "unattended-upgrades"
    "apt-daily"
    "apt-daily-upgrade"
    "packagekit"
    "fwupd"
)

for svc in "${services[@]}"; do
    systemctl stop "$svc" 2>/dev/null || true
    systemctl disable "$svc" 2>/dev/null || true
    systemctl mask "$svc" 2>/dev/null || true
done

# 6. 网络层面屏蔽 (Hosts + Firewall)
echo "🛑 [6/7] 网络层面屏蔽..."
# 备份 hosts
cp /etc/hosts "$BACKUP_DIR/hosts.bak"
# 添加屏蔽
cat >> /etc/hosts <<EOF
# NUCLEAR LOCKDOWN
127.0.0.1 archive.ubuntu.com
127.0.0.1 security.ubuntu.com
127.0.0.1 deb.debian.org
127.0.0.1 security.debian.org
127.0.0.1 launchpad.net
EOF

# 如果有 ufw，禁止 outbound 80/443 (谨慎！这会断网)
# 这里我们不做全局断网，只做 hosts 屏蔽，以免用户无法 SSH 连接

# 7. 禁用 NetworkManager 连通性检查
echo "📶 [7/7] 禁用网络连通性检查..."
if [ -d /etc/NetworkManager ]; then
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/00-disable-connectivity-check.conf <<EOF
[connectivity]
interval=0
uri=http://127.0.0.1/
EOF
    systemctl reload NetworkManager 2>/dev/null || true
fi

echo ""
echo "☢️  锁定完成！系统已进入只读应用模式。"
echo "📂 备份位于：$BACKUP_DIR"
echo ""
echo "⚠️  尝试运行 'apt update' 将看到错误提示。"
echo "⚠️  恢复需要手动从备份目录还原二进制文件。"
