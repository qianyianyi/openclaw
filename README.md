# 🦞 OpenClaw - AI 助手部署和配置指南

![OpenClaw Version](https://img.shields.io/badge/OpenClaw-2026.2.24-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Docker-orange)

OpenClaw 是一个功能强大的 AI 助手系统，支持多模型、多渠道消息和自动化任务。本仓库提供完整的部署、配置和维护指南。

## ✨ 特性

### 🤖 AI 模型支持
- **DeepSeek V3.2** - 高性能语言模型
- **OpenAI 系列** - GPT、Claude 等模型
- **多模型切换** - 灵活的模型配置

### 📱 消息渠道
- **Telegram** - 完整的机器人集成
- **Discord** - 社区平台支持
- **Slack** - 工作协作集成
- **Webhooks** - 自定义 API 集成

### 🚀 部署方式
- **Systemd 服务** - 生产环境部署
- **Docker 容器** - 快速部署方案
- **裸机安装** - 直接系统安装

### 🔧 自动化功能
- **定时任务** - Cron 集成
- **健康检查** - 系统监控
- **自动更新** - 版本管理
- **内网穿透** - Cloudflare Tunnel

## 🛠️ 快速开始

### 环境要求
- **操作系统**: Ubuntu 20.04+, Debian 11+, CentOS 8+
- **内存**: 至少 2GB RAM
- **存储**: 至少 10GB 可用空间
- **网络**: 稳定的互联网连接

### 一键安装
```bash
# 下载安装脚本
curl -fsSL https://raw.githubusercontent.com/your-username/openclaw/main/scripts/install.sh | bash

# 或手动下载后执行
chmod +x scripts/install.sh
./scripts/install.sh
```

### 手动安装
```bash
# 1. 安装依赖
sudo apt update && sudo apt install -y nodejs npm git curl

# 2. 安装 OpenClaw
sudo npm install -g openclaw

# 3. 初始化配置
openclaw init --workspace ~/.openclaw/workspace

# 4. 配置系统服务
sudo ./scripts/setup-systemd.sh
```

## 📁 项目结构

```
openclaw/
├── configs/                 # 配置文件
│   ├── openclaw.json       # 主配置示例
│   ├── systemd/            # 服务配置
│   └── cron/               # 定时任务
├── scripts/                # 实用脚本
│   ├── install.sh          # 自动安装
│   ├── setup-systemd.sh    # 服务配置
│   ├── auto-update.sh      # 自动更新
│   └── health-check.sh     # 健康检查
├── docs/                   # 文档指南
│   ├── installation.md     # 安装指南
│   ├── configuration.md    # 配置指南
│   ├── skills.md          # 技能使用
│   └── troubleshooting.md # 故障排除
└── examples/              # 使用示例
    ├── telegram-setup.md   # Telegram 配置
    ├── cf-tunnel.md        # 内网穿透
    └── multi-channel.md    # 多渠道
```

## ⚙️ 配置指南

### 基础配置
编辑 `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/deepseek-v3.2"
      },
      "workspace": "/path/to/workspace"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN"
    }
  }
}
```

### 系统服务
```bash
# 启用系统服务
sudo systemctl enable openclaw-gateway.service
sudo systemctl start openclaw-gateway.service

# 查看服务状态
sudo systemctl status openclaw-gateway.service
```

## 🎯 使用示例

### 消息发送
```bash
# 发送消息到 Telegram
openclaw message send --channel telegram --to CHAT_ID --message "Hello World!"

# 使用技能
openclaw skill install weather
openclaw skill run weather --location "北京"
```

### 自动化任务
```bash
# 设置定时天气推送
0 */6 * * * /path/to/scripts/weather-push.sh

# 健康检查
*/30 * * * * /path/to/scripts/health-check.sh
```

## 🔧 维护和监控

### 健康检查
```bash
# 运行健康检查
./scripts/health-check.sh

# 查看系统状态
openclaw status
```

### 日志查看
```bash
# 服务日志
journalctl -u openclaw-gateway.service -f

# OpenClaw 日志
tail -f ~/.openclaw/logs/*.log
```

### 更新管理
```bash
# 手动更新
openclaw update

# 自动更新（配置后）
./scripts/auto-update.sh
```

## 🤝 贡献指南

我们欢迎各种形式的贡献！

### 报告问题
- 使用 [Issues](https://github.com/your-username/openclaw/issues) 报告 bug
- 提供详细的系统信息和错误日志

### 功能请求
- 在 Discussions 中提出新功能想法
- 参与功能设计和讨论

### 代码贡献
1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [OpenClaw 官方项目](https://github.com/openclaw/openclaw)
- 所有贡献者和用户
- AI 模型提供商

## 🔗 相关链接

- [官方文档](https://docs.openclaw.ai)
- [社区 Discord](https://discord.gg/clawd)
- [技能市场](https://clawhub.com)

---

**⭐ 如果这个项目对你有帮助，请给个 Star！**