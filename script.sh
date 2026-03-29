#!/bin/sh
set -e

clear
echo "====================================="
echo "  Alpine FRP 交互式一键安装（OpenRC）"
echo "====================================="
echo ""

# 选择模式
read -p "选择模式 [1]服务端frps [2]客户端frpc : " mode
if [ "$mode" != "1" ] && [ "$mode" != "2" ]; then
    echo "输入错误，退出"
    exit 1
fi

# 下载最新版 frp
echo -e "\n→ 下载最新版 frp..."
FRP_VER="0.62.1"
ARCH="linux_amd64"  # 改 arm64 等按需
mkdir -p /opt/frp
cd /opt/frp
wget -O frp.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_${ARCH}.tar.gz
tar zxf frp.tar.gz --strip-components=1
chmod +x frps frpc

# Token
echo -e "\n=== 认证配置 ==="
read -s -p "设置连接 Token（密码）: " token
echo ""

# ================== 服务端 ==================
if [ "$mode" = "1" ]; then
    echo -e "\n=== 服务端配置 ==="
    read -p "服务端绑定端口 (默认7000): " bind_port
    bind_port=${bind_port:-7000}

    read -p "开启仪表盘端口 (默认7500，回车关闭): " dash_port
    read -p "仪表盘用户名 (默认admin): " dash_user
    dash_user=${dash_user:-admin}
    read -s -p "仪表盘密码: " dash_pwd
    echo ""

    # 生成 frps.toml
    cat > frps.toml <<EOF
bindPort = $bind_port
auth.method = "token"
auth.token = "$token"
logFile = "/opt/frp/frps.log"
logLevel = "info"
EOF

    if [ -n "$dash_port" ] && [ -n "$dash_pwd" ]; then
        cat >> frps.toml <<EOF
dashboardPort = $dash_port
dashboardUser = "$dash_user"
dashboardPwd = "$dash_pwd"
EOF
    fi

    # OpenRC 服务文件
    cat > /etc/init.d/frps <<EOF
#!/sbin/openrc-run
name="frps"
description="FRP Server"
command="/opt/frp/frps"
command_args="-c /opt/frp/frps.toml"
supervisor="supervise-daemon"
pidfile="/run/frps.pid"
EOF
    chmod +x /etc/init.d/frps
    rc-update add frps default
    rc-service frps restart

    echo -e "\n✅ 服务端安装完成！"
    echo "服务端口：$bind_port"
    [ -n "$dash_port" ] && echo "面板：http://公网IP:$dash_port"
    echo "Token：$token"

# ================== 客户端 ==================
else
    echo -e "\n=== 客户端配置 ==="
    read -p "服务端公网IP: " server_ip
    read -p "服务端端口 (默认7000): " server_port
    server_port=${server_port:-7000}

    echo -e "\n=== 穿透规则 ==="
    read -p "规则名称(如ssh): " p_name
    p_name=${p_name:-ssh}
    read -p "类型(tcp/udp/http，默认tcp): " p_type
    p_type=${p_type:-tcp}
    read -p "本地IP(默认127.0.0.1): " local_ip
    local_ip=${local_ip:-127.0.0.1}
    read -p "本地端口: " local_port
    read -p "远程映射端口: " remote_port

    # 生成 frpc.toml
    cat > frpc.toml <<EOF
serverAddr = "$server_ip"
serverPort = $server_port
auth.method = "token"
auth.token = "$token"

[[proxies]]
name = "$p_name"
type = "$p_type"
localIP = "$local_ip"
localPort = $local_port
remotePort = $remote_port
EOF

    # OpenRC 服务文件
    cat > /etc/init.d/frpc <<EOF
#!/sbin/openrc-run
name="frpc"
description="FRP Client"
command="/opt/frp/frpc"
command_args="-c /opt/frp/frpc.toml"
supervisor="supervise-daemon"
pidfile="/run/frpc.pid"
EOF
    chmod +x /etc/init.d/frpc
    rc-update add frpc default
    rc-service frpc restart

    echo -e "\n✅ 客户端安装完成！"
    echo "已连接：$server_ip:$server_port"
    echo "穿透：$local_ip:$local_port → $server_ip:$remote_port"
fi

echo -e "\n常用命令："
echo "  查看状态：rc-service frp${mode:0:1} status"
echo "  重启：rc-service frp${mode:0:1} restart"
echo "  日志：tail -f /opt/frp/frp${mode:0:1}.log"
