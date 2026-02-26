#!/bin/bash
# 批量安装 OpenClaw 技能

skills=(
    "github"
    "discord" 
    "slack"
    "notion"
    "obsidian"
    "weather"
    "wechat-article-pro"
    "a-stock-monitor"
    "tech-news-digest"
    "media-news-digest"
    "openclaw-robotics"
    "tushare-finance"
    "git-pushing"
    "video"
    "memory-cache"
    "reporting"
    "empathy"
    "outreach"
    "crm-manager"
    "social-media-scheduler"
)

echo "开始安装技能..."

for skill in "${skills[@]}"; do
    echo "正在安装: $skill"
    npx clawhub install "$skill" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ $skill 安装成功"
    else
        echo "❌ $skill 安装失败"
    fi
done

echo "技能安装完成！"