#!/bin/bash

# 检查脚本是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "此脚本需要以 root 权限运行。请使用 sudo ./setup_vps_root.sh 命令运行。"
  exit 1
fi

# 1. 设置 root 密码
echo "--- 步骤 1: 设置 root 密码 ---"
read -s -p "请输入新的 root 密码: " NEW_PASSWORD
echo
read -s -p "请再次输入新的 root 密码以确认: " NEW_PASSWORD_CONFIRM
echo

if [ "$NEW_PASSWORD" != "$NEW_PASSWORD_CONFIRM" ]; then
  echo "错误：两次输入的密码不匹配。脚本已中止。"
  exit 1
fi

if [ -z "$NEW_PASSWORD" ]; then
  echo "错误：密码不能为空。脚本已中止。"
  exit 1
fi

echo "正在设置 root 密码..."
# 使用 chpasswd 命令设置密码，更适合脚本操作
echo "root:$NEW_PASSWORD" | chpasswd
if [ $? -eq 0 ]; then
  echo "root 密码设置成功。"
else
  echo "错误：root 密码设置失败。请检查错误信息并尝试手动设置。脚本已中止。"
  exit 1
fi

# 2. 开启 SSH 权限
echo ""
echo "--- 步骤 2: 配置 SSH 权限 ---"
echo "请选择您的操作系统类型:"
echo "  1) CentOS / Debian"
echo "  2) Ubuntu"
read -p "请输入选项 (1 或 2): " OS_CHOICE

CONFIG_MODIFIED=false

case $OS_CHOICE in
  1)
    echo "为 CentOS/Debian 配置 SSH..."
    sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    CONFIG_MODIFIED=true
    echo "SSH 配置已更新 (CentOS/Debian)。"
    ;;
  2)
    echo "为 Ubuntu 配置 SSH..."
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    CONFIG_MODIFIED=true
    echo "SSH 配置已更新 (Ubuntu)。"
    ;;
  *)
    echo "错误：无效的选项。脚本已中止。"
    exit 1
    ;;
esac

# 重启 SSH 服务
if [ "$CONFIG_MODIFIED" = true ]; then
  echo ""
  echo "正在尝试重启 SSH 服务..."
  if command -v systemctl &> /dev/null; then
    if systemctl list-units --type=service --all | grep -q sshd.service; then
      systemctl restart sshd
      echo "sshd 服务已重启 (使用 systemctl)。"
    elif systemctl list-units --type=service --all | grep -q ssh.service; then
      systemctl restart ssh
      echo "ssh 服务已重启 (使用 systemctl)。"
    else
      echo "警告：未找到 sshd.service 或 ssh.service。请手动重启 SSH 服务。"
    fi
  elif command -v service &> /dev/null; then
    if service ssh status &> /dev/null; then
      service ssh restart
      echo "ssh 服务已重启 (使用 service)。"
    elif service sshd status &> /dev/null; then
      service sshd restart
      echo "sshd 服务已重启 (使用 service)。"
    else
      echo "警告：无法通过 service 命令确定 SSH 服务状态。请手动重启 SSH 服务。"
    fi
  else
    echo "警告：未找到 systemctl 或 service 命令。您可能需要手动重启 SSH 服务 (例如: /etc/init.d/sshd restart 或 /etc/init.d/ssh restart)。"
  fi
fi

# 3. 提示重启服务器
echo ""
echo "--- 步骤 3: 重启服务器 ---"
echo "所有配置步骤已执行完毕。"
echo "重要提示：建议您现在打开一个新的终端窗口，尝试使用新的 root 密码通过 SSH 登录到服务器，以验证更改是否成功。"
read -p "验证 SSH 登录后，按 Enter 键将立即重启服务器，或按 Ctrl+C 取消重启并手动操作: " REBOOT_CONFIRM

echo "正在发送重启命令..."
reboot

exit 0