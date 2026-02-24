#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== TrustTunnel Official Pro Setup ===${NC}"

# ۱. آپدیت و تنظیم فایروال (پورت ۴۴۳ و ۸۰ برای دریافت SSL الزامی است)
echo -e "${GREEN}[1/4] Configuring Firewall...${NC}"
sudo apt update && sudo apt install -y curl ufw
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

# ۲. دانلود و نصب پکیج رسمی از گیت‌هاب
echo -e "${GREEN}[2/4] Installing Official TrustTunnel Core...${NC}"
curl -fsSL https://raw.githubusercontent.com/TrustTunnel/TrustTunnel/refs/heads/master/scripts/install.sh | sh -s -

# ۳. اجرای ویزارد رسمی سازنده (برای گرفتن SSL و ساخت کانفیگ)
echo -e "${GREEN}[3/4] Running Official Setup Wizard...${NC}"
echo -e "${BLUE}Please answer the questions on the screen (It will automatically get SSL for you!)${NC}"
cd /opt/trusttunnel
sudo ./setup_wizard

# ۴. ساخت سرویس پس‌زمینه برای روشن ماندن همیشگی VPN
echo -e "${GREEN}[4/4] Creating Background Service...${NC}"
cat <<EOF | sudo tee /etc/systemd/system/trusttunnel.service > /dev/null
[Unit]
Description=TrustTunnel VPN Endpoint
After=network.target

[Service]
ExecStart=/opt/trusttunnel/trusttunnel_endpoint /opt/trusttunnel/vpn.toml /opt/trusttunnel/hosts.toml
Restart=always
User=root
WorkingDirectory=/opt/trusttunnel

[Install]
WantedBy=multi-user.target
EOF

# فعال‌سازی و استارت سرور
sudo systemctl daemon-reload
sudo systemctl enable trusttunnel
sudo systemctl restart trusttunnel

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}SUCCESS! Your Official Server is running in the background.${NC}"
echo -e "You can check the live server logs anytime by typing:"
echo -e "sudo journalctl -u trusttunnel -f"
echo -e "${BLUE}=========================================${NC}"