#!/bin/bash
# OpenClaw 自动安装脚本
# 版本: 1.0
# 适用于: Ubuntu/Debian/CentOS

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

error() {
    echo -e "${RED}[错误]${NC} $1"
    exit 1
}

# 检测系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        error "无法检测操作系统"
    fi
    log "检测到系统: $OS $VER"
}

# 安装系统依赖
install_dependencies() {
    log "安装系统依赖..."
    
    if command -v apt &> /dev/null; then
        # Debian/Ubuntu
        apt update && apt upgrade -y
        apt install -y curl wget git build-essential python3 python3-pip \
                      sudo net-tools psmisc
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        yum update -y
        yum install -y curl wget git gcc-c++ make python3 python3-pip \
                      sudo net-tools psmisc
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
    
    # 验证安装
    if ! command -v node &> /dev/null; then
        error "Node.js 安装失败"
    fi
    
    log "Node.js 安装成功: $(node --version)"
}

# 安装 OpenClaw
install_openclaw() {
    log "安装 OpenClaw..."
    
    # 创建目录
    mkdir -p /root/.openclaw/workspace
    
    # 安装 OpenClaw
    npm install -g openclaw
    
    # 验证安装
    if ! command -v openclaw &> /dev/null; then
        error "OpenClaw 安装失败"
    fi
    
    log "OpenClaw 安装成功: $(openclaw --version)"
}

# 初始化工作空间
init_workspace() {
    log "初始化工作空间..."
    
    cd /root/.openclaw
    
    # 初始化配置
    if [ ! -f "openclaw.json" ]; then
        cat > openclaw.json << 'EOF'
{
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "0.0.0.0"
  },
  "agents": {
    "defaults": {
      "workspace": "/root/.openclaw/workspace",
      "heartbeat": {
        "every": "30m"
      }
    }
  },
  "commands": {
    "native": "auto",
    "restart": true
  }
}
EOF
        log "创建基础配置文件"
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
        log "创建身份文件"
    fi
}

# 配置系统服务
setup_service() {
    log "配置系统服务..."
    
    # 创建 systemd 服务
    cat > /etc/systemd/system/openclaw-gateway.service << 'EOF'
[Unit]
Description=OpenClaw Gateway Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/.openclaw
ExecStart=/usr/bin/openclaw gateway run
Restart=always
RestartSec=5
Environment=NODE_ENV=production

# 资源限制
MemoryHigh=800M
MemoryMax=1G

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载 systemd
    systemctl daemon-reload
    systemctl enable openclaw-gateway.service
    
    log "系统服务配置完成"
}

# 启动服务
start_service() {
    log "启动 OpenClaw 服务..."
    
    systemctl start openclaw-gateway.service
    sleep 5
    
    # 检查服务状态
    if systemctl is-active --quiet openclaw-gateway.service; then
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
        warn "端口 18789 未监听，检查服务状态"
    fi
    
    # 检查 CLI
    if openclaw status &> /dev/null; then
        log "✓ OpenClaw CLI 工作正常"
    else
        warn "OpenClaw CLI 检查失败"
    fi
    
    log "安装验证完成"
}

# 显示安装摘要
show_summary() {
    log "========================================"
    log "🎉 OpenClaw 安装完成！"
    log "========================================"
    log ""
    log "📊 安装摘要："
    log "  • 系统: $(uname -s -r)"
    log "  • Node.js: $(node --version)"
    log "  • OpenClaw: $(openclaw --version)"
    log "  • 服务状态: $(systemctl is-active openclaw-gateway.service)"
    log "  • 工作空间: /root/.openclaw/workspace"
    log "  • 控制面板: http://服务器IP:18789"
    log ""
    log "🔧 管理命令："
    log "  systemctl status openclaw-gateway.service  # 查看状态"
    log "  systemctl restart openclaw-gateway.service # 重启服务"
    log "  journalctl -u openclaw-gateway.service -f  # 查看日志"
    log "  openclaw status                            # CLI 状态"
    log ""
    log "📚 下一步："
    log "  1. 配置 Telegram 或其他渠道"
    log "  2. 安装技能: openclaw skill install weather"
    log "  3. 配置定时任务和自动化"
    log "========================================"
}

# 主安装流程
main() {
    log "开始 OpenClaw 自动安装..."
    
    detect_os
    install_dependencies
    install_nodejs
    install_openclaw
    init_workspace
    setup_service
    start_service
    verify_installation
    show_summary
    
    log "安装完成！"
}

# 执行主函数
main "$@"