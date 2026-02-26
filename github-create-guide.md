# 🔐 GitHub 仓库创建完整指南

## 🎯 两种创建方式

### 方式1: 使用 GitHub CLI（推荐）

**步骤1: 安装 GitHub CLI**
```bash
# 如果未安装
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**步骤2: 登录 GitHub**
```bash
# 交互式登录
gh auth login

# 选择:
# - GitHub.com
# - HTTPS
# - 通过浏览器登录
# - 授权访问
```

**步骤3: 创建仓库**
```bash
gh repo create openclaw --public --description "OpenClaw AI 助手部署和配置指南"
```

**步骤4: 上传文件**
```bash
cd /root/.openclaw
git init
git add .
git commit -m "初始提交: OpenClaw 完整配置方案"
git branch -M main
git push -u origin main
```

### 方式2: 手动网页创建

**步骤1: 访问创建页面**
打开: https://github.com/new

**步骤2: 填写仓库信息**
- **仓库名称**: `openclaw`
- **描述**: `OpenClaw AI 助手部署和配置指南 - 完整的系统集成方案`
- **公开/私有**: 公开
- **初始化**: 不添加 README（我们已经有完整文件）

**步骤3: 创建后获取仓库 URL**
创建完成后，你会得到类似这样的 URL:
`https://github.com/你的用户名/openclaw`

**步骤4: 上传本地文件**
```bash
cd /root/.openclaw
git init
git add .
git commit -m "初始提交: OpenClaw 完整配置方案"
git branch -M main
git remote add origin https://github.com/你的用户名/openclaw.git
git push -u origin main
```

## 🔧 故障排除

### 认证问题
```bash
# 检查认证状态
gh auth status

# 重新认证
gh auth logout
gh auth login
```

### 推送失败
```bash
# 强制推送（如果需要）
git push -f origin main

# 检查远程配置
git remote -v
```

### 权限问题
```bash
# 检查文件权限
ls -la

# 确保有写入权限
chmod +x scripts/*.sh
```

## 🎉 完成后的仓库特性

- 🌐 **公开访问**: 任何人都可以查看和使用
- 📚 **完整文档**: 专业的 README 和配置指南
- 🔧 **实用脚本**: 自动安装和部署脚本
- 🤖 **AI 集成**: 多模型和多渠道支持
- 🚀 **生产就绪**: 企业级部署方案

---

**选择其中一种方式，我来指导你完成创建！**