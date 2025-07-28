🔍 BlackLens: Passive Active Recon Toolkit
BlackLens is a lightweight, modular reconnaissance automation script written in Zsh for passive OSINT investigations. It’s designed for security researchers, bug bounty hunters, and ethical hackers who want to automate the boring and focus on the critical.
 
  
  echo -e "${CYAN}"
     '██████╗ ██╗      █████╗  ██████╗██╗  ██╗██╗     ███████╗███╗   ██╗███████╗'
     
     '██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██║     ██╔════╝████╗  ██║██╔════╝'
     
     '██████╔╝██║     ███████║██║     █████╔╝ ██║     █████╗  ██╔██╗ ██║███████╗'
     
     '██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██║     ██╔══╝  ██║╚██╗██║╚════██║'
     
     '██████╔╝███████╗██║  ██║╚██████╗██║  ██╗███████╗███████╗██║ ╚████║███████║'
   '╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝'

🚀 Features
🕵️ Passive WHOIS and DNS enumeration

🌐 Subdomain discovery using subfinder

📡 Live host probing with httpx

🖼️ Screenshot capture via gowitness (multi-threaded)

🚩 Subdomain takeover detection using subzy

📂 Directory brute-forcing with gobuster

📄 Auto-generated HTML report with screenshots and results

⚙️ Usage
bash
Copy
Edit
chmod +x blacklens.sh
./blacklens.sh <domain>
Example:

bash
Copy
Edit
./blacklens.sh vulnweb.com
Reports will be stored in:

bash
Copy
Edit
/output/<domain>/
🧰 Requirements
Make sure the following tools are installed:

subfinder

httpx

gowitness

subzy

gobuster

jq, whois, dig, host, etc.

Install Go-based tools:

bash
Copy
Edit
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/sensepost/gowitness@latest
go install github.com/LukaSikic/subzy@latest
📎 Legal Disclaimer
This tool is intended strictly for legal and educational purposes.
Use only on domains you own or have explicit permission to test.

Test target:
http://testphp.vulnweb.com

🙌 Credits
Created by CipherShield

Powered by ProjectDiscovery, GoWitness, Subzy, and open-source magic ✨

🌐 GitHub
👉 https://github.com/Cipher-Sheild/BlackLens



⭐ Star the repo, fork it, and contribute!
#CyberSecurity #OSINT #Reconnaissance #BlackLens #Infosec #BugBounty
