#!/bin/bash

# ==========================================
# WARNA & FORMATTING
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}==============================================================${NC}"
echo -e "${YELLOW}       🚀 HIMARUSETUP - GSP322 SECURE NETWORK AUTOMATION      ${NC}"
echo -e "${CYAN}==============================================================${NC}"
echo ""

# ==========================================
# INPUT VARIABLES (Orang lain akan mengisi ini)
# ==========================================
echo -e "${BLUE}[HIMARUSETUP]${NC} Silakan masukkan Network Tags yang ada di halaman Qwiklabs Anda:"
read -p "Masukkan SSH IAP network tag (contoh: allow-ssh-iap-...): " IAP_TAG
read -p "Masukkan SSH internal network tag (contoh: allow-ssh-internal-...): " INTERNAL_TAG
read -p "Masukkan HTTP network tag (contoh: allow-http-ingress-...): " HTTP_TAG
echo ""

# ==========================================
# ANIMASI SPINNER
# ==========================================
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ==========================================
# FUNGSI EKSEKUSI TUGAS
# ==========================================
execute_task() {
    local task_name=$1
    local command=$2

    echo -e "${CYAN}[HIMARUSETUP ⚡]${NC} Memproses: ${YELLOW}$task_name${NC}..."
    eval $command > /dev/null 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    local status=$?

    if [ $status -eq 0 ]; then
        echo -e "${GREEN}[✔] BERHASIL: $task_name${NC}\n"
    else
        echo -e "${RED}[✘] GAGAL: $task_name (Cek ulang jika rule sudah ada)${NC}\n"
    fi
}

# ==========================================
# MULAI EKSEKUSI LAB
# ==========================================
echo -e "${BLUE}[HIMARUSETUP]${NC} Mengambil informasi Zone dari instance..."
ZONE=$(gcloud compute instances list --filter="name=juice-shop" --format="value(zone)")
echo -e "${GREEN}[✔] Zone ditemukan: $ZONE${NC}\n"

# Task 1: Hapus rule open-access
execute_task "Menghapus firewall rule yang terlalu permisif (open-access)" "gcloud compute firewall-rules delete open-access --quiet"

# Task 2: Start bastion host
execute_task "Menyalakan (Start) bastion host instance" "gcloud compute instances start bastion --zone=$ZONE"

# Task 3: SSH IAP ke Bastion
execute_task "Membuat firewall rule untuk SSH via IAP" "gcloud compute firewall-rules create allow-ssh-iap-ingress --network=acme-vpc --allow=tcp:22 --source-ranges=35.235.240.0/20 --target-tags=$IAP_TAG"
execute_task "Menambahkan tag IAP ke bastion host" "gcloud compute instances add-tags bastion --tags=$IAP_TAG --zone=$ZONE"

# Task 4: HTTP ke Juice-shop
execute_task "Membuat firewall rule untuk akses HTTP" "gcloud compute firewall-rules create allow-http-ingress --network=acme-vpc --allow=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=$HTTP_TAG"

# Task 5: SSH Internal dari acme-mgmt-subnet
execute_task "Membuat firewall rule untuk SSH Internal" "gcloud compute firewall-rules create allow-ssh-internal-ingress --network=acme-vpc --allow=tcp:22 --source-ranges=192.168.10.0/24 --target-tags=$INTERNAL_TAG"

# Menambahkan tag ke juice-shop
execute_task "Menambahkan tag HTTP dan SSH Internal ke juice-shop" "gcloud compute instances add-tags juice-shop --tags=$HTTP_TAG,$INTERNAL_TAG --zone=$ZONE"

echo -e "${CYAN}==============================================================${NC}"
echo -e "${GREEN}    🎉 SEMUA TUGAS HIMARUSETUP SELESAI DIKERJAKAN! 🎉       ${NC}"
echo -e "${CYAN}==============================================================${NC}"
echo -e "${YELLOW}Langkah Terakhir Manual:${NC}"
echo -e "1. Cek 'Check my progress' di instruksi lab."
echo -e "2. Jika diminta, login ke bastion: ${CYAN}gcloud compute ssh bastion --zone=$ZONE --tunnel-through-iap${NC}"
echo -e "3. Dari bastion, SSH ke juice-shop: ${CYAN}ssh <internal-ip-juice-shop>${NC}"
