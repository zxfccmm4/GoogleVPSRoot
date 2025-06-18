#!/bin/bash

# Google VPS Root Setup Script
# 自动化设置Google Cloud VPS的root登录权限

echo "=========================================="
echo "  Google VPS Root Setup Script"
echo "=========================================="
echo ""
echo "Language Selection / 语言选择"
echo "1) English"
echo "2) 中文"
echo ""
read -p "Please select language / 请选择语言 (1 or 2): " LANG_CHOICE

case $LANG_CHOICE in
  1)
    LANG="en"
    ;;
  2)
    LANG="zh"
    ;;
  *)
    echo "Invalid option. Defaulting to English."
    echo "无效选项。默认使用英语。"
    LANG="en"
    ;;
esac

clear

# 显示标题
if [ "$LANG" = "zh" ]; then
  echo "=========================================="
  echo "  Google VPS Root 设置脚本"
  echo "=========================================="
else
  echo "=========================================="
  echo "  Google VPS Root Setup Script"
  echo "=========================================="
fi
echo ""

# 检查脚本是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
  if [ "$LANG" = "zh" ]; then
    echo "❌ 此脚本需要以 root 权限运行。"
    echo "   请先使用以下命令进入root权限："
    echo "   sudo -i"
    echo "   然后运行此脚本: ./setup_vps_root.sh"
  else
    echo "❌ This script must be run as root."
    echo "   Please first enter root privileges:"
    echo "   sudo -i"
    echo "   Then run this script: ./setup_vps_root.sh"
  fi
  exit 1
fi

if [ "$LANG" = "zh" ]; then
  echo "✅ 已确认以 root 权限运行"
else
  echo "✅ Confirmed running as root"
fi
echo ""

# 1. 设置 root 密码
echo "=========================================="
if [ "$LANG" = "zh" ]; then
  echo "步骤 1: 设置 root 密码"
  echo "=========================================="
  echo "提示：输入密码时不会显示任何字符，这是正常的安全行为"
  echo ""
  read -s -p "请输入新的 root 密码: " NEW_PASSWORD
  echo
  read -s -p "请再次输入新的 root 密码以确认: " NEW_PASSWORD_CONFIRM
  echo
else
  echo "Step 1: Set Root Password"
  echo "=========================================="
  echo "Note: Password input will not be displayed, this is normal security behavior"
  echo ""
  read -s -p "Enter new root password: " NEW_PASSWORD
  echo
  read -s -p "Confirm new root password: " NEW_PASSWORD_CONFIRM
  echo
fi

if [ "$NEW_PASSWORD" != "$NEW_PASSWORD_CONFIRM" ]; then
  if [ "$LANG" = "zh" ]; then
    echo "❌ 错误：两次输入的密码不匹配。脚本已中止。"
  else
    echo "❌ Error: Passwords do not match. Script aborted."
  fi
  exit 1
fi

if [ -z "$NEW_PASSWORD" ]; then
  if [ "$LANG" = "zh" ]; then
    echo "❌ 错误：密码不能为空。脚本已中止。"
  else
    echo "❌ Error: Password cannot be empty. Script aborted."
  fi
  exit 1
fi

if [ "$LANG" = "zh" ]; then
  echo "正在设置 root 密码..."
else
  echo "Setting root password..."
fi

# 使用 passwd 命令，模拟交互式输入
echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | passwd root
if [ $? -eq 0 ]; then
  if [ "$LANG" = "zh" ]; then
    echo "✅ root 密码设置成功"
  else
    echo "✅ Root password set successfully"
  fi
else
  if [ "$LANG" = "zh" ]; then
    echo "❌ 错误：root 密码设置失败。请检查错误信息并尝试手动设置。"
    echo "   手动设置命令：passwd"
  else
    echo "❌ Error: Failed to set root password. Please check error messages and try manual setup."
    echo "   Manual setup command: passwd"
  fi
  exit 1
fi

echo ""
echo "=========================================="
if [ "$LANG" = "zh" ]; then
  echo "步骤 2: 开启 Google Cloud SSH 权限"
  echo "=========================================="
  echo "请选择您的操作系统类型:"
  echo "  1) CentOS / Debian"
  echo "  2) Ubuntu"
  echo ""
  read -p "请输入选项 (1 或 2): " OS_CHOICE
else
  echo "Step 2: Enable Google Cloud SSH Permissions"
  echo "=========================================="
  echo "Please select your operating system type:"
  echo "  1) CentOS / Debian"
  echo "  2) Ubuntu"
  echo ""
  read -p "Enter option (1 or 2): " OS_CHOICE
fi

CONFIG_MODIFIED=false

case $OS_CHOICE in
  1)
    echo ""
    if [ "$LANG" = "zh" ]; then
      echo "🔧 为 CentOS/Debian 系统配置 SSH..."
      echo "执行命令:"
    else
      echo "🔧 Configuring SSH for CentOS/Debian system..."
      echo "Executing commands:"
    fi
    echo "sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config"
    sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
    echo "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    CONFIG_MODIFIED=true
    if [ "$LANG" = "zh" ]; then
      echo "✅ SSH 配置已更新 (CentOS/Debian)"
    else
      echo "✅ SSH configuration updated (CentOS/Debian)"
    fi
    ;;
  2)
    echo ""
    if [ "$LANG" = "zh" ]; then
      echo "🔧 为 Ubuntu 系统配置 SSH..."
      echo "执行命令:"
    else
      echo "🔧 Configuring SSH for Ubuntu system..."
      echo "Executing commands:"
    fi
    echo "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config"
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    echo "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    CONFIG_MODIFIED=true
    if [ "$LANG" = "zh" ]; then
      echo "✅ SSH 配置已更新 (Ubuntu)"
    else
      echo "✅ SSH configuration updated (Ubuntu)"
    fi
    ;;
  *)
    if [ "$LANG" = "zh" ]; then
      echo "❌ 错误：无效的选项。脚本已中止。"
    else
      echo "❌ Error: Invalid option. Script aborted."
    fi
    exit 1
    ;;
esac

# 重启 SSH 服务
if [ "$CONFIG_MODIFIED" = true ]; then
  echo ""
  if [ "$LANG" = "zh" ]; then
    echo "🔄 正在重启 SSH 服务..."
  else
    echo "🔄 Restarting SSH service..."
  fi
  
  if command -v systemctl &> /dev/null; then
    if systemctl list-units --type=service --all | grep -q sshd.service; then
      systemctl restart sshd
      if [ "$LANG" = "zh" ]; then
        echo "✅ sshd 服务已重启"
      else
        echo "✅ sshd service restarted"
      fi
    elif systemctl list-units --type=service --all | grep -q ssh.service; then
      systemctl restart ssh
      if [ "$LANG" = "zh" ]; then
        echo "✅ ssh 服务已重启"
      else
        echo "✅ ssh service restarted"
      fi
    else
      if [ "$LANG" = "zh" ]; then
        echo "⚠️  警告：未找到 sshd.service 或 ssh.service。请手动重启 SSH 服务"
      else
        echo "⚠️  Warning: sshd.service or ssh.service not found. Please restart SSH service manually"
      fi
    fi
  elif command -v service &> /dev/null; then
    if service ssh status &> /dev/null; then
      service ssh restart
      if [ "$LANG" = "zh" ]; then
        echo "✅ ssh 服务已重启"
      else
        echo "✅ ssh service restarted"
      fi
    elif service sshd status &> /dev/null; then
      service sshd restart
      if [ "$LANG" = "zh" ]; then
        echo "✅ sshd 服务已重启"
      else
        echo "✅ sshd service restarted"
      fi
    else
      if [ "$LANG" = "zh" ]; then
        echo "⚠️  警告：无法确定 SSH 服务状态。请手动重启 SSH 服务"
      else
        echo "⚠️  Warning: Cannot determine SSH service status. Please restart SSH service manually"
      fi
    fi
  else
    if [ "$LANG" = "zh" ]; then
      echo "⚠️  警告：未找到 systemctl 或 service 命令"
      echo "   请手动重启 SSH 服务：/etc/init.d/sshd restart 或 /etc/init.d/ssh restart"
    else
      echo "⚠️  Warning: systemctl or service command not found"
      echo "   Please restart SSH service manually: /etc/init.d/sshd restart or /etc/init.d/ssh restart"
    fi
  fi
fi

echo ""
echo "=========================================="
if [ "$LANG" = "zh" ]; then
  echo "步骤 3: 重启服务器"
  echo "=========================================="
  echo "✅ 所有配置步骤已执行完毕"
  echo ""
  echo "⚠️  重要提示："
  echo "   建议您现在打开一个新的终端窗口，"
  echo "   尝试使用新的 root 密码通过 SSH 登录到服务器，"
  echo "   以验证更改是否成功。"
  echo ""
  echo "   SSH 登录命令示例："
  echo "   ssh root@YOUR_SERVER_IP"
  echo ""
  read -p "验证 SSH 登录成功后，按 Enter 键重启服务器，或按 Ctrl+C 取消: " REBOOT_CONFIRM
  echo ""
  echo "🔄 正在重启服务器..."
  echo "执行命令: reboot"
else
  echo "Step 3: Restart Server"
  echo "=========================================="
  echo "✅ All configuration steps completed"
  echo ""
  echo "⚠️  Important Notice:"
  echo "   It is recommended to open a new terminal window now,"
  echo "   and try to login to the server via SSH using the new root password"
  echo "   to verify that the changes are successful."
  echo ""
  echo "   SSH login command example:"
  echo "   ssh root@YOUR_SERVER_IP"
  echo ""
  read -p "After verifying SSH login success, press Enter to restart server, or press Ctrl+C to cancel: " REBOOT_CONFIRM
  echo ""
  echo "🔄 Restarting server..."
  echo "Executing command: reboot"
fi

reboot
exit 0