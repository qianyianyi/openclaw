# 🚀 OpenClaw 远程服务器安装指南

## 📋 前提条件
- 目标服务器：Linux 系统（Ubuntu/Debian/CentOS）
- SSH 访问权限
- root 或 sudo 权限
- 至少 2GB 可用内存

## 🔧 快速安装脚本

### 1. 基础环境准备
```bash
#!/bin/bash
# openclaw-base-setup.sh

# 更新系统
apt update && apt upgrade -y

# 安装依赖
apt install -y curl wget git build-essential python3 python3-pip

# 安装 Node.js (如果未安装)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 安装 PM2 用于进程管理
npm install -g pm2

# 验证安装
node --version
npm --version
```

### 2. OpenClaw 安装脚本
```bash
#!/bin/bash
# openclaw-install.sh

# 创建 OpenClaw 目录
mkdir -p ~/.openclaw
cd ~/.openclaw

# 安装 OpenClaw CLI
npm install -g openclaw

# 初始化工作空间
openclaw init --workspace ~/.openclaw/workspace

# 创建 systemd 服务文件
cat > /etc/systemd/system/openclaw-gateway.service << 'EOF'
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/.openclaw
ExecStart=/usr/bin/openclaw gateway run
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd
systemctl daemon-reload
systemctl enable openclaw-gateway.service

# 启动服务
systemctl start openclaw-gateway.service
```

### 3. 配置脚本
```bash
#!/bin/bash
# openclaw-configure.sh

# 检查服务状态
systemctl status openclaw-gateway.service

# 创建基础配置
cat > ~/.openclaw/openclaw.json << 'EOF'
{
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "0.0.0.0"
  },
  "agents": {
    "defaults": {
      "workspace": "/root/.openclaw/workspace"
    }
  }
}
EOF

# 重启服务应用配置
systemctl restart openclaw-gateway.service

# 检查端口监听
netstat -tlnp | grep 18789
```

## 🔍 验证安装

### 检查服务状态
```bash
# 服务状态
systemctl status openclaw-gateway.service

# 进程检查
ps aux | grep openclaw

# 端口检查
netstat -tlnp | grep 18789

# CLI 测试
openclaw status
```

### 测试功能
```bash
# 创建测试技能
openclaw skill install weather

# 测试消息发送
openclaw message send --channel telegram --to YOUR_CHAT_ID --message "OpenClaw 安装成功"
```

## 🔒 安全配置

### 防火墙设置
```bash
# 开放 OpenClaw 端口
ufw allow 18789/tcp

# 或者使用 iptables
iptables -A INPUT -p tcp --dport 18789 -j ACCEPT
```

### 安全加固
```bash
# 限制访问 IP（可选）
iptables -A INPUT -p tcp --dport 18789 -s YOUR_TRUSTED_IP -j ACCEPT
iptables -A INPUT -p tcp --dport 18789 -j DROP
```

## 📊 安装后检查清单

- [ ] 系统依赖安装完成
- [ ] Node.js 版本 >= 16
- [ ] OpenClaw CLI 安装成功
- [ ] 服务正常运行
- [ ] 端口 18789 监听中
- [ ] 工作空间创建成功
- [ ] 基础配置就绪

## 🛠️ 故障排除

### 常见问题
1. **端口占用**：更改 `openclaw.json` 中的端口号
2. **权限问题**：确保使用 root 或适当权限
3. **网络问题**：检查防火墙和网络配置
4. **内存不足**：增加交换空间或优化配置

### 日志检查
```bash
# 查看服务日志
journalctl -u openclaw-gateway.service -f

# OpenClaw 日志
tail -f ~/.openclaw/logs/*.log
```

## 🔄 更新和维护

### 更新 OpenClaw
```bash
npm update -g openclaw
systemctl restart openclaw-gateway.service
```

### 备份配置
```bash
# 备份重要文件
tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw
```

---
*安装指南版本：1.0 | 最后更新：2026-02-25*