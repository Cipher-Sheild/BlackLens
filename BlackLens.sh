#!/bin/zsh

# ──────────────────────────────────────────────
# 🕵️ BlackLens: Passive Recon Toolkit for OSINT
# By: [CipherShield]
# ──────────────────────────────────────────────

# ANSI Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
BOLD="\033[1m"
RESET="\033[0m"

setopt +o nomatch  # prevent Zsh glob errors when no files match

# ─────────────── BANNER ───────────────
function banner() {
    echo -e "${CYAN}"
    echo '██████╗ ██╗      █████╗  ██████╗██╗  ██╗██╗     ███████╗███╗   ██╗███████╗'
    echo '██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██║     ██╔════╝████╗  ██║██╔════╝'
    echo '██████╔╝██║     ███████║██║     █████╔╝ ██║     █████╗  ██╔██╗ ██║███████╗'
    echo '██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██║     ██╔══╝  ██║╚██╗██║╚════██║'
    echo '██████╔╝███████╗██║  ██║╚██████╗██║  ██╗███████╗███████╗██║ ╚████║███████║'
    echo '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝'
    echo -e "               🕵️  ${BOLD}Recon Toolkit${RESET} - By CipherShield${RESET}"
}

# ─────────────── USAGE ───────────────
function usage() {
    echo -e "${RED}Usage: $0 <domain>${RESET}"
    echo -e "Example: ./blacklens.sh example.com\n"
    exit 1
}

# ─────────────── REQUIREMENTS ───────────────
function check_dependencies() {
    local tools=(whois dig subfinder httpx gowitness subzy)
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies:${RESET} ${missing[*]}"
        echo -e "${CYAN}Install them using:${RESET}"
        echo "   subfinder/httpx/subzy: go install github.com/projectdiscovery/{subfinder,httpx,subzy}@latest"
        echo "   gowitness: go install github.com/sensepost/gowitness@latest"
        echo "   whois/dig: sudo apt install whois dnsutils -y"
        exit 1
    fi
}

# ─────────────── MAIN ───────────────
[ -z "$1" ] && usage
domain="$1"
check_dependencies
banner

# Directory setup
base_dir="$domain"
info_path="$base_dir/info"
subdomain_path="$base_dir/subdomains"
screenshot_path="$base_dir/screenshots"
report_path="$base_dir/report"

mkdir -p "$info_path" "$subdomain_path" "$screenshot_path" "$report_path"
echo -e "${CYAN}📁 Directories created under ${BOLD}$base_dir${RESET}"

# ─────────────── RECON FUNCTIONS ───────────────

# WHOIS lookup
echo -e "\n${RED}🛠️  [+] WHOIS Lookup...${RESET}"
whois "$domain" > "$info_path/whois.txt" || echo "WHOIS failed." > "$info_path/whois.txt"

# DNS records
echo -e "\n${RED}🛠️  [+] DNS Records...${RESET}"
{
    echo "─── A Records ───"; dig A "$domain" +short
    echo "\n─── MX Records ───"; dig MX "$domain" +short
    echo "\n─── NS Records ───"; dig NS "$domain" +short
    echo "\n─── TXT Records ───"; dig TXT "$domain" +short
} > "$info_path/dns.txt"

# Subdomain discovery
echo -e "\n${RED}🛠️  [+] Finding subdomains (subfinder)...${RESET}"
subfinder -d "$domain" -silent > "$subdomain_path/found.txt" || {
    echo -e "${RED}❌ subfinder failed!${RESET}"
    exit 1
}

# Deduplicate and filter
sort -u "$subdomain_path/found.txt" -o "$subdomain_path/found.txt"

# Probe live subdomains
echo -e "\n${RED}🛠️  [+] Probing live subdomains (httpx)...${RESET}"
httpx -l "$subdomain_path/found.txt" -silent -status-code -title -no-color -o "$subdomain_path/alive_raw.txt"
cut -d ' ' -f 1 "$subdomain_path/alive_raw.txt" > "$subdomain_path/alive.txt"

# Screenshots and subdomain takeover checks
if [ -s "$subdomain_path/alive.txt" ]; then
    echo -e "\n${RED}📸 [+] Capturing screenshots (gowitness)...${RESET}"
    gowitness scan file -f "$subdomain_path/alive.txt" --threads 4 --screenshot-path "$screenshot_path"

    echo -e "\n${RED}🔍 [+] Checking for subdomain takeover (subzy)...${RESET}"
    subzy run --targets "$subdomain_path/alive.txt" --hide_fails | sed 's/\x1b\[[0-9;]*m//g' > "$info_path/takeover.txt"
else
    echo -e "\n${RED}⚠️  No live subdomains found. Skipping screenshots/takeover checks.${RESET}"
    echo "No live subdomains." > "$info_path/takeover.txt"
fi
echo -e "\n${RED}🔍 [+] Running Gobuster (Directory Bruteforce)...${RESET}"
gobuster dir -u "$domain" -w /usr/share/wordlists/dirb/common.txt -o "$base_dir/gobuster_dirs.txt" -t 50 -q

# Generate HTML report
echo -e "\n${RED}📊 [+] Generating HTML Report...${RESET}"
report_file="$report_path/report.html"

# Copy screenshots to report directory for proper linking
mkdir -p "$report_path/screenshots"
cp "$screenshot_path"/*.jpeg "$report_path/screenshots/" 2>/dev/null

{
    echo "<!DOCTYPE html><html><head><title>BlackLens Report - $domain</title>"
    echo "<style>body{font-family: Arial, sans-serif; margin: 2em;} pre{background: #f4f4f4; padding: 1em; border-radius: 5px;}"
    echo "img {border: 1px solid #ddd; margin-bottom: 1em; max-width: 800px; display: block;}"
    echo "hr {margin: 2em 0;}</style></head>"
    echo "<body><h1>🕵️ BlackLens Recon Report - $domain</h1>"
    echo "<h2>🔗 WHOIS</h2><pre>$(cat "$info_path/whois.txt")</pre>"
    echo "<h2>🌐 DNS Records</h2><pre>$(cat "$info_path/dns.txt")</pre>"
    echo "<h2>🔍 Subdomains Found ($(wc -l < "$subdomain_path/found.txt"))</h2><pre>$(cat "$subdomain_path/found.txt")</pre>"
    echo "<h2>✅ Live Subdomains ($(wc -l < "$subdomain_path/alive.txt"))</h2><pre>$(cat "$subdomain_path/alive_raw.txt")</pre>"
    echo "<h2>⚠️ Possible Takeovers</h2><pre>$(cat "$info_path/takeover.txt")</pre>"
    
    
    # Check if screenshots exist
    echo "<h2>📸 Screenshots</h2>"
    if ls "$domain/$report_path"/screenshots/*.jpeg &>/dev/null; then
    for img in "$domain/$report_path"/screenshots/*.jpeg; do
	img_name=$(basename "$img")
	echo "<div><img src='screenshots/$img_name' style='max-width:800px;'></div>"
    done
    else
    	echo "<p>No screenshots available here check your screenshort Directory</p>"
    fi
    
    echo "<h2>🔍 Directory Bruteforce (Gobuster)</h2>"
    if [[ -s "$base_dir/gobuster_dirs.txt" ]]; then
        echo "<pre>$(cat "$base_dir/gobuster_dirs.txt")</pre>"
    else
        echo "<p>No directories found.</p>"
    fi
    echo "</body></html>"
} > "$report_file"
# Completion message
echo -e "\n${GREEN}✅ BlackLens recon complete!${RESET}"
echo -e "${CYAN}📂 Report: ${BOLD}file://$(realpath "$report_file")${RESET}"
