#!/bin/bash

# ==========================================
# Konfigurasi Warna untuk Terminal
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
BLINK='\033[5m'
NC='\033[0m' # No Color

# ==========================================
# Animasi ERIK GANTENG
# ==========================================
erik_ganteng_anim() {
    clear
    echo -e "\n\n"
    local text="E R I K   G A N T E N G"
    local delay=0.1
    
    # Efek Mengetik
    echo -ne "          "
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${CYAN}${BOLD}${text:$i:1}${NC}"
        sleep $delay
    done
    echo ""
    
    # Efek Kedap-Kedip Warna Warni
    for i in {1..6}; do
        echo -ne "\r          ${RED}${BOLD}E R I K   G A N T E N G${NC}"
        sleep 0.15
        echo -ne "\r          ${YELLOW}${BOLD}E R I K   G A N T E N G${NC}"
        sleep 0.15
        echo -ne "\r          ${GREEN}${BOLD}E R I K   G A N T E N G${NC}"
        sleep 0.15
        echo -ne "\r          ${PURPLE}${BOLD}E R I K   G A N T E N G${NC}"
        sleep 0.15
    done
    
    echo -e "\r          ${CYAN}${BOLD}E R I K   G A N T E N G${NC}"
    echo -e "\n      ${YELLOW}${BLINK}🔥 Memuat Script Auto Lab... 🔥${NC}\n"
    sleep 2
    clear
}

# ==========================================
# Fungsi Animasi Loading (Spinner)
# ==========================================
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Mulai Animasi Erik Ganteng
erik_ganteng_anim

export REGION="europe-west3"
export ZONE="europe-west3-c"

echo -e "${CYAN}${BOLD}=====================================================${NC}"
echo -e "${CYAN}${BOLD}    AUTO SCRIPT: Develop your Google Cloud Network   ${NC}"
echo -e "${CYAN}${BOLD}                   (Challenge Lab)                   ${NC}"
echo -e "${CYAN}${BOLD}=====================================================${NC}"
echo ""

# Meminta input Username 2 dari pengguna
read -p "$(echo -e ${YELLOW}"Masukkan Username 2 (contoh: student-0x-xxx@qwiklabs.net): "${NC})" USER_2
echo ""
echo -e "${GREEN}Terima kasih! Memulai otomatisasi untuk project: ${BOLD}$GOOGLE_CLOUD_PROJECT${NC}"
echo -e "${YELLOW}Catatan: Beberapa proses (Database & GKE) membutuhkan waktu 3-5 menit.${NC}"
echo "-----------------------------------------------------"

# ==========================================
# TASK 1: Development VPC
# ==========================================
echo -e "${BLUE}[*] Task 1: Membuat development VPC dan subnets...${NC}"
(
    gcloud compute networks create griffin-dev-vpc --subnet-mode=custom > /dev/null 2>&1
    gcloud compute networks subnets create griffin-dev-wp --network=griffin-dev-vpc --region=$REGION --range=192.168.16.0/20 > /dev/null 2>&1
    gcloud compute networks subnets create griffin-dev-mgmt --network=griffin-dev-vpc --region=$REGION --range=192.168.32.0/20 > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 1 Selesai!${NC}"

# ==========================================
# TASK 2: Production VPC
# ==========================================
echo -e "${BLUE}[*] Task 2: Membuat production VPC dan subnets...${NC}"
(
    gcloud compute networks create griffin-prod-vpc --subnet-mode=custom > /dev/null 2>&1
    gcloud compute networks subnets create griffin-prod-wp --network=griffin-prod-vpc --region=$REGION --range=192.168.48.0/20 > /dev/null 2>&1
    gcloud compute networks subnets create griffin-prod-mgmt --network=griffin-prod-vpc --region=$REGION --range=192.168.64.0/20 > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 2 Selesai!${NC}"

# ==========================================
# TASK 3: Bastion Host
# ==========================================
echo -e "${BLUE}[*] Task 3: Membuat Bastion Host dan rule Firewall...${NC}"
(
    gcloud compute firewall-rules create bastion-ssh-dev --network=griffin-dev-vpc --allow=tcp:22 --source-ranges=0.0.0.0/0 > /dev/null 2>&1
    gcloud compute firewall-rules create bastion-ssh-prod --network=griffin-prod-vpc --allow=tcp:22 --source-ranges=0.0.0.0/0 > /dev/null 2>&1
    gcloud compute instances create bastion \
        --zone=$ZONE \
        --machine-type=e2-medium \
        --network-interface=subnet=griffin-dev-mgmt \
        --network-interface=subnet=griffin-prod-mgmt > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 3 Selesai!${NC}"

# ==========================================
# TASK 4: Cloud SQL
# ==========================================
echo -e "${BLUE}[*] Task 4: Membuat Cloud SQL DB (Ini memakan waktu cukup lama, mohon bersabar)...${NC}"
(
    gcloud sql instances create griffin-dev-db \
        --region=$REGION \
        --database-version=MYSQL_8_0 \
        --tier=db-n1-standard-1 > /dev/null 2>&1
    gcloud sql databases create wordpress --instance=griffin-dev-db > /dev/null 2>&1
    gcloud sql users create wp_user --host="%" --instance=griffin-dev-db --password="stormwind_rules" > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 4 Selesai!${NC}"

# ==========================================
# TASK 5: Kubernetes Cluster
# ==========================================
echo -e "${BLUE}[*] Task 5: Membuat Kubernetes Cluster (Ini juga memakan waktu lama)...${NC}"
(
    gcloud container clusters create griffin-dev \
        --zone=$ZONE \
        --network=griffin-dev-vpc \
        --subnetwork=griffin-dev-wp \
        --machine-type=e2-standard-4 \
        --num-nodes=2 > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 5 Selesai!${NC}"

# ==========================================
# TASK 6 & 7: Kubernetes Prepare & Deploy
# ==========================================
echo -e "${BLUE}[*] Task 6 & 7: Konfigurasi dan Deploy WordPress ke Kubernetes...${NC}"
(
    gsutil cp -r gs://spls/gsp321/wp-k8s . > /dev/null 2>&1
    cd wp-k8s
    sed -i 's/username_goes_here/wp_user/g' wp-env.yaml
    sed -i 's/password_goes_here/stormwind_rules/g' wp-env.yaml

    gcloud iam service-accounts keys create key.json --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com > /dev/null 2>&1
    gcloud container clusters get-credentials griffin-dev --zone=$ZONE > /dev/null 2>&1
    kubectl create secret generic cloudsql-instance-credentials --from-file key.json > /dev/null 2>&1
    kubectl apply -f wp-env.yaml > /dev/null 2>&1

    INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe griffin-dev-db --format="value(connectionName)")
    sed -i "s/YOUR_SQL_INSTANCE/$INSTANCE_CONNECTION_NAME/g" wp-deployment.yaml

    kubectl apply -f wp-deployment.yaml > /dev/null 2>&1
    kubectl apply -f wp-service.yaml > /dev/null 2>&1
) & spinner $!
echo -e "${GREEN}[+] Task 6 & 7 Selesai!${NC}"

# ==========================================
# TASK 9: IAM Access
# ==========================================
echo -e "${BLUE}[*] Task 9: Memberikan akses Editor ke Username 2...${NC}"
(
    if [ ! -z "$USER_2" ]; then
        gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
            --member="user:$USER_2" \
            --role="roles/editor" > /dev/null 2>&1
    fi
) & spinner $!
if [ ! -z "$USER_2" ]; then
    echo -e "${GREEN}[+] Task 9 Selesai! Akses diberikan ke $USER_2.${NC}"
else
    echo -e "${RED}[!] Task 9 Dilewati (Username 2 kosong).${NC}"
fi

# ==========================================
# MENGAMBIL EXTERNAL IP & TUTORIAL TASK 8
# ==========================================
echo ""
echo -e "${YELLOW}Menunggu IP External Load Balancer dari WordPress (membutuhkan beberapa detik)...${NC}"
WP_IP=""
for i in {1..12}; do
    WP_IP=$(kubectl get svc wp-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$WP_IP" ]; then
        break
    fi
    sleep 5
    printf "."
done

echo ""
echo -e "${CYAN}${BOLD}=====================================================${NC}"
echo -e "${GREEN}${BOLD}               SEMUA SCRIPT SELESAI!                 ${NC}"
echo -e "${CYAN}${BOLD}=====================================================${NC}"
echo ""
echo -e "${YELLOW}${BOLD}>> INSTRUKSI TERAKHIR UNTUK TASK 8 (ENABLE MONITORING)${NC}"
echo -e "Silakan ikuti langkah manual berikut di Google Cloud Console:"
echo ""
echo -e "1. Di menu pencarian atas, cari dan klik ${BOLD}'Uptime Checks'${NC}."
echo -e "2. Di bagian atas, klik tombol ${BOLD}+ CREATE UPTIME CHECK${NC}."
echo -e "3. Konfigurasi dengan pengaturan berikut:"
echo -e "   - Protocol      : ${CYAN}HTTP${NC}"
echo -e "   - Resource Type : ${CYAN}URL${NC}"
if [ -n "$WP_IP" ]; then
    echo -e "   - Hostname      : ${GREEN}${BOLD}$WP_IP${NC}  <-- (Copy IP ini!)"
else
    echo -e "   - Hostname      : ${RED}[Ketik perintah 'kubectl get services' untuk melihat External IP wp-service]${NC}"
fi
echo -e "   - Path          : / (biarkan default)"
echo -e "4. Klik tombol ${BOLD}Continue${NC} terus ke bawah."
echo -e "5. Klik tombol ${BOLD}Test${NC} (pastikan muncul centang hijau)."
echo -e "6. Terakhir, klik ${BOLD}Create${NC}."
echo ""
echo -e "${GREEN}Setelah itu, kembali ke halaman Qwiklabs dan klik 'Check my progress' pada Task 8.${NC}"
