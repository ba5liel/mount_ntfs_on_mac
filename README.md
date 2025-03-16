# NTFS Drive Mount Tool for macOS

A simple tool to enable read and write support for NTFS drives on macOS. This tool has been specifically tested on Apple Silicon Macs.

⚠️ **Note: This tool has only been tested on Apple Silicon (M1/M2/M3) Macs.**

## Prerequisites

- macOS running on Apple Silicon
- [Homebrew](https://brew.sh/) package manager
- Administrator privileges

## Installation

1. Clone or download this repository
2. Open Terminal and navigate to the tool's directory
3. Make the scripts executable:
   ```bash
   chmod +x install.sh boot_drive.sh
   ```
4. Run the installation script:
   ```bash
   ./install.sh
   ```

The installation script will:
1. Install required packages using Homebrew:
   - macFUSE
   - ntfs-3g-mac
2. Check if kernel extensions are allowed
3. Guide you through enabling kernel extensions if needed

## First-Time Setup

If kernel extensions are not allowed (common on first use), the installer will guide you through these steps:

1. Restart your Mac
2. Hold Command (⌘) + R immediately after restart
3. Wait for Recovery Mode to load
4. Click "Utilities" in the top menu
5. Select "Startup Security Utility"
6. Click "Security Policy..."
7. Select "Reduced Security" and check "Allow user management of kernel extensions"
8. Restart your Mac

## Usage

1. Connect your NTFS drive
2. Open Terminal
3. Navigate to the tool's directory
4. Run:
   ```bash
   sudo ./boot_drive.sh
   ```
5. Use arrow keys to select your drive from the list
6. Press Enter to mount the drive

Your drive will be mounted at `/Volumes/MyDrive` with full read and write permissions.

## Troubleshooting

If mounting fails:
1. Ensure you've completed the kernel extension setup in Recovery Mode
2. Make sure the drive is properly connected
3. Try unplugging and reconnecting the drive
4. Ensure the drive is using NTFS format

## Security Note

This tool requires sudo privileges because mounting file systems is a privileged operation. Always review scripts that require sudo before running them.

## Compatibility

- ✅ Tested on macOS Sonoma with Apple Silicon
- ⚠️ Not tested on Intel-based Macs
- ⚠️ Not tested on older macOS versions

## License

This project is open source and available under the MIT License. 