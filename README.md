# Google VPS Root Setup Script

[English](README.md) | [中文](READMECN.md)

This repository contains a Bash script (`setup_vps_root.sh`) designed to simplify the initial setup process for a Google Cloud VPS, specifically focusing on enabling root login via SSH with a password.

## Features

*   **Set Root Password**: Interactively prompts the user to set a new password for the `root` user.
*   **Configure SSH for Root Login**: Modifies the `sshd_config` file to:
    *   Allow root login (`PermitRootLogin yes`).
    *   Enable password authentication (`PasswordAuthentication yes`).
*   **OS Detection**: Provides options for CentOS/Debian and Ubuntu systems to apply the correct `sed` commands for `sshd_config` modification.
*   **SSH Service Restart**: Attempts to restart the SSH service (`sshd` or `ssh`) after configuration changes.
*   **Reboot Prompt**: Advises the user to verify SSH login with the new root password before rebooting the server and then prompts for a server reboot.

## Prerequisites

*   A Google Cloud VPS (or any other Linux server where you have `sudo` access).
*   The script needs to be run with `sudo` privileges.

## Usage

1.  **Download the Script**:
    Clone this repository or download the `setup_vps_root.sh` script to your server.

    ```bash
    git clone https://github.com/zxfccmm4/GoogleVPSRoot.git
    cd GoogleVPSRoot
    ```

2.  **Make the Script Executable**:

    ```bash
    chmod +x setup_vps_root.sh
    ```

3.  **Run the Script with Sudo**:

    ```bash
    sudo ./setup_vps_root.sh
    ```

    The script will guide you through the following steps:
    *   Setting the root password.
    *   Choosing your operating system (CentOS/Debian or Ubuntu) for SSH configuration.

4.  **Verify SSH Login**:
    After the script completes the SSH configuration and restarts the SSH service, **it is crucial to open a new terminal window and attempt to log in as `root` using the password you just set**.

    ```bash
    ssh root@YOUR_SERVER_IP
    ```

5.  **Reboot the Server**:
    If the SSH login as root is successful, go back to the terminal where the script is running and press Enter to reboot the server. If the SSH login fails, you can press `Ctrl+C` to cancel the reboot and troubleshoot the issue.

## Important Notes

*   **Security**: Enabling root login with a password can be a security risk. It is generally recommended to use SSH keys for authentication and disable password authentication, especially for root. This script is provided for convenience in specific scenarios but consider hardening your server security afterwards.
*   **Backup `sshd_config`**: While the script uses `sed -i` for in-place editing, it's always a good practice to back up your `/etc/ssh/sshd_config` file before running scripts that modify it.
*   **Error Handling**: The script includes basic error checks, but ensure you monitor its output for any unexpected messages.

## Disclaimer

This script is provided as-is. Use it at your own risk. The author is not responsible for any damage or issues caused by its use. Always understand what a script does before running it on your system, especially with `sudo` privileges.

## Repository

- **GitHub**: https://github.com/zxfccmm4/GoogleVPSRoot.git
- **Author**: zxfccmm4

## License

This project is open source. Please check the repository for license details.
