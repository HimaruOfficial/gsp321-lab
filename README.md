# 🚀 GSP321 Challenge Lab - Automator Script

Script otomatisasi interaktif untuk menyelesaikan **Develop your Google Cloud Network: Challenge Lab (GSP321)** dengan cepat, bersih, dan dilengkapi animasi keren **ERIK GANTENG**.

---

## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` tingkat lanjut yang memerlukan izin aktif pada project lab Anda, **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP321** di Qwiklabs seperti biasa.
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

3. **Salin dan Jalankan Perintah Link Raw**
   * Setelah berhasil login, salin perintah *one-liner* (satu baris) berikut, lalu tempel (*paste*) langsung ke dalam terminal Cloud Shell Anda:
     ```bash
     curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp321-lab/refs/heads/main/gsp321-pro.sh && chmod +x gsp321-pro.sh && ./gsp321-pro.sh```
   * **Penjelasan perintah di atas:**
     * `curl -LO [link_raw]` berfungsi untuk mengunduh file script `gsp321-pro.sh` langsung secara mentah (*raw*) dari repository GitHub.
     * `chmod +x gsp321-pro.sh` memberikan izin agar file tersebut bisa dieksekusi sebagai program.
     * `./gsp321-pro.sh` langsung mengeksekusi script otomatisasinya.

4. **Ikuti Instruksi Interaktif di Layar**
   * Animasi teks **ERIK GANTENG** akan muncul menyambut Anda.
   * Masukkan **Username 2** (akun tambahan dari kredensial lab Anda) saat diminta oleh script, lalu tekan `Enter`.
   * Tunggu beberapa menit hingga proses otomatisasi selesai.

---

## ⚠️ Instruksi Terakhir (Task 8: Enable Monitoring)
Task 8 (Uptime Check) memerlukan tindakan manual di panel Monitoring. Setelah script selesai, ikuti langkah berikut:
1. Cari menu **Uptime Checks** di kolom pencarian Google Cloud Console.
2. Klik tombol **+ CREATE UPTIME CHECK**.
3. Atur konfigurasi berikut:
   * **Protocol:** `HTTP`
   * **Resource Type:** `URL`
   * **Title:** Masukkan nilai *External IP* dari service WordPress sebagai nama judulnya (IP ini otomatis dicetak oleh script di bagian akhir terminal Anda).
   * **Hostname:** Masukkan *External IP* dari service WordPress tersebut.
   * **Path:** `/` (biarkan default).
4. Klik tombol **Continue**, lalu klik **Test** (pastikan muncul centang hijau).
5. Klik **Create**.
6. Kembali ke halaman Qwiklabs dan klik **Check my progress** pada Task 8.

---
*Created with 🔥 by HimaruOfficial*
