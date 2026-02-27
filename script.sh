#!/bin/bash

echo "开始彻底卸载 OpenCode..."

# 1. 删除用户根目录下的隐藏配置
rm -rf ~/.opencode
rm -rf ~/.opencode_history

# 2. 删除 VS Code 插件残留
rm -rf ~/.vscode/extensions/*opencode*

# 3. (仅限 macOS) 清理应用支持文件和偏好设置
if [[ "$OSTYPE" == "darwin"* ]]; then
    rm -rf ~/Library/Application\ Support/OpenCode
    rm -rf ~/Library/Caches/com.opencode.*
    rm -rf ~/Library/Preferences/com.opencode.plist
    echo "macOS 特定残留已清理。"
fi

# 4. 清理二进制文件（如果之前安装到了 /usr/local/bin）
sudo rm -f /usr/local/bin/opencode

echo "卸载完成！所有相关配置文件已移除。"
