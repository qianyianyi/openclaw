#!/bin/bash
# OpenClaw 自动安装脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[NOTE]${NC} $1"; }

# 显示欢迎信息
show_welcome() {
    echo "========================================"
    echo "🦞 OpenClaw 自动安装脚本"
    echo "========================================"
    echo ""
    echo "这个脚本将自动安装和配置:"
    echo "  • OpenClaw AI 助手"
    echo "  • 系统服务配置"
    echo "  • 基础环境设置"
    echo ""
}

# 检查系统
check_system() {
    log "检查系统环境..."
    
    # 检查操作系统
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        info "操作系统: $OS $VER"
    else
        warn "无法检测具体操作系统"
    fi
    
    # 检查 root 权限
    if [ "$EUID" -ne 0 ]; then
        warn "建议使用 root 权限运行以获得最佳体验"
    fi
}

# 安装系统依赖
install_dependencies() {
    log "安装系统依赖..."
    
    if command -v apt &> /dev/null; then
        # Debian/Ubuntu
        apt update && apt upgrade -y
        apt install -y curl wget git build-essential python3 python3-pip sudo
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        yum update -y
        yum install -y curl wget git gcc-c++ make python3 python3-pip sudo
    elif command -v dnf &> /dev/null; then
        # Fedora
        dnf update -y
        dnf install -y curl wget git gcc-c++ make python3 python3-pip sudo
    else
        error "不支持的包管理器"
    fi
}

# 安装 Node.js
install_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        log "Node.js 已安装: $NODE_VERSION"
        return
    fi
    
    log "安装 Node.js..."
    
    if command -v apt &> /dev/null; then
        # Ubuntu/Debian
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt install -y nodejs
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
        yum install -y nodejs
    fi
    
    if command -v node &> /dev/null; then
        log "Node.js 安装成功: $(node --version)"
    else
        error "Node.js 安装失败"
    fi
}

# 安装 OpenClaw
install_openclaw() {
    log "安装 OpenClaw..."
    
    # 创建目录
    mkdir -p ~/.openclaw/workspace
    
    # 安装 OpenClaw
    npm install -g openclaw
    
    if command -v openclaw &> /dev/null; then
        log "OpenClaw 安装成功: $(openclaw --version)"
    else
        error "OpenClaw 安装失败"
    fi
}

# 初始化配置
init_config() {
    log "初始化配置..."
    
    cd ~/.openclaw
    
    # 复制示例配置
    if [ ! -f "openclaw.json" ]; then
        cp ../configs/openclaw.json ./
        log "配置文件已创建"
    fi
    
    # 创建工作空间文件
    if [ ! -f "workspace/SOUL.md" ]; then
        cat > workspace/SOUL.md << 'EOF'
# SOUL.md - AI 助手身份

## 核心原则
- 实用主义：直接解决问题
- 资源优化：高效利用系统资源  
- 安全第一：保护用户数据和系统安全
- 持续学习：从交互中改进服务

## 服务承诺
- 24/7 可用性
- 快速响应
- 技术专业
- 用户至上
EOF
        log "身份文件已创建"
    fi
}

# 配置系统服务
setup_systemd() {
    log "配置系统服务..."
    
    # 创建用户 systemd 目录
    mkdir -p ~/.config/systemd/user
    
    # 创建服务文件
    cat > ~/.config/systemd/user/openclaw-gateway.service << EOF
[Unit]
Description=OpenClaw Gateway Service
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=~/.openclaw
ExecStart=/usr/bin/openclaw gateway run
Restart=always
RestartSec=5
Environment=NODE_ENV=production

# 资源限制
MemoryHigh=800M
MemoryMax=1G

[Install]
WantedBy=default.target
EOF
    
    # 启用 linger 以便用户服务在登录后运行
    sudo loginctl enable-linger $(whoami)
    
    # 重新加载并启用服务
    systemctl --user daemon-reload
    systemctl --user enable openclaw-gateway.service
    
    log "系统服务配置完成"
}

# 启动服务
start_service() {
    log "启动 OpenClaw 服务..."
    
    systemctl --user start openclaw-gateway.service
    sleep 5
    
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        log "服务启动成功"
    else
        error "服务启动失败"
    fi
}

# 验证安装
verify_installation() {
    log "验证安装..."
    
    # 检查进程
    if pgrep -f "openclaw gateway" > /dev/null; then
        log "✓ OpenClaw 进程运行中"
    else
        error "✗ OpenClaw 进程未运行"
    fi
    
    # 检查端口
    if netstat -tln | grep -q ":18789"; then
        log "✓ 端口 18789 监听中"
    else
        warn "端口 18789 未监听"
    fi
    
    # 检查 CLI
    if openclaw status &> /dev/null; then
        log "✓ OpenClaw CLI 工作正常"
    else
        warn "OpenClaw CLI 检查失败"
    fi
}

# 显示完成信息
show_completion() {
    echo ""
    echo "========================================"
    echo "🎉 OpenClaw 安装完成！"
    echo "========================================"
    echo ""
    echo "📊 安装摘要："
    echo "  • 系统: $(uname -s -r)"
    echo "  • Node.js: $(node --version)"
    echo "  • OpenClaw: $(openclaw --version)"
    echo "  • 服务状态: $(systemctl --user is-active openclaw-gateway.service)"
    echo "  • 工作空间: ~/.openclaw/workspace"
    echo "  • 控制面板: http://localhost:18789"
    echo ""
    echo "🔧 下一步操作："
    echo "  1. 编辑 ~/.openclaw/openclaw.json 配置模型和渠道"
    echo "  2. 配置 Telegram 机器人或其他消息渠道"
    echo "  3. 安装技能: openclaw skill install weather"
    echo "  4. 测试消息发送"
    echo ""
    echo "🛠️ 管理命令："
    echo "  systemctl --user status openclaw-gateway.service"
    echo "  systemctl --user restart openclaw-gateway.service"
    echo "  journalctl --user -u openclaw-gateway.service -f"
    echo "  openclaw status"
    echo "========================================"
}

# 主函数
main() {
    show_welcome
    check_system
    install_dependencies
    install_nodejs
    install_openclaw
    init_config
    setup_systemd
    start_service
    verify_installation
    show_completion
}

main "$@"