# 🚀 OpenClaw 部署指南

## 📋 部署选项

### 1. 快速部署（推荐）
使用自动安装脚本快速部署：

```bash
# 一键安装
curl -fsSL https://raw.githubusercontent.com/your-username/openclaw/main/scripts/install.sh | bash
```

### 2. 手动部署
适合有经验的用户或定制化需求：

```bash
# 克隆仓库
git clone https://github.com/your-username/openclaw.git
cd openclaw

# 运行安装脚本
chmod +x scripts/install.sh
./scripts/install.sh
```

### 3. Docker 部署
使用 Docker 容器化部署：

```bash
# 构建镜像
docker build -t openclaw .

# 运行容器
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -v ~/.openclaw:/app/config \
  openclaw
```

## 🛠️ 系统要求

### 最低要求
- **操作系统**: Ubuntu 20.04+, Debian 11+, CentOS 8+
- **内存**: 2GB RAM
- **存储**: 10GB 可用空间
- **网络**: 稳定的互联网连接

### 推荐配置
- **操作系统**: Ubuntu 22.04 LTS
- **内存**: 4GB RAM 或更多
- **存储**: 20GB SSD
- **网络**: 100Mbps+ 带宽

## ⚙️ 配置步骤

### 1. 基础配置
编辑 `~/.openclaw/openclaw.json`:

```json
{
  "models": {
    "providers": {
      "OpenAI": {
        "apiKey": "your-openai-api-key"
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "your-telegram-bot-token",
      "allowFrom": ["your-chat-id"]
    }
  }
}
```

### 2. 消息渠道配置

#### Telegram 配置
1. 创建 Telegram 机器人 via @BotFather
2. 获取 bot token
3. 获取你的 chat ID
4. 更新配置文件

#### Discord 配置
1. 创建 Discord 应用
2. 添加机器人权限
3. 获取 bot token 和服务器 ID
4. 更新配置文件

### 3. 模型配置

#### OpenAI 模型
```json
{
  "id": "gpt-4",
  "name": "OpenAI / gpt-4",
  "input": ["text", "image"]
}
```

#### DeepSeek 模型
```json
{
  "id": "deepseek-v3.2", 
  "name": "OpenAI / deepseek-v3.2",
  "input": ["text", "image"]
}
```

## 🔧 系统服务管理

### 服务命令
```bash
# 启动服务
systemctl --user start openclaw-gateway.service

# 停止服务
systemctl --user stop openclaw-gateway.service

# 重启服务
systemctl --user restart openclaw-gateway.service

# 查看状态
systemctl --user status openclaw-gateway.service

# 查看日志
journalctl --user -u openclaw-gateway.service -f
```

### 开机自启
```bash
# 启用服务
systemctl --user enable openclaw-gateway.service

# 禁用服务
systemctl --user disable openclaw-gateway.service
```

## 📊 监控和维护

### 健康检查
```bash
# 运行健康检查脚本
./scripts/health-check.sh

# 检查系统状态
openclaw status
```

### 日志管理
```bash
# 查看服务日志
journalctl --user -u openclaw-gateway.service --since "1 hour ago"

# 查看应用日志
tail -f ~/.openclaw/logs/gateway.log
```

### 备份配置
```bash
# 备份配置文件
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.$(date +%Y%m%d)

# 恢复配置
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
```

## 🐛 故障排除

### 常见问题

#### 服务启动失败
```bash
# 检查日志
journalctl --user -u openclaw-gateway.service -f

# 检查端口占用
netstat -tlnp | grep 18789
```

#### 消息发送失败
```bash
# 测试消息发送
openclaw message send --channel telegram --to CHAT_ID --message "测试"

# 检查渠道配置
openclaw gateway status
```

#### 模型连接失败
```bash
# 检查 API 密钥
openclaw config get models.providers.OpenAI.apiKey

# 测试网络连接
curl -I https://api.openai.com
```

### 性能优化

#### 内存优化
```bash
# 调整内存限制
systemctl --user set-property openclaw-gateway.service MemoryMax=800M
```

#### 网络优化
```bash
# 配置代理（如需要）
export HTTPS_PROXY=http://proxy-server:port
```

## 🔒 安全建议

### 访问控制
- 使用防火墙限制端口访问
- 配置可信代理列表
- 定期轮换 API 密钥

### 数据保护
- 备份重要配置文件
- 加密敏感数据
- 定期更新系统

## 📈 扩展部署

### 多实例部署
```bash
# 创建多个实例目录
mkdir -p ~/.openclaw-instance{1,2}

# 配置不同端口和环境
openclaw gateway run --port 18790 --workspace ~/.openclaw-instance1
```

### 负载均衡
使用 Nginx 进行负载均衡：

```nginx
upstream openclaw {
    server 127.0.0.1:18789;
    server 127.0.0.1:18790;
}

server {
    listen 80;
    location / {
        proxy_pass http://openclaw;
    }
}
```

---
*部署完成后，你可以开始使用 OpenClaw 的各种功能了！*