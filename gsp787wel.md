# 🚀 GSP787 Challenge Lab - Automator Script

Script otomatisasi interaktif untuk menyelesaikan **Derive Insights from BigQuery Data: Challenge Lab (GSP787)** dengan cepat, bersih, dan dilengkapi animasi keren **HIMARUSETUP**.

---

## ✨ Deskripsi Lab
Lab ini menguji kemampuan Anda dalam menganalisis dataset publik COVID-19 (`bigquery-public-data.covid19_open_data.covid19_open_data`) menggunakan kueri SQL di BigQuery. Script ini secara otomatis mengeksekusi semua kueri SQL yang dibutuhkan dari Task 1 hingga Task 10 sehingga Anda bisa mendapatkan skor **100/100** dengan cepat.

---

## 📖 Tutorial Cara Penggunaan & Link Raw

### Langkah-Langkah di Cloud Shell Lab:

1. **Start Lab & Buka Cloud Shell**
   * Mulai lab **GSP787** di Qwiklabs / Google Cloud Skills Boost.
   * Buka Google Cloud Console menggunakan akun student Qwiklabs Anda.
   * Klik ikon **Cloud Shell** (terminal `>_`) di pojok kanan atas Cloud Console.

2. **Lakukan Autentikasi Akun (`gcloud auth login`) - *Opsional/Jika Diminta***
   * Jika Cloud Shell meminta konfirmasi izin atau otorisasi tambahan, jalankan:
     ```bash
     gcloud auth login
     ```
   * Buka link yang muncul, login menggunakan akun student Qwiklabs Anda, izinkan akses, lalu salin kode verifikasi dan paste di Cloud Shell.

3. **Salin dan Jalankan Perintah Link Raw**
   * Salin perintah *one-liner* berikut, lalu tempel (*paste*) langsung ke dalam terminal Cloud Shell Anda:
     ```bash
     curl -LO https://raw.githubusercontent.com/HimaruOfficial/gsp321-lab/refs/heads/main/gsp787.sh && chmod +x himaru_final.sh && ./himaru_final.sh
     ```
   * **Penjelasan perintah di atas:**
     * `curl -LO [link_raw]` mengunduh file script `himaru_final.sh` langsung secara mentah (*raw*) dari repository GitHub.
     * `chmod +x himaru_final.sh` memberikan izin akses eksekusi pada script.
     * `./himaru_final.sh` mengeksekusi otomatisasi script.

4. **Tunggu Animasi & Proses Selesai**
   * Animasi khas **HIMARUSETUP** akan muncul menyambut Anda.
   * Tunggu beberapa saat hingga seluruh kueri Task 1 sampai Task 10 berhasil dieksekusi.

---

## ⚠️ Instruksi Tambahan (Task 10: Create a Data Studio report)
Meskipun script telah mengeksekusi kueri BigQuery untuk Task 10, jika tombol **Check my progress** pada Task 10 belum terceklis otomatis, lakukan langkah visualisasi manual berikut:

1. Buka [Looker Studio](https://datastudio.google.com/) menggunakan akun Qwiklabs Anda.
2. Klik **Blank Report** -> Pilih konektor **BigQuery**.
3. Pilih **Custom Query** -> Pilih Project ID Anda (`qwiklabs-gcp-...`).
4. Masukkan kueri SQL berikut:
   ```sql
   SELECT date, SUM(cumulative_confirmed) AS country_cases, SUM(cumulative_deceased) AS country_deaths
   FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
   WHERE country_name='United States of America' AND date BETWEEN '2020-03-22' AND '2020-04-30'
   GROUP BY date;
