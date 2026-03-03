#!/bin/bash
clear
echo "========================================"
echo "   轻量 Chromium + 网页VNC 一键安装"
echo "        端口默认8888 · 仅输密码"
echo "========================================"

read -p "请设置 VNC 密码：" VNC_PASSWD
VNC_PORT="8888"

# 更新源并安装依赖（修复chromium包名）
apt update -y
apt install -y xfce4 xfce4-goodies tightvncserver novnc websockify chromium --fix-missing

# 配置VNC密码
mkdir -p ~/.vnc
echo "${VNC_PASSWD}" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 配置VNC启动文件
cat > ~/.vnc/xstartup <<EOF
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# 清理旧进程
vncserver -kill :1 >/dev/null 2>&1
pkill -f websockify >/dev/null 2>&1

# 配置VNC开机自启
cat > /etc/systemd/system/vncserver@1.service <<EOF
[Unit]
Description=VNC Server
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/vncserver :1 -geometry 1280x720 -depth 24
ExecStop=/usr/bin/vncserver -kill :1
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 配置网页VNC开机自启
cat > /etc/systemd/system/novnc.service <<EOF
[Unit]
Description=noVNC Web
After=vncserver@1.service

[Service]
ExecStart=/usr/bin/websockify --web=/usr/share/novnc ${VNC_PORT} localhost:5901
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 生效并启动服务
systemctl daemon-reload
systemctl enable --now vncserver@1
systemctl enable --now novnc

echo -e "\n✅ 安装完成！"
echo "🌐 访问地址：http://你的IP:8888/vnc.html"
echo "🔑 密码：${VNC_PASSWD}"
echo "🚀 已设置开机自启"
