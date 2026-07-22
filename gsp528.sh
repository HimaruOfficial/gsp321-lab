cat << 'EOF' > himarusetup.sh
#!/bin/bash

# --- WARNA UNTUK TERMINAL ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear

# --- BANNER HIMARUSETUP ---
echo -e "${CYAN}██╗  ██╗██╗███╗   ███╗███████╗██████╗ ██╗   ██╗${NC}"
echo -e "${CYAN}██║  ██║██║████╗ ████║██╔════╝██╔══██╗██║   ██║${NC}"
echo -e "${CYAN}███████║██║██╔████╔██║█████╗  ██████╔╝██║   ██║${NC}"
echo -e "${CYAN}██╔══██║██║██║╚██╔╝██║██╔══╝  ██╔══██╗██║   ██║${NC}"
echo -e "${CYAN}██║  ██║██║██║ ╚═╝ ██║███████╗██║  ██║╚██████╔╝${NC}"
echo -e "${CYAN}╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝${NC}"
echo -e "${YELLOW}                 S E T U P                    ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  GSP528: Connecting Cloud Networks with NCC Lab  ${NC}"
echo -e "${GREEN}======================================================${NC}\n"

# --- INPUT MANUAL (USER INTERACTIVE) ---
# Deteksi region bawaan dari Qwiklabs
DEFAULT_REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
if [ -z "$DEFAULT_REGION" ]; then
    DEFAULT_REGION="us-east1"
fi

echo -e "${YELLOW}[*] Sistem mendeteksi Region bawaan lab ini adalah: ${DEFAULT_REGION}${NC}"
read -p "$(echo -e ${CYAN}"[?] Masukkan Region (Tekan ENTER untuk menggunakan default [$DEFAULT_REGION]): "${NC})" INPUT_REGION

# Jika user hanya menekan Enter, gunakan default
LOCATION=${INPUT_REGION:-$DEFAULT_REGION}
echo -e "${GREEN}[+] Region yang akan digunakan: $LOCATION ${NC}\n"

read -p "$(echo -e ${YELLOW}"[?] Tekan [ENTER] untuk mulai mengeksekusi script..."${NC})"

echo -e "\n${BLUE}[Tahap 1] Membuat NCC Hub dan Spokes (VPN) untuk On-Prem Offices...${NC}"
gcloud network-connectivity hubs create hub-onprem --description="Hub for On-Prem Office Connectivity" --quiet || true

OFFICE1_TUNNELS=$(gcloud compute vpn-tunnels list --regions=$LOCATION --filter="name ~ office-1 OR name ~ office1" --format="value(selfLink)" | tr '\n' ',' | sed 's/,$//')
OFFICE2_TUNNELS=$(gcloud compute vpn-tunnels list --regions=$LOCATION --filter="name ~ office-2 OR name ~ office2" --format="value(selfLink)" | tr '\n' ',' | sed 's/,$//')

gcloud network-connectivity spokes linked-vpn-tunnels create spoke-office-1 \
  --hub=hub-onprem --region=$LOCATION --vpn-tunnels=$OFFICE1_TUNNELS --quiet || true

gcloud network-connectivity spokes linked-vpn-tunnels create spoke-office-2 \
  --hub=hub-onprem --region=$LOCATION --vpn-tunnels=$OFFICE2_TUNNELS --quiet || true

echo -e "\n${BLUE}[Tahap 2 & 3] Membuat Hybrid Hub dan menyatukan VPC Spokes...${NC}"
gcloud network-connectivity hubs create hub-hybrid --description="Hub for Hybrid Connectivity" --quiet || true

WORKLOAD1_VPC=$(gcloud compute networks list --format="value(selfLink)" | grep -iE "workload.*1" | head -n 1)
WORKLOAD2_VPC=$(gcloud compute networks list --format="value(selfLink)" | grep -iE "workload.*2" | head -n 1)
OFFICE1_VPC=$(gcloud compute networks list --format="value(selfLink)" | grep -iE "office.*1|on-prem.*1" | head -n 1)

gcloud network-connectivity spokes linked-vpc-network create hybrid-spoke-office-1 \
  --hub=hub-hybrid --global --vpc-network=$OFFICE1_VPC --quiet || true

gcloud network-connectivity spokes linked-vpc-network create hybrid-spoke-workload-1 \
  --hub=hub-hybrid --global --vpc-network=$WORKLOAD1_VPC --quiet || true

gcloud network-connectivity spokes linked-vpc-network create spoke-workload-2 \
  --hub=hub-hybrid --global --vpc-network=$WORKLOAD2_VPC --quiet || true

echo -e "\n${BLUE}[Tahap 4] Membuat Firewall Rules untuk mengizinkan Ping (ICMP)...${NC}"
gcloud compute firewall-rules create allow-icmp-w1 --network=$(basename $WORKLOAD1_VPC) --allow=icmp --source-ranges=0.0.0.0/0 --quiet || true
gcloud compute firewall-rules create allow-icmp-w2 --network=$(basename $WORKLOAD2_VPC) --allow=icmp --source-ranges=0.0.0.0/0 --quiet || true

echo -e "\n${YELLOW}[Tahap 5] Menunggu 120 detik untuk Propagasi Rute BGP jaringan NCC...${NC}"
for i in {120..1}; do
    echo -ne "${CYAN}Tersisa $i detik...${NC}\r"
    sleep 1
done
echo -e "\n${GREEN}[+] Propagasi selesai!${NC}"

echo -e "\n${BLUE}[Tahap 6] Melakukan Ping Test Otomatis (Workload 1 ke Workload 2)...${NC}"
VM1_NAME=$(gcloud compute instances list --filter="name ~ workload-1 OR name ~ workload1" --format="value(name)" | head -n 1)
VM1_ZONE=$(gcloud compute instances list --filter="name ~ workload-1 OR name ~ workload1" --format="value(zone)" | head -n 1)
VM2_IP=$(gcloud compute instances list --filter="name ~ workload-2 OR name ~ workload2" --format="value(networkInterfaces[0].networkIP)" | head -n 1)

gcloud compute ssh $VM1_NAME --zone=$VM1_ZONE --tunnel-through-iap --command="ping -c 4 $VM2_IP" --quiet

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${YELLOW}  LAB SELESAI! Silakan klik 'Check my progress' di lab. ${NC}"
echo -e "${GREEN}======================================================${NC}\n"
EOF

chmod +x himarusetup.sh
