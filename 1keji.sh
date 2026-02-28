#!/bin/bash

# 如果没有安装curl，则尝试自动安装
if ! command -v curl &>/dev/null; then
    echo "curl 未安装，正在尝试自动安装..."
    if [ -x "$(command -v apt-get)" ]; then
        apt-get update && apt-get install -y curl
    elif [ -x "$(command -v yum)" ]; then
        yum install -y curl
    else
        echo "无法确定包管理器，请手动安装curl"
        exit 1
    fi
fi

alias_removed=0
# 自动生成的统一脚本

while true; do
    clear
    echo -e "\033[1;32m╔══════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;32m║\033[0m\033[1;37m          一点科技 综合 管理脚本          \033[0m\033[1;32m║\033[0m"
    echo -e "\033[1;32m╠══════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;32m║\033[0m\033[1;37m 作者：一点科技                           \033[0m\033[1;32m║\033[0m"
    echo -e "\033[1;32m║\033[0m\033[1;37m 频道：https://www.youtube.com/@1keji_net \033[0m\033[1;32m║\033[0m"
    echo -e "\033[1;32m║\033[0m\033[1;37m TG群：  https://t.me/tg_1keji            \033[0m\033[1;32m║\033[0m"
    echo -e "\033[1;32m║\033[0m\033[1;37m 网站：  https://1keji.net                \033[0m\033[1;32m║\033[0m"
    echo -e "\033[1;32m╚══════════════════════════════════════════╝\033[0m"

    echo -e "\033[1;33m请选择一个功能：\033[0m"
    echo -e "\033[1;37m1: nginx管理\033[0m"
    echo -e "\033[1;37m2: php管理\033[0m"
    echo -e "\033[1;37m3: docker管理\033[0m"
    echo -e "\033[1;37m4: mysql管理（基于docker）\033[0m"
    echo -e "\033[1;37m5: ssl证书下载\033[0m"
    echo -e "\033[1;37m6: 备份功能\033[0m"
    echo -e "\033[1;37m8: app管理\033[0m"
    echo -e "\033[1;37m9: BBR\033[0m"
    echo -e "\033[1;32m----------------------------------------\033[0m"
    echo -e "\033[1;37m11: cloudreve网盘\033[0m"
    echo -e "\033[1;37m12: 哪吒监控（综合管理）\033[0m"
    echo -e "\033[1;37m13: 个人导航站\033[0m"
    echo -e "\033[1;37m14: 图床\033[0m"
    echo -e "\033[1;37m15: 现代图床（新图床）\033[0m"
    echo -e "\033[1;37m16: 现代图床docker版\033[0m"
    echo -e "\033[1;32m----------------------------------------\033[0m"
    echo -e "\033[1;37m41: ssh防护\033[0m"
    echo -e "\033[1;37m42: 流量控制\033[0m"
    echo -e "\033[1;32m----------------------------------------\033[0m"
    echo -e "\033[1;37m99: nginx整合测试版\033[0m"
    echo -e "\033[1;32m----------------------------------------\033[0m"
    echo -e "\033[1;37m101: dd系统\033[0m"
    echo -e "\033[1;32m----------------------------------------\033[0m"
    echo -e "\033[1;37m209: bbr+队列测试版\033[0m"
    echo -e "\033[1;37mdel: 删除快捷命令\033[0m"
    echo -e "\033[1;37m0: 退出\033[0m"
    read -p "请输入对应的数字或命令: " choice
    case $choice in
        1 )
            bash <(curl -sL "https://sh.1keji.net/f/n5num/nginx_1kejiv1.sh")
            continue
            ;;
        2 )
            bash <(curl -sL "https://sh.1keji.net/f/XDBfO/manage_php.sh")
            continue
            ;;
        3 )
            bash <(curl -sL "https://sh.1keji.net/f/w0ty/docker_1keji.sh")
            continue
            ;;
        4 )
            bash <(curl -sL "https://sh.1keji.net/f/734UZ/manage_mysql.sh")
            continue
            ;;
        5 )
            wget -O ssl_get.sh "https://sh.1keji.net/f/jESR/ssl_get.sh" && chmod +x ssl_get.sh && ./ssl_get.sh
            continue
            ;;
        6 )
            wget -O bf_1keji.sh "https://sh.1keji.net/f/xG5Cx/bf_1keji.sh" && chmod +x bf_1keji.sh && ./bf_1keji.sh
            continue
            ;;
        8 )
            bash <(curl -sL "https://sh.1keji.net/f/y8OHL/app_manager.sh")
            continue
            ;;
        9 )
            bash <(curl -sL "https://sh.1keji.net/f/znF4/bbr_1keji.sh")
            continue
            ;;
        11 )
            bash <(curl -sL "https://sh.1keji.net/f/qjjuX/cloudreve_manager.sh")
            continue
            ;;
        12 )
            bash <(curl -sL "https://sh.1keji.net/f/GzUA/neza_1keji.sh")
            continue
            ;;
        13 )
            bash <(curl -sL "https://sh.1keji.net/f/82QfY/nav_1keji.sh")
            continue
            ;;
        14 )
            bash <(curl -sL "https://sh.1keji.net/f/4xOtl/image_keji.sh")
            continue
            ;;
        15 )
            bash <(curl -sL "https://sh.1keji.net/f/0RWSm/modern-images.sh")
            continue
            ;;
        16 )
            bash <(curl -sL "https://sh.1keji.net/f/jREfR/deploy_modern_images.sh")
            continue
            ;;
        41 )
            bash <(curl -sL "https://sh.1keji.net/f/L1hQ/fail2ban_manager.sh")
            continue
            ;;
        42 )
            bash <(curl -sL "https://sh.1keji.net/f/MXiz/llgk.sh")
            continue
            ;;
        99 )
            bash <(curl -sL "https://sh.1keji.net/f/r07C2/nginx_1keji_integrated.sh")
            continue
            ;;
        101 )
            bash <(curl -sL "https://sh.1keji.net/f/vglFA/dd_1keji.sh")
            continue
            ;;
        209 )
            bash <(curl -sL "https://sh.1keji.net/f/zmEI4/bbr_1keji.sh")
            continue
            ;;
        del )
            if [ -f ~/.bashrc ]; then
                sed -i "/function keji()/d" ~/.bashrc
                echo -e "\033[1;31m已删除快捷命令 keji，请重新启动 shell 以生效\033[0m"
                alias_removed=1
            else
                echo -e "\033[1;31m~/.bashrc 文件不存在\033[0m"
            fi
            ;;
        0 )
            echo -e "\033[1;31m退出脚本\033[0m"
            break
            ;;
        * )
            echo -e "\033[1;31m无效的选择，请重新输入。\033[0m"
            ;;
    esac
    if [ "$choice" != "0" ]; then
        echo
        read -p "按回车键继续..." 
    fi
done

# 快捷命令调出脚本菜单功能
if [ $alias_removed -eq 0 ] && [ -f ~/.bashrc ]; then
    SCRIPT_RUNTIME=$(readlink -f "$0")
    echo "$SCRIPT_RUNTIME" > ~/.runtime_path_keji
    if ! grep -q 'function keji()' ~/.bashrc; then
        echo 'function keji() {' >> ~/.bashrc
        echo '    bash "$(cat ~/.runtime_path_keji)"' >> ~/.bashrc
        echo '}' >> ~/.bashrc
        echo "快捷命令 keji 已添加到 ~/.bashrc, 正在自动重新加载 shell..."
        exec bash
    fi
fi
