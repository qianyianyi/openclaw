#!/bin/bash

echo "===== GOD MODE IMMUTABLE LOCK ====="

if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

################################
echo "[1] Install requirements"
################################
apt update -y 2>/dev/null
apt install -y overlayroot aide 2>/dev/null

################################
echo "[2] Enable RAM overlay root"
################################
cat <<EOF > /etc/overlayroot.conf
overlayroot="tmpfs"
EOF

################################
echo "[3] Disable package systems"
################################
chmod 000 /usr/bin/apt*
chmod 000 /usr/bin/dpkg*
chmod 000 /usr/bin/snap 2>/dev/null

################################
echo "[4] Kill update services"
################################
for s in apt-daily.service apt-daily.timer \
apt-daily-upgrade.service apt-daily-upgrade.timer \
unattended-upgrades
do
 systemctl stop $s 2>/dev/null
 systemctl disable $s 2>/dev/null
 systemctl mask $s
done

################################
echo "[5] Remove repositories"
################################
echo "#locked" > /etc/apt/sources.list
rm -rf /etc/apt/sources.list.d/*

################################
echo "[6] Kernel lockdown"
################################
sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="lockdown=confidentiality /' \
/etc/default/grub

################################
echo "[7] GRUB password auto"
################################
HASH=$(echo -e "lock\nlock" | grub-mkpasswd-pbkdf2 | \
grep grub.pbkdf2 | awk '{print $7}')

cat <<EOF >> /etc/grub.d/40_custom
set superusers="rootlock"
password_pbkdf2 rootlock $HASH
EOF

update-grub

################################
echo "[8] Make system immutable"
################################
chattr +i /etc
chattr +i /usr
chattr +i /bin
chattr +i /sbin
chattr +i /boot

################################
echo "[9] File integrity database"
################################
aideinit
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

################################
echo "[10] Auto tamper detection"
################################
cat <<EOF > /usr/local/bin/system-guard.sh
#!/bin/bash
aide --check
if [ \$? -ne 0 ]; then
   echo "SYSTEM MODIFIED!"
   reboot -f
fi
EOF

chmod +x /usr/local/bin/system-guard.sh

################################
echo "[11] Guard at boot"
################################
cat <<EOF > /etc/systemd/system/system-guard.service
[Unit]
Description=System Guard
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/system-guard.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable system-guard.service

################################
echo "[12] Alias protection"
################################
echo "alias apt='echo SYSTEM IMMUTABLE'"
echo "alias apt-get='echo SYSTEM IMMUTABLE'" >> /etc/bash.bashrc

echo "===== IMMUTABLE GOD MODE ENABLED ====="
echo "REBOOT NOW"
