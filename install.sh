#!/bin/bash

# Print colorful messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== NTFS-3G Installation Script ===${NC}\n"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew is not installed. Please install Homebrew first:${NC}"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# Install required packages
echo -e "${BLUE}Installing required packages...${NC}"
brew tap gromgit/homebrew-fuse
brew install --cask macfuse
brew install ntfs-3g-mac

# Check if kernel extensions are allowed
if ! spctl kext-consent status | grep -q "ENABLED"; then
    echo -e "\n${YELLOW}Important: Kernel extensions need to be allowed for NTFS-3G to work.${NC}"
    echo -e "Please follow these steps:"
    echo -e "1. Restart your Mac"
    echo -e "2. Press and hold ${GREEN}Command (⌘) + R${NC} immediately after restarting"
    echo -e "3. Keep holding until you see the Apple logo or spinning globe"
    echo -e "4. When in Recovery Mode, click on ${GREEN}Utilities${NC} in the top menu"
    echo -e "5. Select ${GREEN}Startup Security Utility${NC}"
    echo -e "6. Click ${GREEN}Security Policy...${NC}"
    echo -e "7. Select ${GREEN}Reduced Security${NC} and check ${GREEN}Allow user management of kernel extensions${NC}"
    echo -e "8. Restart your Mac"
    echo -e "\nAfter completing these steps, run ${GREEN}./boot_drive.sh${NC} to mount your NTFS drive."
else
    echo -e "\n${GREEN}Kernel extensions are already allowed.${NC}"
    echo -e "You can now run ${BLUE}./boot_drive.sh${NC} to mount your NTFS drive."
fi

# Make boot_drive.sh executable
chmod +x boot_drive.sh

echo -e "\n${GREEN}Installation complete!${NC}" 