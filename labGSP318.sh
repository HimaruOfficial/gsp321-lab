#!/bin/bash
# =================================================================
#               HIMARUSETUP AUTOMATION SYSTEM
#     GSP318: Deploy Kubernetes Applications on Google Cloud
# =================================================================

# Warna ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fungsi Banner Visual
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "=================================================================="
    echo "  _  _ ___ __  __    _   ___ _   _ ___ ___ _____ _   _ ___ "
    echo " | || |_ _|  \/  |  /_\ | _ \ | | / __| __|_   _| | | | _ \\"
    echo " | __ || || |\/| | / _ \|   / |_| \__ \ _|  | | | |_| |  _/"
    echo " |_||_|___|_|  |_|/_/ \_\_|_\\___/|___/___| |_|  \___/|_|  "
    echo "=================================================================="
    echo -e "${YELLOW}           AUTO-RUNNER CHALLENGE LAB - GSP318${NC}\n"
}

# Fungsi Loading Spinner Animated
run_with_spinner() {
    local pid=$1
    local task_name=$2
    local spin='-\|/'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r${PURPLE}[HIMARUSETUP]${NC} %s... ${CYAN}[%c]${NC}" "$task_name" "${spin:$i:1}"
        sleep 0.1
    done

    wait $pid
    local exit_status=$?

    if [ $exit_status -eq 0 ]; then
        printf "\r${PURPLE}[HIMARUSETUP]${NC} %s... ${GREEN}[SUCCESS ✔]${NC}\n" "$task_name"
    else
        printf "\r${PURPLE}[HIMARUSETUP]${NC} %s... ${RED}[FAILED ✘]${NC}\n" "$task_name"
        exit 1
    fi
}

show_banner

# Deteksi otomatis Project ID aktif (jika ada)
AUTO_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

echo -e "${BOLD}${CYAN}--- INPUT PARAMS MANUALL (Tekan Enter untuk memakai default) ---${NC}\n"

# Menu Input Manual
read -p "$(echo -e ${YELLOW}"[1] Input Project ID [Default: $AUTO_PROJECT_ID]: "${NC})" PROJECT_ID
PROJECT_ID=${PROJECT_ID:-$AUTO_PROJECT_ID}

read -p "$(echo -e ${YELLOW}"[2] Input Region [Default: us-east4]: "${NC})" REGION
REGION=${REGION:-"us-east4"}

read -p "$(echo -e ${YELLOW}"[3] Input Zone [Default: us-east4-a]: "${NC})" ZONE
ZONE=${ZONE:-"us-east4-a"}

read -p "$(echo -e ${YELLOW}"[4] Input Repository Name [Default: valkyrie-docker]: "${NC})" REPO
REPO=${REPO:-"valkyrie-docker"}

read -p "$(echo -e ${YELLOW}"[5] Input Docker Image Name [Default: valkyrie-app]: "${NC})" IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-"valkyrie-app"}

read -p "$(echo -e ${YELLOW}"[6] Input Image Tag [Default: v0.0.3]: "${NC})" TAG
TAG=${TAG:-"v0.0.3"}

# Susun Jalur Full Docker Image
FULL_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${TAG}"

echo -e "\n------------------------------------------------------------------"
echo -e "${GREEN}Konfigurasi Eksekusi:${NC}"
echo -e "  • Project ID : ${BOLD}${PROJECT_ID}${NC}"
echo -e "  • Region     : ${BOLD}${REGION}${NC}"
echo -e "  • Zone       : ${BOLD}${ZONE}${NC}"
echo -e "  • Repository : ${BOLD}${REPO}${NC}"
echo -e "  • Image Tag  : ${BOLD}${FULL_IMAGE}${NC}"
echo -e "------------------------------------------------------------------\n"

sleep 2

# =================================================================
# TASK 1: Create Docker Image and Store Dockerfile
# =================================================================
echo -e "${BOLD}${CYAN}>>> TASK 1: Mempersiapkan Kode & Membangun Docker Image${NC}"

(
    source <(gsutil cat gs://spls/gsp318/script.sh) > /dev/null 2>&1
    gsutil cp gs://spls/gsp318/valkyrie-app.tgz . > /dev/null 2>&1
    tar -xzf valkyrie-app.tgz
    cd valkyrie-app || exit

    cat <<EOF > Dockerfile
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

    docker build -t ${IMAGE_NAME}:${TAG} . > /dev/null 2>&1
) &
run_with_spinner $! "Downloading source code & Building Docker image (${IMAGE_NAME}:${TAG})"


# =================================================================
# TASK 2: Test Created Docker Image
# =================================================================
echo -e "\n${BOLD}${CYAN}>>> TASK 2: Pengujian Lokal Docker Container${NC}"

(
    docker run -d -p 8080:8080 --name ${IMAGE_NAME} ${IMAGE_NAME}:${TAG} > /dev/null 2>&1 || docker run -d -p 8080:8080 ${IMAGE_NAME}:${TAG} > /dev/null 2>&1
    sleep 3
) &
run_with_spinner $! "Launching container & mapping port 8080"


# =================================================================
# TASK 3: Push Docker Image to Artifact Registry
# =================================================================
echo -e "\n${BOLD}${CYAN}>>> TASK 3: Konfigurasi Artifact Registry & Push Image${NC}"

(
    gcloud artifacts repositories create ${REPO} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository" > /dev/null 2>&1 || true

    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet > /dev/null 2>&1

    docker tag ${IMAGE_NAME}:${TAG} ${FULL_IMAGE} > /dev/null 2>&1
    docker push ${FULL_IMAGE} > /dev/null 2>&1
) &
run_with_spinner $! "Creating Artifact Registry repo & Pushing Image"


# =================================================================
# TASK 4: Create and Expose Deployment in Kubernetes
# =================================================================
echo -e "\n${BOLD}${CYAN}>>> TASK 4: Deploy & Expose ke Google Kubernetes Engine (GKE)${NC}"

(
    cd ~/valkyrie-app/k8s || exit

    gcloud container clusters get-credentials valkyrie-dev --zone ${ZONE} > /dev/null 2>&1

    sed -i "s|image: .*|image: ${FULL_IMAGE}|g" deployment.yaml
    sed -i "s|VALKYRIE-IMAGE|${FULL_IMAGE}|g" deployment.yaml 2>/dev/null || true

    kubectl apply -f deployment.yaml > /dev/null 2>&1
    kubectl apply -f service.yaml > /dev/null 2>&1
) &
run_with_spinner $! "Configuring Kubernetes cluster & Applying deployments"

# =================================================================
# FINISH
# =================================================================
echo -e "\n------------------------------------------------------------------"
echo -e "${GREEN}${BOLD}   🎉 SEMUA TASK BERHASIL DISELESAIKAN OLEH HIMARUSETUP! 🎉${NC}"
echo -e "------------------------------------------------------------------"
