# 🚀 GSP318 - Deploy Kubernetes Applications on Google Cloud (Challenge Lab)

![HIMARUSETUP Banner](https://img.shields.io/badge/HIMARUSETUP-AUTOMATION-cyan?style=for-the-badge)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

Script otomatisasi serbaguna dengan tampilan antarmuka terminal interaktif, indikator animasi *loading spinner*, serta proteksi input manual tanpa menyimpan data pribadi/sensitif.

---

## 📌 Deskripsi

Script ini dirancang untuk menyelesaikan tugas pada **Qwiklabs / Google Cloud Skill Boost GSP318**:
- **Task 1:** Membuat Docker image & menyimpan `Dockerfile`.
- **Task 2:** Pengujian lokal container Docker di port `8080`.
- **Task 3:** Konfigurasi Artifact Registry & push Docker image.
- **Task 4:** Deploy dan expose aplikasi ke Google Kubernetes Engine (GKE).

---

## ⚡ Fitur Utama

- 🎨 **Terminal UI & Banner Custom**: Menampilkan ASCII Banner `[HIMARUSETUP]`.
- 🔄 **Animated Loading Spinner**: Visual indikator proses berjalan di background.
- 🛠️ **Interactive Input**: Input parameter manual saat dijalankan (Project ID, Region, Zone, Image Tag).
- 🔒 **Aman & Bebas Data Hardcoded**: Tidak mengandung Project ID atau identitas akun tertentu secara tetap.
- ⚡ **Auto Fallback**: Menekan `Enter` pada prompt akan otomatis memakai variabel default lingkungan Cloud Shell.

---

## 🚀 Cara Penggunaan (Quick Start)
## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` tingkat lanjut yang memerlukan izin aktif pada project lab Anda, **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP318** di Qwiklabs seperti biasa.
   * Buka Google Cloud Console menggunakan akun *Username 1*.
   * Klik ikon **Cloud Shell** (terminal `>_`) di pojok kanan atas Cloud Console.

2. **Lakukan Autentikasi Akun (`gcloud auth login`)**
   * Ketik perintah di bawah ini di terminal Cloud Shell, lalu tekan `Enter`:
     ```bash
     gcloud auth login
     ```
   * Terminal akan memunculkan sebuah link URL panjang dan pertanyaan konfirmasi. Tekan `Y` (Yes) atau *Ctrl + Klik* pada link tersebut untuk membukanya di browser.
   * Di tab browser baru, login menggunakan akun Google Qwiklabs yang aktif.
   * Klik **Allow / Continue / Confirm** untuk memberikan izin akses.
   * Anda akan diberikan sebuah **kode verifikasi (verification code)**. Klik tombol **Copy** pada kode tersebut.
   * Kembali ke terminal Cloud Shell, **paste (tempel)** kode verifikasi yang sudah di-copy tadi ke dalam terminal, lalu tekan `Enter`.

Buka **Google Cloud Shell**, lalu jalankan perintah satu baris berikut:

```bash
curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp321-lab/refs/heads/main/labGSP318.sh && chmod +x labGSP318.sh && ./labGSP318.sh
