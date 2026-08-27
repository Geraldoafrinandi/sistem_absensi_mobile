# 📍 Sistem Presensi Geofencing: Analisis Komparatif Algoritma Haversine & Vincenty

Sistem informasi presensi perkuliahan berbasis *Mobile* dan *Web* yang menerapkan teknologi **Geofencing** dan **Dynamic QR Code**. Proyek ini dikembangkan untuk membandingkan tingkat akurasi dan performa waktu komputasi antara **Algoritma Haversine** dan **Algoritma Vincenty** dalam menentukan jarak presensi mahasiswa terhadap lokasi dosen (WGS-84).

Proyek ini dikembangkan sebagai bagian dari penelitian Tugas Akhir di Program Studi Teknologi Rekayasa Perangkat Lunak, Jurusan Teknologi Informasi, Politeknik Negeri Padang.

---

## ✨ Fitur Utama

- **Geofencing Validation:** Validasi lokasi mahasiswa secara presisi menggunakan sensor GPS *smartphone*.
- **Algoritma Komparatif:** Menghitung jarak geodesik menggunakan metode Haversine dan Vincenty secara *real-time* di sisi server, lengkap dengan pencatatan waktu komputasi (milidetik).
- **Dynamic QR Code:** Kode QR sesi perkuliahan yang di-*refresh* otomatis setiap beberapa detik untuk mencegah kecurangan manipulasi jarak jauh (*screen sharing/video call*).
- **Real-time Dashboard:** Dosen dapat melihat jumlah mahasiswa yang hadir secara *real-time* tanpa perlu me-*refresh* halaman (didukung oleh Socket.io).
- **Security:** Autentikasi berbasis JSON Web Token (JWT) dengan umur token yang ketat (15 menit) pada sesi aplikasi *mobile*.
- **Auto-Housekeeping:** Cron jobs otomatis untuk membersihkan (*housekeeping*) *file* sampah/foto izin lama pada server.

---

## 🛠️ Tech Stack

Sistem ini terdiri dari tiga bagian utama:

1. **Backend (API & Socket):** Node.js, Express.js, Sequelize ORM, MySQL, Socket.io, JWT.
2. **Frontend Mobile (Mahasiswa):** Flutter, Dart, Geolocator, HTTP, JWT Decoder.
3. **Frontend Web (Admin & Dosen):** Vue.js, Tailwind CSS.

---

## 🚀 Cara Instalasi & Menjalankan Aplikasi

### 1. Persiapan Database & Backend (Node.js)
1. *Clone* repositori ini: `git clone https://github.com/username-anda/nama-repo.git`
2. Masuk ke folder backend: `cd backend`
3. Install semua dependensi: `npm install`
4. Buat file `.env` di *root* folder backend berdasarkan file `.env.example` dan sesuaikan konfigurasi database Anda:
   ```env
   PORT=5000
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=db_absensi_geofencing
   JWT_SECRET=rahasia_jwt_anda
