# 🚀 GSP322 Challenge Lab - Automator Script

Script otomatisasi interaktif untuk menyelesaikan **Build a Secure Google Cloud Network: Challenge Lab (GSP322)** dengan cepat, bersih, dan dilengkapi animasi keren **HIMARUSETUP**.

---

## 🛠️ Prasyarat Sebelum Menjalankan Script
Karena script ini menggunakan perintah `gcloud` tingkat lanjut yang memerlukan izin aktif pada project lab Anda, **sangat disarankan** untuk melakukan autentikasi akun terlebih dahulu agar terhindar dari *error permission/denied*.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP322** di Qwiklabs seperti biasa.
   * Buka Google Cloud Console menggunakan kredensial lab Anda.
   * Klik ikon **Cloud Shell** (terminal `>_`) di pojok kanan atas Cloud Console.

2. **Lakukan Autentikasi Akun (`gcloud auth login`)**
   * Ketik perintah di bawah ini di terminal Cloud Shell, lalu tekan `Enter`:
     ```
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
     curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp322-lab/refs/heads/main/himaru.sh && chmod +x himaru.sh && ./himaru.sh
     ```
   * **Penjelasan perintah di atas:**
     * `curl -LO [link_raw]` berfungsi untuk mengunduh file script `himaru.sh` langsung secara mentah (*raw*) dari repository GitHub. *(Pastikan link URL di atas sudah disesuaikan dengan link raw di repository Anda)*.
     * `chmod +x himaru.sh` memberikan izin agar file tersebut bisa dieksekusi sebagai program.
     * `./himaru.sh` langsung mengeksekusi script otomatisasinya.

4. **Ikuti Instruksi Interaktif di Layar**
   * Animasi teks **HIMARUSETUP** akan muncul menyambut Anda.
   * Script akan meminta Anda untuk memasukkan **Network Tags** (bisa dilihat di panel kiri halaman instruksi Qwiklabs Anda).
   * Masukkan secara berurutan saat diminta:
     1. **SSH IAP network tag** (contoh: `allow-ssh-iap-ingress-ql-xxx`)
     2. **SSH internal network tag** (contoh: `allow-ssh-internal-ingress-ql-xxx`)
     3. **HTTP network tag** (contoh: `allow-http-ingress-ql-xxx`)
   * Tunggu beberapa saat hingga proses pembuatan *firewall rules* dan penambahan tag selesai dengan status centang hijau.

---

## ⚠️ Instruksi Terakhir (Verifikasi SSH Manual)
Setelah script selesai berjalan 100%, ada satu tindakan manual terakhir yang harus Anda lakukan untuk menyelesaikan task terakhir di Qwiklabs:

1. Di Console Google Cloud, masuk ke menu **Compute Engine > VM Instances**.
2. Catat atau salin **Internal IP** dari instance bernama `juice-shop`.
3. Kembali ke Cloud Shell, masuk ke bastion host menggunakan IAP dengan perintah berikut (ganti `[ZONE]` dengan zona dari lab Anda, misalnya `us-east1-b`):
   ```bash
   gcloud compute ssh bastion --zone=[ZONE] --tunnel-through-iap
