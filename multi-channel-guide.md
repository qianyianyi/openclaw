# 📱 OpenClaw 多消息渠道配置指南

## 🎯 支持的渠道类型

### 即时通讯平台
- **Telegram** - 当前已配置
- **Discord** - 游戏社区平台
- **Slack** - 工作协作平台
- **WhatsApp** - 全球通讯应用
- **Signal** - 安全加密通讯
- **iMessage** - Apple 生态系统

### 社交平台
- **Twitter/X** - 社交媒体
- **Google Chat** - Google 工作区
- **IRC** - 传统聊天协议

### 企业平台
- **Microsoft Teams** - 企业协作
- **Webhooks** - 自定义 API 集成

## 🔧 配置方法

### 1. Discord 配置示例
```json
{
  "channels": {
    "telegram": { ... },
    "discord": {
      "enabled": true,
      "botToken": "YOUR_DISCORD_BOT_TOKEN",
      "clientId": "YOUR_CLIENT_ID",
      "guildId": "YOUR_SERVER_ID",
      "dmPolicy": "allowlist",
      "allowFrom": ["USER_ID_1", "USER_ID_2"]
    }
  },
  "plugins": {
    "allow": ["telegram", "discord"],
    "entries": {
      "telegram": { "enabled": true },
      "discord": { "enabled": true }
    }
  }
}
```

### 2. Slack 配置示例
```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "xoxb-YOUR_SLACK_BOT_TOKEN",
      "appToken": "xapp-YOUR_APP_TOKEN",
      "signingSecret": "YOUR_SIGNING_SECRET",
      "dmPolicy": "allowlist",
      "allowFrom": ["USER_ID"]
    }
  }
}
```

### 3. WhatsApp 配置示例
```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "accountSid": "YOUR_TWILIO_ACCOUNT_SID",
      "authToken": "YOUR_TWILIO_AUTH_TOKEN",
      "phoneNumber": "+1234567890",
      "dmPolicy": "allowlist"
    }
  }
}
```

## 🚀 多渠道优势

### 消息分发策略
- **广播模式** - 同时发送到所有渠道
- **条件路由** - 根据内容类型选择渠道
- **优先级路由** - 紧急消息使用特定渠道

### 使用场景
- **个人使用** - Telegram + Discord
- **团队协作** - Slack + Discord
- **家庭使用** - WhatsApp + Telegram
- **企业环境** - Teams + Slack

## ⚙️ 配置步骤

### 步骤1: 获取渠道凭证
1. **Discord**: 创建 Discord 应用和机器人
2. **Slack**: 创建 Slack 应用和机器人
3. **WhatsApp**: 注册 Twilio 账户
4. **其他**: 按照各平台开发者文档

### 步骤2: 修改配置文件
```bash
# 备份当前配置
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.backup

# 编辑配置添加新渠道
nano /root/.openclaw/openclaw.json
```

### 步骤3: 重启服务
```bash
systemctl --user restart openclaw-gateway.service
```

## 🔒 安全配置

### 权限控制
- **allowlist** - 只允许特定用户
- **pairing** - 需要配对确认
- **open** - 对所有人开放

### 消息策略
- **dmPolicy** - 私聊消息策略
- **groupPolicy** - 群组消息策略
- **streaming** - 流式消息设置

## 📊 渠道特性对比

| 渠道 | 优势 | 限制 | 适用场景 |
|------|------|------|----------|
| **Telegram** | 功能丰富，API稳定 | 需要翻墙 | 个人使用，技术社区 |
| **Discord** | 社区功能强大 | 游戏导向 | 游戏社区，技术社群 |
| **Slack** | 企业级功能 | 付费限制 | 工作团队，项目管理 |
| **WhatsApp** | 用户基数大 | 商业API收费 | 家庭朋友，日常通讯 |
| **Signal** | 安全性最高 | 用户较少 | 安全通讯，隐私保护 |

## 🛠️ 故障排除

### 常见问题
1. **凭证错误** - 检查 API 密钥和权限
2. **网络连接** - 确保服务器能访问外部 API
3. **权限不足** - 检查机器人权限设置
4. **配置格式** - 验证 JSON 语法正确

### 测试连接
```bash
# 测试消息发送
openclaw message send --channel discord --to USER_ID --message "测试消息"

# 查看渠道状态
openclaw gateway status
```

---
*根据你的需求，我可以帮你配置特定的消息渠道！*