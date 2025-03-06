#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Fix terminal issues before running
stty sane  # Reset terminal to sane state
stty erase ^H  # Fix backspace issues

# Banner
echo -e "${CYAN}"
echo "┌───────────────────────────────────────────────┐"
echo "│      🔍  UP-SCANNER: LIVE HOST DETECTOR      │"
echo "└───────────────────────────────────────────────┘"
echo -e "${RESET}"

# Function to check if file exists and is readable
check_file() {
    if [[ ! -f "$1" ]]; then
        echo -e "${RED}[!] Error: The specified file does not exist!${RESET}"
        return 1
    elif [[ ! -r "$1" ]]; then
        echo -e "${RED}[!] Error: The file is not readable! Check permissions.${RESET}"
        return 1
    fi
    return 0
}

# Enable tab completion for file paths
shopt -s progcomp

# Ask for the input file
echo -en "${YELLOW}[?] Enter the path to the subnet list file: ${RESET}"
read -e -r INPUT_FILE

# Validate input file
check_file "$INPUT_FILE" || exit 1

# Ask for the output file
echo -en "${YELLOW}[?] Enter the name of the output file for live hosts: ${RESET}"
read -e -r OUTPUT_FILE

# Clear the output file before scanning
> "$OUTPUT_FILE"

# Start scanning
echo -e "${BLUE}[*] Starting scan...${RESET}"

# Progress counter
total_subnets=$(wc -l < "$INPUT_FILE")
current=0
while read -r subnet; do
    ((current++))
    progress=$(( (current * 100) / total_subnets ))
    echo -ne "${CYAN}[*] Scanning $subnet... ($progress% Completed)\r${RESET}"
    fping -a -g "$subnet" 2>/dev/null >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo ""

# Display results
if [[ -s "$OUTPUT_FILE" ]]; then
    echo -e "${GREEN}[✔] Scan completed! Live IPs saved to $OUTPUT_FILE.${RESET}"
else
    echo -e "${RED}[!] No live hosts found.${RESET}"
fi
