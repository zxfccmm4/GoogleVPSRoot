#!/bin/bash

# Google VPS Root Setup Script
# 自动化设置Google Cloud VPS的root登录权限
# Author: Steve
# X: @st7evechou

echo "
+--------------------------------------------------+
|                                                  |
|          Google VPS Root Setup Script            |
|                                                  |
+--------------------------------------------------+
"
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
  echo "
+--------------------------------------------------+
|                                                  |
|            Google VPS Root 设置脚本              |
|              作者: Steve (X: @st7evechou)        |
|                                                  |
+--------------------------------------------------+
"
else
  echo "
+--------------------------------------------------+
|                                                  |
|          Google VPS Root Setup Script            |
|            Author: Steve (X: @st7evechou)        |
|                                                  |
+--------------------------------------------------+
"
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

# Final, safest version of the function to update sshd_config
update_ssh_config() {
  local key="$1"
  local value="$2"
  local config_file="/etc/ssh/sshd_config"

  # Check if the key already exists (commented or uncommented)
  if grep -qE "^\s*#?\s*${key}" "$config_file"; then
    # If it exists, replace the line robustly.
    # This ensures that even if there are multiple lines, only the first is replaced and the rest are deleted.
    # A bit complex, but handles all edge cases.
    sed -i -E "s/^\s*#?\s*${key}.*/${key} ${value}/" "$config_file"
    # To be absolutely sure, let's delete any other duplicate lines (if any)
    local count=$(grep -cE "^\s*${key}" "$config_file")
    if [ "$count" -gt 1 ]; then
      sed -i "/^\s*${key}/d" "$config_file"
      echo "${key} ${value}" >> "$config_file"
    fi
  else
    # If it does not exist, append it.
    echo "${key} ${value}" >> "$config_file"
  fi
}

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
  echo "步骤 2: 配置 SSH 以允许 root 登录"
  echo "=========================================="
  echo "🔧 正在以通用方式更新 SSH 配置文件 (/etc/ssh/sshd_config)..."
else
  echo "Step 2: Configure SSH for Root Login"
  echo "=========================================="
  echo "🔧 Updating SSH configuration file universally (/etc/ssh/sshd_config)..."
fi

update_ssh_config "PermitRootLogin" "yes"
update_ssh_config "PasswordAuthentication" "yes"

if [ "$LANG" = "zh" ]; then
  echo "✅ SSH 配置已更新"
else
  echo "✅ SSH configuration updated"
fi

# 安全检查和重启 SSH 服务
echo ""
if [ "$LANG" = "zh" ]; then
  echo "🛡️  正在验证 SSH 配置文件语法..."
else
  echo "🛡️  Validating SSH configuration syntax..."
fi

# 使用 sshd -t 进行语法检查
if sshd -t; then
  if [ "$LANG" = "zh" ]; then
    echo "✅ SSH 配置文件语法正确。"
    echo "🔄 正在重启 SSH 服务..."
  else
    echo "✅ SSH configuration syntax is OK."
    echo "🔄 Restarting SSH service..."
  fi

  # 更稳健的 SSH 重启逻辑
  RESTARTED=false
  SERVICE_NAME=""
  if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet sshd.service; then
      systemctl restart sshd.service && RESTARTED=true && SERVICE_NAME="sshd"
    elif systemctl is-active --quiet ssh.service; then
      systemctl restart ssh.service && RESTARTED=true && SERVICE_NAME="ssh"
    fi
  elif command -v service &> /dev/null; then
    if service sshd status &> /dev/null; then
      service sshd restart && RESTARTED=true && SERVICE_NAME="sshd"
    elif service ssh status &> /dev/null; then
      service ssh restart && RESTARTED=true && SERVICE_NAME="ssh"
    fi
  fi

  if [ "$RESTARTED" = true ]; then
    if [ "$LANG" = "zh" ]; then
      echo "✅ SSH 服务 ($SERVICE_NAME) 已成功重启"
    else
      echo "✅ SSH service ($SERVICE_NAME) restarted successfully"
    fi
  else
    if [ "$LANG" = "zh" ]; then
      echo "⚠️  警告：自动重启 SSH 服务失败。请手动重启。"
      echo "   常用命令: systemctl restart sshd  或  service sshd restart"
    else
      echo "⚠️  Warning: Failed to automatically restart SSH service. Please restart manually."
      echo "   Common commands: systemctl restart sshd  or  service sshd restart"
    fi
  fi
else
  # 如果 sshd -t 失败
  if [ "$LANG" = "zh" ]; then
    echo "❌ 严重错误：SSH 配置文件存在语法错误！"
    echo "   为了您的服务器安全，脚本已中止，并未重启 SSH 服务。"
    echo "   请手动检查 /etc/ssh/sshd_config 文件中的错误。"
    echo "   修复后，请手动运行 'systemctl restart sshd'。"
  else
    echo "❌ CRITICAL ERROR: SSH configuration file has a syntax error!"
    echo "   For your server's safety, the script has been aborted without restarting the SSH service."
    echo "   Please manually check /etc/ssh/sshd_config for errors."
    echo "   After fixing, please run 'systemctl restart sshd' manually."
  fi
  exit 1
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