#!/bin/bash
# OpenClaw 自动更新脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查更新状态
check_updates() {
    log "每日更新检查..."
    
    # 使用 dry-run 模式检查是否有更新
    DRY_RUN_OUTPUT=$(openclaw update --dry-run 2>&1)
    
    # 检查是否有新版本
    if echo "$DRY_RUN_OUTPUT" | grep -q "No changes were applied"; then
        log "已是最新版本: $(openclaw --version)"
        return 1
    else
        CURRENT_VERSION=$(openclaw --version)
        log "发现新版本可用!"
        log "当前版本: $CURRENT_VERSION"
        return 0
    fi
}

# 执行更新
perform_update() {
    log "开始自动更新..."
    
    # 备份当前配置
    log "备份配置文件..."
    cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)
    
    # 执行更新（非交互模式）
    log "执行更新命令..."
    openclaw update --yes --no-restart
    
    if [ $? -eq 0 ]; then
        log "更新成功完成"
        
        # 重启服务以应用更新
        log "重启网关服务..."
        systemctl --user restart openclaw-gateway.service
        
        sleep 5
        
        if systemctl --user is-active openclaw-gateway.service; then
            log "服务重启成功"
            log "新版本: $(openclaw --version)"
            return 0
        else
            error "服务重启失败"
            return 1
        fi
    else
        error "更新失败"
        return 1
    fi
}

# 主函数
main() {
    log "=== OpenClaw 每日自动更新检查 ==="
    
    if check_updates; then
        log "发现新版本，准备执行更新..."
        perform_update
    else
        log "今日检查完成，已是最新版本"
    fi
    
    log "=== 每日更新检查完成 ==="
}

# 执行主函数
main "$@" 2>&1 | tee -a /var/log/openclaw-update.log