# 🚀 GSP510 - Manage Kubernetes in Google Cloud (Challenge Lab)

![HIMARUSETUP Banner](https://img.shields.io/badge/HIMARUSETUP-AUTOMATION-cyan?style=for-the-badge)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

Script otomatisasi serbaguna dengan tampilan antarmuka terminal interaktif, indikator berjalan, serta proteksi input manual tanpa menyimpan data pribadi/sensitif.

---

## 📌 Deskripsi

Script ini dirancang untuk menyelesaikan secara otomatis tugas-tugas pada **Qwiklabs / Google Cloud Skill Boost GSP510**:
- **Task 1:** Membuat GKE cluster berdasarkan parameter spesifik.
- **Task 2:** Mengaktifkan Managed Prometheus pada cluster GKE.
- **Task 3:** Men-deploy aplikasi awal (mengandung error).
- **Task 4:** Membuat logs-based metric dan Alerting Policy via JSON file.
- **Task 5:** Memperbaiki image pada manifest dan men-deploy ulang aplikasi.
- **Task 6:** Melakukan containerize source code via Docker, push ke Artifact Registry, memperbarui deployment di GKE, serta expose via LoadBalancer.

---

## ⚡ Fitur Utama

- 🎨 **Terminal UI & Banner Custom**: Menampilkan ASCII Banner `[HIMARUSETUP]`.
- 🔄 **Automasi Full-Cycle**: Menyelesaikan konfigurasi GKE, Docker, metrik, dan alert sekaligus.
- 🛠️ **Interactive Input**: Meminta input parameter manual saat dijalankan (Cluster Name, Zone, Namespace, Service Name) agar selalu sesuai dengan panel instruksi lab masing-masing pengguna.
- 🔒 **Aman & Bebas Data Hardcoded**: Tidak mengandung Project ID atau identitas akun tertentu secara tetap, melainkan mendeteksinya dari environment.

---

## 🚀 Cara Penggunaan (Quick Start)

## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` tingkat lanjut (termasuk interaksi dengan Artifact Registry dan Monitoring API) yang memerlukan izin aktif pada project lab Anda, **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP510** di Qwiklabs seperti biasa.
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

3. **Jalankan Script**
   Buka **Google Cloud Shell**, lalu jalankan perintah satu baris berikut:

```bash
curl -LO [https://raw.githubusercontent.com/](https://raw.githubusercontent.com/)<USERNAME-GITHUB-KAMU>/<NAMA-REPO-KAMU>/main/himaru.sh && chmod +x himaru.sh && ./himaru.sh
