#!/bin/bash
# 宜宾天气推送脚本

# 获取天气信息
WEATHER=$(curl -s "wttr.in/宜宾?format=3")

# 记录日志
echo "$(date): 天气推送 - $WEATHER" >> /var/log/weather-push.log

# 发送到 Telegram
openclaw message send --channel telegram --to 1055592339 --message "🌤️ 宜宾天气推送: $WEATHER" --target 1055592339

echo "推送完成: $WEATHER"