# Google VPS Root 设置脚本

[English](README.md) | [中文](READMECN.md)

本仓库包含一个 Bash 脚本 (`setup_vps_root.sh`)，旨在简化 Google Cloud VPS 的初始设置过程，特别专注于通过密码启用 SSH 的 root 登录。

## 功能特性

*   **设置 Root 密码**：交互式提示用户为 `root` 用户设置新密码。
*   **配置 SSH Root 登录**：修改 `sshd_config` 文件以：
    *   允许 root 登录 (`PermitRootLogin yes`)。
    *   启用密码认证 (`PasswordAuthentication yes`)。
*   **操作系统检测**：为 CentOS/Debian 和 Ubuntu 系统提供选项，以应用正确的 `sed` 命令来修改 `sshd_config`。
*   **SSH 服务重启**：在配置更改后尝试重启 SSH 服务 (`sshd` 或 `ssh`)。
*   **重启提示**：建议用户在重启服务器之前使用新的 root 密码验证 SSH 登录，然后提示重启服务器。

## 前置条件

*   Google Cloud VPS（或任何其他您拥有 `sudo` 访问权限的 Linux 服务器）。
*   脚本需要以 `sudo` 权限运行。

## 使用方法

1.  **下载脚本**：
    克隆此仓库或将 `setup_vps_root.sh` 脚本下载到您的服务器。

    ```bash
    git clone https://github.com/zxfccmm4/GoogleVPSRoot.git
    cd GoogleVPSRoot
    ```

2.  **使脚本可执行**：

    ```bash
    chmod +x setup_vps_root.sh
    ```

3.  **使用 Sudo 运行脚本**：

    ```bash
    sudo ./setup_vps_root.sh
    ```

    脚本将引导您完成以下步骤：
    *   设置 root 密码。
    *   选择您的操作系统（CentOS/Debian 或 Ubuntu）进行 SSH 配置。

4.  **验证 SSH 登录**：
    脚本完成 SSH 配置并重启 SSH 服务后，**重要的是打开一个新的终端窗口，尝试使用您刚设置的密码以 `root` 身份登录**。

    ```bash
    ssh root@YOUR_SERVER_IP
    ```

5.  **重启服务器**：
    如果 root 的 SSH 登录成功，回到运行脚本的终端并按 Enter 键重启服务器。如果 SSH 登录失败，您可以按 `Ctrl+C` 取消重启并排查问题。

## 重要说明

*   **安全性**：启用带密码的 root 登录可能存在安全风险。通常建议使用 SSH 密钥进行认证并禁用密码认证，特别是对于 root 用户。此脚本在特定场景下提供便利，但请考虑之后加强服务器安全。
*   **备份 `sshd_config`**：虽然脚本使用 `sed -i` 进行就地编辑，但在运行修改 `/etc/ssh/sshd_config` 文件的脚本之前，备份该文件始终是个好习惯。
*   **错误处理**：脚本包含基本的错误检查，但请确保监控其输出以获取任何意外消息。

## 免责声明

此脚本按原样提供。使用风险自负。作者不对使用此脚本造成的任何损害或问题负责。在系统上运行脚本之前，特别是使用 `sudo` 权限时，请始终了解脚本的功能。

## 仓库信息

- **GitHub**: https://github.com/zxfccmm4/GoogleVPSRoot.git
- **作者**: zxfccmm4

## 许可证

此项目为开源项目。请查看仓库了解许可证详情。