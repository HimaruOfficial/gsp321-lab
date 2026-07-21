# 🚀 GSP329 - Use Machine Learning APIs on Google Cloud (Challenge Lab)

![HIMARUSETUP Banner](https://img.shields.io/badge/HIMARUSETUP-AUTOMATION-cyan?style=for-the-badge)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-669DF6?style=for-the-badge&logo=googlecloud&logoColor=white)

Script otomatisasi serbaguna dengan tampilan antarmuka *Hacker/Matrix* interaktif di terminal, indikator berjalan, serta proteksi input manual tanpa menyimpan data pribadi/sensitif.

---

## 📌 Deskripsi

Script ini dirancang untuk menyelesaikan secara otomatis tugas-tugas pada **Qwiklabs / Google Cloud Skill Boost GSP329**:
- **Task 1:** Membuat Service Account khusus lab dan memberikan hak akses IAM (BigQuery Data Owner & Storage Object Admin).
- **Task 2:** Membuat dan mengunduh *Authentication Credentials* (Key JSON) ke environment.
- **Task 3:** Memodifikasi skrip Python untuk mengekstrak teks dari gambar di Cloud Storage menggunakan **Cloud Vision API**.
- **Task 4:** Memodifikasi skrip Python untuk mendeteksi bahasa dan menerjemahkan teks menggunakan **Cloud Translation API**.
- **Task 5:** Memasukkan (*load*) data hasil analisis ke BigQuery dan menjalankan *query* verifikasi.

---

## ⚡ Fitur Utama

- 🎨 **Terminal UI Matrix/Hacker**: Menampilkan ASCII Banner `[HIMARUSETUP]` dan animasi *Braille Matrix Spinner*.
- 🔄 **Automasi Full-Cycle**: Menyelesaikan pembuatan IAM, penulisan skrip Python, pemrosesan Machine Learning, dan BigQuery sekaligus.
- 🛠️ **Interactive Input**: Meminta input parameter manual saat dijalankan (Project ID & Service Account Name) agar selalu sesuai dengan panel instruksi lab masing-masing pengguna.
- 🔒 **Aman & Bebas Data Hardcoded**: Tidak mengandung Project ID atau identitas akun tertentu secara tetap, melainkan meminta konfirmasi dari *environment* saat ini.

---

## 🚀 Cara Penggunaan (Quick Start)

## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` untuk pembuatan IAM, Service Account Keys, dan pemanggilan API yang memerlukan izin aktif pada project lab Anda, **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP329** di Qwiklabs seperti biasa.
   * Buka Google Cloud Console menggunakan kredensial lab yang diberikan.
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
curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp321-lab/refs/heads/main/gsp329.sh && chmod +x gsp329.sh && ./gsp329.sh
