#!/usr/bin/env bash
# ==============================================================================
# GSP342: Implement Cloud Security Fundamentals on Google Cloud
# Auto-Solver Script for Qwiklabs
# ==============================================================================

# Berhenti jika ada error
set -e

# ==============================================================================
# 1. DEKLARASI WARNA & EMOJI
# ==============================================================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

E_ROCKET="🚀"
E_SHIELD="🛡️"
E_CLOUD="☁️"
E_CHECK="✅"
E_WAIT="⏳"
E_KEY="🔑"
E_GEAR="⚙️"
E_BOX="📦"
E_PARTY="🎉"

# ==============================================================================
# 2. BANNER UTAMA
# ==============================================================================
clear
echo -e "${CYAN}========================================================================${NC}"
echo -e "${MAGENTA}                  ${E_CLOUD} GOOGLE CLOUD SKILL BADGE SOLVER ${E_CLOUD}${NC}"
echo -e "${YELLOW}           GSP342: Implement Cloud Security Fundamentals${NC}"
echo -e "${CYAN}========================================================================${NC}"
echo ""
echo -e "${WHITE}Selamat datang! Script ini akan menyelesaikan Challenge Lab Anda.${NC}"
echo -e "${WHITE}Pastikan Anda telah menjalankan lab dan memiliki detail kredensial.${NC}"
echo ""

# ==============================================================================
# 3. INPUT MANUAL DARI USER
# ==============================================================================
echo -e "${GREEN}${E_GEAR} SILAKAN MASUKKAN DATA DARI PANEL LAB ANDA:${NC}"

read -p "$(echo -e ${CYAN}➤ Custom Security Role Name ${NC}(contoh: orca_storage_editor_848): )" ROLE_NAME
read -p "$(echo -e ${CYAN}➤ Service Account Name      ${NC}(contoh: orca-private-cluster-393-sa): )" SA_NAME
read -p "$(echo -e ${CYAN}➤ Cluster Name              ${NC}(contoh: orca-cluster-629): )" CLUSTER_NAME
read -p "$(echo -e ${CYAN}➤ Region                    ${NC}(tekan enter untuk europe-west1): )" REGION
REGION=${REGION:-europe-west1}
read -p "$(echo -e ${CYAN}➤ Zone                      ${NC}(tekan enter untuk europe-west1-c): )" ZONE
ZONE=${ZONE:-europe-west1-c}

echo ""
echo -e "${YELLOW}${E_WAIT} Mengambil Project ID Anda saat ini...${NC}"
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo -e "${GREEN}${E_CHECK} Konfigurasi Diterima:${NC}"
echo -e "${WHITE}- Project ID   : ${CYAN}$PROJECT_ID${NC}"
echo -e "${WHITE}- Service Email: ${CYAN}$SA_EMAIL${NC}"
echo -e "${CYAN}========================================================================${NC}"
echo ""

# ==============================================================================
# TASK 1: Create a custom security role
# ==============================================================================
echo -e "${MAGENTA}${E_SHIELD} [Task 1] Membuat Custom Security Role: ${WHITE}$ROLE_NAME${NC}"
gcloud iam roles create $ROLE_NAME \
  --project=$PROJECT_ID \
  --title="Orca Storage Editor" \
  --description="Custom role for Orca storage permissions" \
  --permissions="storage.buckets.get,storage.objects.get,storage.objects.list,storage.objects.update,storage.objects.create" \
  --stage="GA"
echo -e "${GREEN}${E_CHECK} Task 1 Selesai!${NC}\n"

# ==============================================================================
# TASK 2: Create a service account
# ==============================================================================
echo -e "${MAGENTA}${E_KEY} [Task 2] Membuat Service Account: ${WHITE}$SA_NAME${NC}"
gcloud iam service-accounts create $SA_NAME \
  --display-name="Orca Private Cluster Service Account"
echo -e "${GREEN}${E_CHECK} Task 2 Selesai!${NC}\n"

# MENCEGAH IAM PROPAGATION DELAY (Error binding gagal karena SA belum terdeteksi sistem)
echo -e "${YELLOW}${E_WAIT} Menunggu 15 detik agar Service Account terdaftar di IAM Google Cloud...${NC}"
sleep 15
echo -e "${GREEN}${E_CHECK} Lanjut!${NC}\n"

# ==============================================================================
# TASK 3: Bind IAM security roles to a service account
# ==============================================================================
echo -e "${MAGENTA}${E_GEAR} [Task 3] Menambahkan role binding ke Service Account...${NC}"

ROLES=(
  "roles/monitoring.viewer"
  "roles/monitoring.metricWriter"
  "roles/logging.logWriter"
  "projects/$PROJECT_ID/roles/$ROLE_NAME"
)

for ROLE in "${ROLES[@]}"; do
  echo -e "${BLUE}➤ Menambahkan role: ${WHITE}$ROLE${NC}"
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="$ROLE" > /dev/null 2>&1
  echo -e "${GREEN}  Berhasil diikat!${NC}"
done
echo -e "${GREEN}${E_CHECK} Task 3 Selesai!${NC}\n"

# ==============================================================================
# TASK 4: Create a private GKE cluster in a custom subnet
# ==============================================================================
echo -e "${MAGENTA}${E_BOX} [Task 4] Persiapan membuat Private GKE Cluster...${NC}"
echo -e "${BLUE}➤ Mendapatkan Internal IP dari orca-jumphost...${NC}"

JUMPHOST_IP=$(gcloud compute instances describe orca-jumphost \
  --zone=$ZONE \
  --format='get(networkInterfaces[0].networkIP)')
echo -e "${WHITE}  IP orca-jumphost: ${CYAN}$JUMPHOST_IP${NC}"

echo -e "${BLUE}➤ Mendeploy GKE Private Cluster: ${WHITE}$CLUSTER_NAME ${YELLOW}(Ini memakan waktu sekitar 5-10 menit)${NC}"
gcloud container clusters create $CLUSTER_NAME \
  --zone=$ZONE \
  --network=orca-build-vpc \
  --subnetwork=orca-build-subnet \
  --service-account=$SA_EMAIL \
  --enable-ip-alias \
  --enable-private-nodes \
  --enable-private-endpoint \
  --master-ipv4-cidr="172.16.0.0/28" \
  --enable-master-authorized-networks \
  --master-authorized-networks="${JUMPHOST_IP}/32"
echo -e "${GREEN}${E_CHECK} Task 4 Selesai!${NC}\n"

# ==============================================================================
# TASK 5: Deploy an application to a private GKE cluster
# ==============================================================================
echo -e "${MAGENTA}${E_ROCKET} [Task 5] Mengeksekusi deployment dari orca-jumphost via SSH...${NC}"
echo -e "${YELLOW}${E_WAIT} Proses SSH dan instalasi plugin...${NC}"

gcloud compute ssh orca-jumphost --zone=$ZONE --tunnel-through-iap --quiet --command="
  echo '====================================================='
  echo 'Memulai proses dari dalam orca-jumphost...'
  echo '====================================================='
  
  echo '➤ Menginstal gke-gcloud-auth-plugin...'
  sudo apt-get update -y
  sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
  
  echo '➤ Mengonfigurasi environment variable...'
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  
  echo '➤ Mendapatkan kredensial GKE internal...'
  gcloud container clusters get-credentials $CLUSTER_NAME --internal-ip --project=$PROJECT_ID --zone=$ZONE
  
  echo '➤ Mendeploy hello-server ke cluster...'
  kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
"
echo -e "${GREEN}${E_CHECK} Task 5 Selesai!${NC}\n"

# ==============================================================================
# FINAL
# ==============================================================================
echo -e "${CYAN}========================================================================${NC}"
echo -e "${GREEN}${E_PARTY} SELAMAT! SEMUA TASK TELAH SELESAI DIEKSEKUSI! ${E_PARTY}${NC}"
echo -e "${WHITE}Silakan kembali ke halaman Qwiklabs dan klik ${YELLOW}'Check my progress'${WHITE} pada semua task.${NC}"
echo -e "${CYAN}========================================================================${NC}"
