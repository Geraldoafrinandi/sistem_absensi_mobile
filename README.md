#  Sistem Presensi Geofencing: Komparasi Algoritma Haversine & Vincenty

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)]()
[![Vue.js](https://img.shields.io/badge/Vue.js-35495E?style=flat&logo=vue.js&logoColor=4FC08D)]()
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=flat&logo=node.js&logoColor=white)]()
[![MySQL](https://img.shields.io/badge/MySQL-00000F?style=flat&logo=mysql&logoColor=white)]()

Sistem informasi presensi perkuliahan terintegrasi (*Mobile* & *Web*) yang menerapkan teknologi **Geofencing** dan **Dynamic QR Code**. Penelitian ini berfokus pada **Analisis Komparatif** antara algoritma **Haversine** dan **Vincenty** dalam menghitung jarak geodesik mahasiswa terhadap titik koordinat dosen (standar WGS-84) secara *real-time*.

Dikembangkan sebagai Tugas Akhir di Program Studi Teknologi Rekayasa Perangkat Lunak, Jurusan Teknologi Informasi, Politeknik Negeri Padang.

---

##  Cuplikan Layar (Screenshots)
*(Tambahkan gambar antarmuka aplikasi di sini untuk memberikan gambaran visual kepada pembaca)*
| Dashboard Dosen (Web) | Scanner Mahasiswa (Mobile) | Riwayat Presensi |
| :---: | :---: | :---: |
| `[Screenshot Web]` | `[Screenshot Mobile]` | `[Screenshot Riwayat]` |

---

## ⚙️ Cara Kerja Sistem (Alur Presensi)

1. **Inisiasi Sesi:** Dosen membuka sesi perkuliahan melalui aplikasi Web/Mobile. Sistem mencatat titik koordinat (GPS) laptop/perangkat dosen sebagai titik referensi (*center point*).
2. **Dynamic QR Code:** Sistem memunculkan QR Code di layar dosen yang akan diperbarui (di-*refresh*) secara otomatis setiap 5 detik untuk mencegah kecurangan via *video call* atau *screen sharing*.
3. **Pemindaian (Scanning):** Mahasiswa melakukan *scan* QR Code menggunakan aplikasi Flutter. Aplikasi akan memvalidasi masa aktif JWT (maksimal 15 menit) sebelum mengambil koordinat GPS mahasiswa.
4. **Komputasi Jarak:** Backend Node.js menerima data koordinat dan mengeksekusi perhitungan jarak menggunakan **Haversine** dan **Vincenty** secara bersamaan.
5. **Validasi Geofencing:** Jika jarak (berdasarkan kalkulasi Vincenty) berada di luar batas radius yang ditentukan, presensi ditolak. Jika sesuai, data disimpan beserta catatan waktu (*timestamp*) dan waktu komputasi milidetik dari kedua algoritma.

---

## 📂 Struktur Direktori

Proyek ini menggunakan struktur *Monorepo* yang memuat tiga layanan utama:

```text
📦 project-root
 ┣ 📂 backend            # REST API & WebSocket (Node.js, Express, Sequelize)
 ┃ ┣ 📂 src/controllers  # Logika bisnis (Auth, Absensi, Sesi)
 ┃ ┣ 📂 src/models       # Skema database MySQL
 ┃ ┗ 📜 test_real.js     # Script Load Testing & Concurrency
 ┣ 📂 mobile-mahasiswa   # Aplikasi Mobile Mahasiswa (Flutter, Dart)
 ┃ ┣ 📂 lib/core         # Konfigurasi, endpoint API, dan servis lokal
 ┃ ┗ 📂 lib/modules      # UI/UX Scanner, Dashboard, Riwayat
 ┗ 📂 web-dosen          # Dashboard Dosen & Admin (Vue.js, Tailwind CSS)
   ┣ 📂 src/components   # Komponen UI Reusable
   ┗ 📂 src/views        # Halaman utama Web
