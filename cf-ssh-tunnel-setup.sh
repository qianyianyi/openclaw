#!/bin/bash
# Cloudflare Tunnel SSH 内网穿透配置脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${BLUE}[NOTE]${NC} $1"; }

# 显示欢迎信息
show_welcome() {
    echo "========================================"
    echo "🌐 Cloudflare Tunnel SSH 内网穿透配置"
    echo "========================================"
    echo ""
    echo "这个脚本将帮你："
    echo "  • 配置 Cloudflare Tunnel"
    echo "  • 创建 SSH 隧道"
    echo "  • 设置 systemd 服务"
    echo "  • 生成连接指南"
    echo ""
}

# 检查 SSH 服务
check_ssh_service() {
    log "检查 SSH 服务状态..."
    
    if systemctl is-active --quiet ssh; then
        log "SSH 服务运行正常"
    else
        warn "SSH 服务未运行，正在启动..."
        systemctl start ssh
        systemctl enable ssh
    fi
    
    # 检查 SSH 端口
    if netstat -tln | grep -q ":22 "; then
        log "SSH 端口 22 监听中"
    else
        error "SSH 端口未监听，请检查 SSH 服务"
        exit 1
    fi
}

# 安装 Cloudflared
install_cloudflared() {
    if command -v cloudflared &> /dev/null; then
        log "Cloudflared 已安装: $(cloudflared --version | awk '{print $3}')"
        return
    fi
    
    log "安装 Cloudflared..."
    
    # 检测架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
        *) error "不支持的架构: $ARCH" ;;
    esac
    
    # 下载安装
    cd /tmp
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.deb
    dpkg -i cloudflared-linux-${ARCH}.deb
    rm -f cloudflared-linux-${ARCH}.deb
    
    if command -v cloudflared &> /dev/null; then
        log "Cloudflared 安装成功"
    else
        error "Cloudflared 安装失败"
    fi
}

# 交互式配置
interactive_config() {
    echo ""
    echo "🔧 SSH 隧道配置"
    echo "================"
    
    # 获取子域名
    while true; do
        read -p "请输入 SSH 隧道子域名 (例如: ssh): " SUBDOMAIN
        if [ -n "$SUBDOMAIN" ]; then
            break
        fi
        warn "子域名不能为空"
    done
    
    # 获取主域名
    read -p "请输入你的主域名 (例如: example.com): " DOMAIN
    if [ -z "$DOMAIN" ]; then
        DOMAIN="your-domain.com"
        warn "使用默认域名: $DOMAIN (需要在 Cloudflare 配置)"
    fi
    
    FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
    TUNNEL_NAME="ssh-tunnel-${SUBDOMAIN}"
    
    echo ""
    info "配置信息:"
    echo "  隧道名称: $TUNNEL_NAME"
    echo "  访问域名: $FULL_DOMAIN"
    echo "  本地服务: SSH (localhost:22)"
    echo ""
    
    read -p "确认配置? (y/N): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        log "配置已取消"
        exit 0
    fi
}

# Cloudflare 认证
authenticate_cloudflare() {
    log "Cloudflare 认证..."
    
    echo ""
    info "认证步骤:"
    echo "  1. 浏览器将打开 Cloudflare 登录页面"
    echo "  2. 登录你的账户"
    echo "  3. 选择域名: $DOMAIN"
    echo "  4. 授权完成后返回终端"
    echo ""
    
    read -p "按 Enter 开始认证..."
    
    cloudflared tunnel login
    
    if [ $? -eq 0 ]; then
        log "Cloudflare 认证成功"
    else
        error "认证失败，请手动运行: cloudflared tunnel login"
        exit 1
    fi
}

# 创建隧道
create_tunnel() {
    log "创建 SSH 隧道..."
    
    cloudflared tunnel create $TUNNEL_NAME
    
    if [ $? -eq 0 ]; then
        log "隧道创建成功: $TUNNEL_NAME"
    else
        error "隧道创建失败"
        exit 1
    fi
    
    # 配置 DNS 路由
    log "配置 DNS 路由..."
    cloudflared tunnel route dns $TUNNEL_NAME $FULL_DOMAIN
}

# 创建配置文件
create_config() {
    log "创建隧道配置文件..."
    
    # 创建配置目录
    mkdir -p /etc/cloudflared
    
    # 移动凭证文件
    if [ -f "/root/.cloudflared/$TUNNEL_NAME.json" ]; then
        mv /root/.cloudflared/$TUNNEL_NAME.json /etc/cloudflared/
        log "凭证文件已移动"
    fi
    
    # 创建主配置
    cat > /etc/cloudflared/config.yml << EOF
tunnel: $TUNNEL_NAME
credentials-file: /etc/cloudflared/$TUNNEL_NAME.json

# SSH 服务配置
ingress:
  - hostname: $FULL_DOMAIN
    service: ssh://localhost:22
    originRequest:
      connectTimeout: 30s
      noTLSVerify: false

  # 默认回退
  - service: http_status:404
EOF
    
    log "配置文件已创建: /etc/cloudflared/config.yml"
}

# 配置 systemd 服务
setup_systemd() {
    log "配置 systemd 服务..."
    
    cat > /etc/systemd/system/cloudflared-ssh.service << EOF
[Unit]
Description=Cloudflare Tunnel SSH Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run $TUNNEL_NAME
Restart=always
RestartSec=5

# 资源限制
MemoryMax=256M
CPUQuota=100%

# 安全设置
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable cloudflared-ssh.service
    log "systemd 服务已配置"
}

# 启动服务
start_service() {
    log "启动 SSH 隧道服务..."
    
    systemctl start cloudflared-ssh.service
    sleep 3
    
    if systemctl is-active --quiet cloudflared-ssh.service; then
        log "服务启动成功"
    else
        error "服务启动失败"
    fi
}

# 验证配置
verify_configuration() {
    log "验证配置..."
    
    # 检查服务状态
    if systemctl is-active --quiet cloudflared-ssh.service; then
        log "✓ systemd 服务运行正常"
    else
        error "✗ systemd 服务异常"
    fi
    
    # 检查进程
    if pgrep -f "cloudflared.*$TUNNEL_NAME" > /dev/null; then
        log "✓ Cloudflared 进程运行正常"
    else
        warn "✗ Cloudflared 进程未找到"
    fi
    
    # 显示隧道信息
    info "隧道信息:"
    cloudflared tunnel list | grep -E "(NAME|$TUNNEL_NAME)" || true
}

# 生成连接指南
create_connection_guide() {
    log "生成连接指南..."
    
    cat > /root/ssh-tunnel-connection-guide.md << EOF
# 🌐 SSH 内网穿透连接指南

## 📋 连接信息
- **隧道名称**: $TUNNEL_NAME
- **访问域名**: $FULL_DOMAIN
- **本地服务**: SSH (端口 22)
- **创建时间**: $(date)

## 🔗 SSH 连接命令

### 方法1: 直接连接
\`\`\`bash
ssh username@$FULL_DOMAIN -p 22
\`\`\`

### 方法2: 使用 Cloudflared 客户端连接
\`\`\`bash
# 在客户端安装 cloudflared
cloudflared access ssh --hostname $FULL_DOMAIN
\`\`\`

### 方法3: 通过 Cloudflared 代理
\`\`\`bash
# 启动本地代理
cloudflared access tcp --hostname $FULL_DOMAIN --url localhost:2222

# 连接本地代理
ssh username@localhost -p 2222
\`\`\`

## 🛠️ 服务管理

### 查看状态
\`\`\`bash
systemctl status cloudflared-ssh.service
\`\`\`

### 重启服务
\`\`\`bash
systemctl restart cloudflared-ssh.service
\`\`\`

### 查看日志
\`\`\`bash
journalctl -u cloudflared-ssh.service -f
\`\`\`

## 🔒 安全建议

1. **使用密钥认证**
   \`\`\`bash
   ssh-copy-id username@$FULL_DOMAIN
   \`\`\`

2. **修改默认 SSH 端口** (可选)
   \`\`\`bash
   # 编辑 /etc/ssh/sshd_config
   Port 2222
   \`\`\`

3. **禁用密码登录** (推荐)
   \`\`\`bash
   PasswordAuthentication no
   \`\`\`

## 🌍 Cloudflare 仪表板

1. 访问: https://dash.cloudflare.com/
2. 进入 Zero Trust → Access → Tunnels
3. 查看隧道 $TUNNEL_NAME 状态

## 🐛 故障排除

### 连接失败
1. 检查隧道服务状态
2. 验证 DNS 解析
3. 检查 Cloudflare 仪表板

### 认证问题
1. 重新运行认证: \`cloudflared tunnel login\`
2. 检查凭证文件权限

---
*配置完成时间: $(date)*
EOF
    
    log "连接指南已保存: /root/ssh-tunnel-connection-guide.md"
}

# 显示完成信息
show_completion() {
    echo ""
    echo "========================================"
    echo "🎉 SSH 内网穿透配置完成！"
    echo "========================================"
    echo ""
    echo "📊 配置摘要:"
    echo "  隧道名称: $TUNNEL_NAME"
    echo "  访问地址: $FULL_DOMAIN"
    echo "  服务状态: $(systemctl is-active cloudflared-ssh.service)"
    echo ""
    echo "🔗 连接命令:"
    echo "  ssh your-username@$FULL_DOMAIN"
    echo ""
    echo "📚 详细指南:"
    echo "  查看 /root/ssh-tunnel-connection-guide.md"
    echo ""
    echo "🛠️ 管理命令:"
    echo "  systemctl status cloudflared-ssh.service"
    echo "  systemctl restart cloudflared-ssh.service"
    echo "  journalctl -u cloudflared-ssh.service -f"
    echo "========================================"
}

# 主函数
main() {
    show_welcome
    check_ssh_service
    install_cloudflared
    interactive_config
    authenticate_cloudflare
    create_tunnel
    create_config
    setup_systemd
    start_service
    verify_configuration
    create_connection_guide
    show_completion
}

main "$@"