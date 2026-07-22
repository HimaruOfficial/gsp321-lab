# 🚀 GSP342 - Implement Cloud Security Fundamentals on Google Cloud: Challenge Lab

![HIMARUSETUP Banner](https://img.shields.io/badge/HIMARUSETUP-AUTOMATION-cyan?style=for-the-badge)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Security](https://img.shields.io/badge/IAM_Security-FF0000?style=for-the-badge&logo=google-cloud&logoColor=white)

Script otomatisasi serbaguna dengan tampilan antarmuka terminal interaktif warna-warni, indikator berjalan, serta proteksi input manual tanpa menyimpan data pribadi/sensitif.

---

## 📌 Deskripsi

Script ini dirancang untuk menyelesaikan secara otomatis tugas-tugas pada **Qwiklabs / Google Cloud Skill Boost GSP342**:
- **Task 1:** Membuat Custom Security Role dengan perizinan *storage object* spesifik.
- **Task 2:** Membuat Service Account khusus (Dedicated) untuk GKE Cluster.
- **Task 3:** Melakukan *binding* IAM Role (termasuk Role bawaan dan Custom Role) pada Service Account. Menggunakan *delay protection* untuk mencegah *IAM Propagation Error*.
- **Task 4:** Mendeploy GKE Private Cluster pada *custom subnet* yang dikonfigurasi dengan fitur *Master Authorized Networks* yang dihubungkan ke `orca-jumphost`.
- **Task 5:** Mendeploy *test application* ke dalam Private GKE Cluster menggunakan akses SSH via *jumphost*.

---

## ⚡ Fitur Utama

- 🎨 **Terminal UI & Emojis**: Tampilan terminal modern, warna-warni, penuh dengan emoji agar tidak membosankan.
- 🔄 **Automasi Full-Cycle**: Menyelesaikan konfigurasi IAM, Service Account, GKE Private Cluster, dan Deployment dalam satu alur eksekusi beruntun.
- 🛠️ **Interactive Input**: Meminta input parameter manual saat dijalankan (*Custom Security Role*, *Service Account Name*, dan *Cluster Name*) agar selalu sesuai dengan ID acak di panel lab masing-masing pengguna.
- 🔒 **Aman & Bebas Data Hardcoded**: Tidak mengandung Project ID atau identitas akun tertentu secara tetap, melainkan mendeteksinya dari environment secara otomatis.

---

## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` tingkat lanjut (termasuk pembuatan Custom Role IAM dan eksekusi SSH ke dalam VM), **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP342** di Qwiklabs seperti biasa.
   * Buka Google Cloud Console menggunakan akun *Username 1* yang diberikan lab.
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
curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp321-lab/refs/heads/main/GSP342.sh && chmod +x GSP342.sh && ./GSP342.sh
