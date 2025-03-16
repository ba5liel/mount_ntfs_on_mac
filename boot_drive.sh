#!/bin/bash

# Print colorful messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Please run as root (using sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}=== NTFS Drive Mounting Tool ===${NC}\n"

# Create arrays to store drive information
declare -a drive_list
declare -a identifiers
declare -a volume_names

# Process diskutil list to get external drives
current_disk=""
is_external=false

while IFS= read -r line; do
    # Check if this is an external disk header
    if [[ $line == *"(external, physical):"* ]]; then
        current_disk=$(echo "$line" | awk '{print $1}')
        is_external=true
        continue
    fi
    
    # If we're in an external disk section and find a partition without asterisk
    if [[ $is_external == true && $line =~ ^[[:space:]]*[0-9]+:[[:space:]] && ! $line == *"*"* ]]; then
        # Extract partition info
        partition_id="${current_disk}s$(echo "$line" | awk '{print $1}' | tr -d ':')"
        volume_name=$(echo "$line" | awk -F'NAME[[:space:]]+' '{print $2}' | awk '{print $1}')
        size=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i ~/TB$|GB$|MB$/) print $(i-1)" "$i}')
        
        # Store the information
        drive_list+=("$line")
        identifiers+=("$partition_id")
        volume_names+=("$volume_name")
    fi
    
    # Reset external flag if we hit a new disk
    if [[ $line =~ ^/dev/disk[0-9]+ && ! $line == *"(external, physical):"* ]]; then
        is_external=false
    fi
done <<< "$(diskutil list)"

if [ ${#drive_list[@]} -eq 0 ]; then
    echo -e "${RED}No external drives found!${NC}"
    echo -e "${YELLOW}Please make sure your external NTFS drive is connected.${NC}"
    exit 1
fi

# Print the menu
echo -e "${BLUE}Available external drives:${NC}\n"
for i in "${!drive_list[@]}"; do
    echo -e "$((i+1)). ${GREEN}${drive_list[$i]}${NC}"
done

# Get user selection
echo -e "\nUse arrow keys to select a drive and press Enter:"
selected=0
while true; do
    # Clear previous selections
    for i in "${!drive_list[@]}"; do
        echo -e "\033[1A\033[K"
    done
    
    # Print menu with highlight
    for i in "${!drive_list[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "${YELLOW}> ${drive_list[$i]}${NC}"
        else
            echo "  ${drive_list[$i]}"
        fi
    done
    
    # Read a single character
    read -rsn1 key
    
    case "$key" in
        A) # Up arrow
            ((selected--))
            [ $selected -lt 0 ] && selected=$((${#drive_list[@]}-1))
            ;;
        B) # Down arrow
            ((selected++))
            [ $selected -eq ${#drive_list[@]} ] && selected=0
            ;;
        "") # Enter key
            break
            ;;
    esac
done

# Get the selected drive identifier
identifier=${identifiers[$selected]}
selected_drive=${drive_list[$selected]}
volume_name=${volume_names[$selected]}

# Create mount point if it doesn't exist
mkdir -p /Volumes/MyDrive

# Unmount the drive if it's mounted
echo -e "\n${BLUE}Unmounting drive if mounted...${NC}"
diskutil unmount force "/Volumes/MyDrive" &>/dev/null
diskutil unmount force "$identifier" &>/dev/null
[ ! -z "$volume_name" ] && diskutil unmount force "/Volumes/$volume_name" &>/dev/null

# Mount the drive
echo -e "${BLUE}Mounting drive: ${GREEN}$selected_drive${NC}"
if ntfs-3g "$identifier" /Volumes/MyDrive -o local -o allow_other; then
    echo -e "\n${GREEN}Success!${NC} Drive mounted at ${BLUE}/Volumes/MyDrive${NC}"
    echo -e "You can now read and write to this drive."
else
    echo -e "\n${RED}Failed to mount the drive.${NC}"
    echo -e "Please make sure you have:"
    echo -e "1. Allowed kernel extensions in Recovery Mode"
    echo -e "2. Installed NTFS-3G correctly using the install.sh script"
    exit 1
fi 