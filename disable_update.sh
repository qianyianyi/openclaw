#!/bin/bash
set -euo pipefail  # 严格的错误处理

# 检查是否为root
if [ "$EUID" -ne 0 ]; then
  echo "错误：必须以root身份运行此脚本" >&2
  exit 1
fi

echo "===== GOD MODE IMMUTABLE LOCK ====="

# 定义回滚标记和备份目录
BACKUP_DIR="/var/immutable_backup"
mkdir -p "$BACKUP_DIR"

################################
echo "[1] Install requirements"
################################
echo "正在安装必要依赖..."
if ! apt update -y; then
  echo "警告：apt更新失败，继续尝试安装依赖..." >&2
fi
if ! apt install -y overlayroot aide; then
  echo "错误：依赖安装失败，退出脚本" >&2
  exit 1
fi

################################
echo "[2] Enable RAM overlay root (备份配置)"
################################
if [ -f "/etc/overlayroot.conf" ]; then
  cp /etc/overlayroot.conf "$BACKUP_DIR/"
fi
cat <<EOF > /etc/overlayroot.conf
overlayroot="tmpfs"
EOF
echo "RAM overlay配置已完成（重启后生效）"

################################
echo "[3] Disable package systems (备份权限)"
################################
# 备份原始权限
for bin in /usr/bin/apt* /usr/bin/dpkg* /usr/bin/snap; do
  if [ -f "$bin" ]; then
    stat -c "%a %n" "$bin" >> "$BACKUP_DIR/bin_perms.txt"
    chmod 000 "$bin" 2>/dev/null
  fi
done

################################
echo "[4] Kill update services"
################################
for s in apt-daily.service apt-daily.timer \
apt-daily-upgrade.service apt-daily-upgrade.timer \
unattended-upgrades; do
  systemctl stop "$s" 2>/dev/null || true
  systemctl disable "$s" 2>/dev/null || true
  systemctl mask "$s" 2>/dev/null || true
done

################################
echo "[5] Remove repositories (备份源文件)"
################################
if [ -f "/etc/apt/sources.list" ]; then
  cp /etc/apt/sources.list "$BACKUP_DIR/"
fi
cp -r /etc/apt/sources.list.d "$BACKUP_DIR/" 2>/dev/null || true
echo "#locked" > /etc/apt/sources.list
rm -rf /etc/apt/sources.list.d/*

################################
# 【已删除】[6] Kernel lockdown 相关配置
################################

################################
echo "[6] GRUB password auto (强密码生成)"  # 步骤序号从7改为6
################################
# 生成随机强密码（而非固定lock）
GRUB_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
echo "GRUB密码已生成：$GRUB_PASS (请妥善保存！)"
HASH=$(echo -e "$GRUB_PASS\n$GRUB_PASS" | grub-mkpasswd-pbkdf2 | grep grub.pbkdf2 | awk '{print $7}')

# 备份40_custom
if [ -f "/etc/grub.d/40_custom" ]; then
  cp /etc/grub.d/40_custom "$BACKUP_DIR/"
fi

cat <<EOF >> /etc/grub.d/40_custom
set superusers="rootlock"
password_pbkdf2 rootlock $HASH
EOF

update-grub || echo "警告：GRUB更新失败，请手动检查" >&2

################################
echo "[7] Make system immutable (overlay重启后生效)"  # 步骤序号从8改为7
################################
# 延迟锁定，先备份chattr状态
for dir in /etc /usr /bin /sbin /boot; do
  lsattr "$dir" >> "$BACKUP_DIR/lsattr_backup.txt" 2>/dev/null || true
  # overlay生效前先不执行chattr，避免操作失效
  echo "计划锁定目录：$dir (重启后执行chattr +i $dir)"
done

################################
echo "[8] File integrity database"  # 步骤序号从9改为8
################################
echo "正在初始化AIDE数据库..."
if ! aideinit; then
  echo "错误：AIDE数据库初始化失败" >&2
else
  if [ -f "/var/lib/aide/aide.db.new" ]; then
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo "AIDE数据库已生成"
  else
    echo "错误：未找到AIDE新数据库文件" >&2
  fi
fi

################################
echo "[9] Auto tamper detection (添加告警)"  # 步骤序号从10改为9
################################
cat <<EOF > /usr/local/bin/system-guard.sh
#!/bin/bash
# 系统完整性检测脚本（带告警）
LOG_FILE="/var/log/system-guard.log"
echo "[$(date)] 开始系统完整性检测" >> \$LOG_FILE

aide --check >> \$LOG_FILE 2>&1
if [ \$? -ne 0 ]; then
   echo "[$(date)] 检测到系统篡改！" >> \$LOG_FILE
   # 可选：添加邮件告警 echo "系统篡改" | mail -s "系统告警" admin@example.com
   # 替换为只读挂载而非直接重启
   mount -o remount,ro /
else
   echo "[$(date)] 系统完整性正常" >> \$LOG_FILE
fi
EOF

chmod +x /usr/local/bin/system-guard.sh

################################
echo "[10] Guard at boot"  # 步骤序号从11改为10
################################
cat <<EOF > /etc/systemd/system/system-guard.service
[Unit]
Description=System Guard
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/system-guard.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable system-guard.service || echo "警告：启用system-guard服务失败" >&2

################################
echo "[11] Alias protection (全局生效)"  # 步骤序号从12改为11
################################
# 对所有shell生效，而非仅bash
cat <<EOF > /etc/profile.d/immutable_aliases.sh
alias apt='echo SYSTEM IMMUTABLE'
alias apt-get='echo SYSTEM IMMUTABLE'
alias dpkg='echo SYSTEM IMMUTABLE'
EOF
source /etc/profile.d/immutable_aliases.sh

# 生成回滚脚本
cat <<EOF > "$BACKUP_DIR/rollback.sh"
#!/bin/bash
set -e
echo "正在回滚不可变配置..."

# 恢复包管理权限
while read -r perm bin; do
  chmod \$perm \$bin 2>/dev/null || true
done < "$BACKUP_DIR/bin_perms.txt"

# 恢复源文件
cp "$BACKUP_DIR/sources.list" /etc/apt/sources.list 2>/dev/null || true
cp -r "$BACKUP_DIR/sources.list.d" /etc/apt/ 2>/dev/null || true

# 恢复GRUB配置（移除了内核锁定相关的恢复）
cp "$BACKUP_DIR/grub" /etc/default/grub 2>/dev/null || true
cp "$BACKUP_DIR/40_custom" /etc/grub.d/ 2>/dev/null || true
update-grub

# 恢复overlay配置
cp "$BACKUP_DIR/overlayroot.conf" /etc/ 2>/dev/null || true

# 启用更新服务
for s in apt-daily.service apt-daily.timer apt-daily-upgrade.service apt-daily-upgrade.timer unattended-upgrades; do
  systemctl unmask \$s 2>/dev/null || true
  systemctl enable \$s 2>/dev/null || true
done

# 删除别名
rm -f /etc/profile.d/immutable_aliases.sh

# 禁用system-guard服务
systemctl disable --now system-guard.service
rm -f /etc/systemd/system/system-guard.service
rm -f /usr/local/bin/system-guard.sh

echo "回滚完成，请重启系统生效"
EOF
chmod +x "$BACKUP_DIR/rollback.sh"

echo "===== IMMUTABLE GOD MODE ENABLED ====="
echo "⚠️ 重要：备份文件位于 $BACKUP_DIR"
echo "⚠️ 回滚脚本：$BACKUP_DIR/rollback.sh (仅重启前可用)"
echo "REBOOT NOW"
