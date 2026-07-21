#!/bin/bash
# ========================================================
#   HIMARU SETUP - GSP329 CHALLENGE LAB AUTOMATION
#   Enhanced with Matrix/Hacker UI Theme & Manual Input
# ========================================================

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
MATRIX_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

clear

# Banner Animation (Hacker Matrix Style)
echo -e "${MATRIX_GREEN}${BOLD}"
cat << "EOF"
  _   _ _____ __  __    _    ____  _   _ ____  _____ _____ _   _ ____  
 | | | |_   _|  \/  |  / \  |  _ \| | | / ___|| ____|_   _| | | |  _ \ 
 | | | | | | | |\/| | / _ \ | |_) | | | \___ \|  _|   | | | | | | |_) |
 | |_| | | | | |  | |/ ___ \|  _ <| |_| |___) | |___  | | | |_| |  __/ 
  \___/  |_| |_|  |_/_/   \_\_| \_\\___/|____/|_____| |_|  \___/|_|    
EOF
echo -e "${GREEN}======================================================================${RESET}"
echo -e "${YELLOW}${BOLD}     GSP329 : Use Machine Learning APIs on Google Cloud (Challenge)   ${RESET}"
echo -e "${GREEN}======================================================================${RESET}\n"

# --------------------------------------------------------
# MANUAL INPUT SECTION
# --------------------------------------------------------
echo -e "${CYAN}[*] SYSTEM INITIALIZATION - USER INPUT REQUIRED${RESET}\n"

# Get default project from gcloud
AUTO_PROJECT=$(gcloud config get-value project 2>/dev/null)

echo -e "${WHITE}Project ID otomatis terdeteksi: ${MATRIX_GREEN}${AUTO_PROJECT}${RESET}"
echo -ne "${YELLOW}[?] Masukkan Project ID ${WHITE}(Tekan ENTER untuk pakai yang otomatis): ${RESET}"
read USER_PROJECT

# Assign Project ID based on user input
if [ -z "$USER_PROJECT" ]; then
    export PROJECT_ID=$AUTO_PROJECT
else
    export PROJECT_ID=$USER_PROJECT
fi

echo -ne "${YELLOW}[?] Masukkan Nama Service Account ${WHITE}(Default: ml-lab-sa): ${RESET}"
read USER_SA
export SA_NAME=${USER_SA:-"ml-lab-sa"}
export KEY_FILE="${HOME}/key.json"

echo -e "\n${CYAN}======================================================================${RESET}"
echo -e "${YELLOW}[*] Target Project ID : ${BOLD}${MATRIX_GREEN}${PROJECT_ID}${RESET}"
echo -e "${YELLOW}[*] Service Account   : ${BOLD}${MATRIX_GREEN}${SA_NAME}${RESET}"
echo -e "${CYAN}======================================================================${RESET}\n"

# Pause before execution
read -n 1 -s -r -p "$(echo -e ${MATRIX_GREEN}"[!] Tekan ENTER untuk memulai eksekusi sistem... (Atau CTRL+C untuk batal)"${RESET})"
echo -e "\n"

# Hacker-style Spinner Animation
hacker_spin() {
    local pid=$1
    local msg=$2
    local delay=0.07
    local spinstr=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
    
    # Hide cursor
    tput civis 
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinstr[@]}"; do
            printf "\r${MATRIX_GREEN}[ %s ]${RESET} ${CYAN}%s...${RESET}" "$i" "$msg"
            sleep $delay
        done
    done
    # Show cursor & print success
    tput cnorm 
    printf "\r${MATRIX_GREEN}[ ✔ ]${RESET} ${WHITE}%s... ${MATRIX_GREEN}[DONE]${RESET}\033[K\n" "$msg"
}

log_step() {
    echo -e "\n${BLUE}${BOLD}[TASK $1]${RESET} ${WHITE}$2${RESET}"
}

# --------------------------------------------------------
# TASK 1: Service Account & IAM Roles
# --------------------------------------------------------
log_step "1" "Konfigurasi Service Account & IAM Roles"

gcloud iam service-accounts create ${SA_NAME} --display-name="Machine Learning Lab SA" >/dev/null 2>&1 &
hacker_spin $! "Membuat Service Account (${SA_NAME})"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataOwner" >/dev/null 2>&1 &
hacker_spin $! "Binding Role: BigQuery Data Owner"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin" >/dev/null 2>&1 &
hacker_spin $! "Binding Role: Storage Object Admin"

# --------------------------------------------------------
# TASK 2: Download Credentials & Environment Variable
# --------------------------------------------------------
log_step "2" "Mengamankan Credentials"

gcloud iam service-accounts keys create ${KEY_FILE} \
    --iam-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" >/dev/null 2>&1 &
hacker_spin $! "Mengunduh file JSON Authentication"

export GOOGLE_APPLICATION_CREDENTIALS="${KEY_FILE}"
export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"

# --------------------------------------------------------
# TASK 3 & 4: Python Script Generation
# --------------------------------------------------------
log_step "3 & 4" "Injeksi Skrip Python untuk Vision & Translate API"

cat << 'PYEOF' > analyze-images-v2.py
import os, time
from google.cloud import vision
from google.cloud import translate_v2 as translate
from google.cloud import bigquery
from google.cloud import storage

# Initialize API Clients
vision_client = vision.ImageAnnotatorClient()
translate_client = translate.Client()
bigquery_client = bigquery.Client()
storage_client = storage.Client()

project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
bucket_name = project_id

bucket = storage_client.get_bucket(bucket_name)

dataset_id = 'image_classification_dataset'
table_id = 'image_text_detail'
table_ref = bigquery_client.dataset(dataset_id).table(table_id)
table = bigquery_client.get_table(table_ref)

rows_to_insert = []
print("\033[1;36m[System]\033[0m Mengolah data dari Cloud Storage Bucket...")

blobs = bucket.list_blobs()
for blob in blobs:
    if blob.name.lower().endswith(('.jpg', '.jpeg', '.png')):
        print(f"  \033[1;32m[+]\033[0m Processing: {blob.name}")
        image_uri = f"gs://{bucket_name}/{blob.name}"
        image = vision.Image()
        image.source.image_uri = image_uri

        # Vision API - Extract Text
        response = vision_client.document_text_detection(image=image)
        extracted_text = response.full_text_annotation.text if response.full_text_annotation else ""

        # Upload Text to Storage
        txt_filename = blob.name.rsplit('.', 1)[0] + '.txt'
        txt_blob = bucket.blob(txt_filename)
        txt_blob.upload_from_string(extracted_text)

        # Translation API
        if extracted_text.strip():
            translation = translate_client.translate(extracted_text, target_language='en')
            translated_text = translation.get('translatedText', '')
            locale = translation.get('detectedSourceLanguage', 'en')
        else:
            translated_text = ""
            locale = "en"

        rows_to_insert.append((blob.name, extracted_text, locale, translated_text))

# Upload Results to BigQuery
if rows_to_insert:
    errors = bigquery_client.insert_rows(table, rows_to_insert)
    if not errors:
        print("\033[1;32m[✔]\033[0m Data berhasil dikirim ke BigQuery secara massal.")
    else:
        print(f"\033[1;31m[x]\033[0m Error BigQuery: {errors}")
PYEOF

sleep 2 &
hacker_spin $! "Menulis analyze-images-v2.py"

# --------------------------------------------------------
# EXECUTION & TASK 5: Run Script & BigQuery Verification Query
# --------------------------------------------------------
log_step "5" "Eksekusi Machine Learning & Verifikasi BigQuery"

python3 analyze-images-v2.py

echo -e "\n${YELLOW}[*] Menjalankan Verifikasi BigQuery...${RESET}"
bq query --use_legacy_sql=false "SELECT locale, COUNT(locale) as lcount FROM \`${PROJECT_ID}.image_classification_dataset.image_text_detail\` GROUP BY locale ORDER BY lcount DESC;"

echo -e "\n${MATRIX_GREEN}${BOLD}======================================================================${RESET}"
echo -e "${MATRIX_GREEN}${BOLD}   [✔] MISSION ACCOMPLISHED! GSP329 COMPLETED. CHECK YOUR SCORE!      ${RESET}"
echo -e "${MATRIX_GREEN}${BOLD}======================================================================${RESET}\n"
