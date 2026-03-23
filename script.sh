#!/bin/sh
# FRP 服务端 一键安装脚本 (Alpine Linux)
# 适配架构: x86_64(amd64) / aarch64
# 适配系统: Alpine Linux 3.15+

# ===================== 可自定义配置 =====================
FRP_VERSION="0.59.0"          # FRP版本号，可修改为最新稳定版
BIND_PORT=7000               # 客户端连接端口
HTTP_PORT=80                 # HTTP穿透端口
HTTPS_PORT=443               # HTTPS穿透端口
CUSTOM_TOKEN="AIshy980925."  # 认证密码（务必修改！）
INSTALL_DIR="/opt/frp"       # 安装目录
# ========================================================

# 颜色输出配置
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误：请使用root用户运行此脚本！${NC}"
    exit 1
fi

# 检测系统架构
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64) FRP_ARCH="amd64" ;;
    aarch64) FRP_ARCH="arm64" ;;
    *)
        echo -e "${RED}错误：不支持的系统架构 ${ARCH}！${NC}"
        exit 1
        ;;
esac

# 定义文件路径
FRP_FILE="frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz"
FRP_DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FRP_FILE}"

# 安装基础依赖
echo -e "${GREEN}===== 安装基础依赖（wget/tar/curl）=====${NC}"
apk add --no-cache wget tar curl >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：依赖安装失败！${NC}"
    exit 1
fi

# 创建安装目录
echo -e "${GREEN}===== 创建安装目录 ${INSTALL_DIR} =====${NC}"
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR} || exit 1

# 下载FRP安装包
echo -e "${GREEN}===== 下载FRP v${FRP_VERSION} (${FRP_ARCH}) =====${NC}"
if [ ! -f "${FRP_FILE}" ]; then
    wget -q --show-progress "${FRP_DOWNLOAD_URL}" -O "${FRP_FILE}"
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误：FRP安装包下载失败！${NC}"
        exit 1
    fi
fi

# 解压安装包
echo -e "${GREEN}===== 解压安装包 =====${NC}"
tar -zxf "${FRP_FILE}" --strip-components 1 >/dev/null 2>&1
rm -f "${FRP_FILE}"

# 生成FRP服务端配置文件
echo -e "${GREEN}===== 生成服务端配置文件 =====${NC}"
cat > frps.toml << EOF
bindPort = ${BIND_PORT}
token = "${CUSTOM_TOKEN}"
vhostHTTPPort = ${HTTP_PORT}
vhostHTTPSPort = ${HTTPS_PORT}
EOF

# 配置openrc服务
echo -e "${GREEN}===== 配置openrc服务 =====${NC}"
cat > /etc/init.d/frps << EOF
#!/sbin/openrc-run

name="frps"
description="FRP Server Service"
command="${INSTALL_DIR}/frps"
command_args="-c ${INSTALL_DIR}/frps.toml"
command_background="yes"
pidfile="/run/\${name}.pid"

depend() {
    need net
    use logger
}
EOF

# 赋予服务执行权限
chmod +x /etc/init.d/frps

# 启动服务并设置开机自启
echo -e "${GREEN}===== 启动FRP服务并设置开机自启 =====${NC}"
rc-update add frps default >/dev/null 2>&1
rc-service frps start >/dev/null 2>&1

# 检查服务状态
if rc-service frps status | grep -q "started"; then
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✅ FRP服务端安装成功！${NC}"
    echo -e "${GREEN}📁 配置文件路径：${INSTALL_DIR}/frps.toml${NC}"
    echo -e "${GREEN}🔧 服务管理命令：${NC}"
    echo -e "  启动：rc-service frps start${NC}"
    echo -e "  停止：rc-service frps stop${NC}"
    echo -e "  重启：rc-service frps restart${NC}"
    echo -e "  状态：rc-service frps status${NC}"
    echo -e "${GREEN}=========================================${NC}"
else
    echo -e "${RED}❌ FRP服务启动失败！${NC}"
    echo -e "🔍 查看日志：rc-service frps log"
    exit 1
fi
