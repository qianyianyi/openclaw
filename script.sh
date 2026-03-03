#!/bin/bash
clear
echo "========================================"
echo "   轻量 Chromium + 网页VNC 一键安装"
echo "       无Docker · 交互式 · 开机自启"
echo "========================================"

read -p "设置VNC密码：" VNC_PASSWD
read -p "设置网页访问端口（如 8888）：" VNC_PORT

apt update -y
apt install -y xfce4 xfce4-goodies tightvncserver novnc websockify chromium-browser

mkdir -p ~/.vnc
echo "${VNC_PASSWD}" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

cat > ~/.vnc/xstartup <<EOF
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

vncserver -kill :1 >/dev/null 2>&1
pkill -f websockify >/dev/null 2>&1

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

systemctl daemon-reload
systemctl enable --now vncserver@1
systemctl enable --now novnc

echo -e "\n✅ 安装完成！"
echo "🌐 访问：http://你的IP:${VNC_PORT}/vnc.html"
echo "🔑 密码：${VNC_PASSWD}"
echo "🚀 已开机自启 | 浏览器：轻量 Chromium"
