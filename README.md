# 📱 Sistem Presensi Geofencing (Aplikasi Mahasiswa)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)]()
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)]()
[![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)]()

Repositori ini berisi kode sumber untuk **Aplikasi Mobile (Client-Side)** dari Sistem Presensi Perkuliahan berbasis **Geofencing** dan **Dynamic QR Code**. Aplikasi ini dirancang khusus untuk digunakan oleh mahasiswa dalam melakukan proses pemindaian (*scanning*) absensi di dalam ruang kelas. 

Aplikasi ini akan mengirimkan data sensor GPS (Latitude, Longitude, Altitude, dan Accuracy) ke *backend* server (Node.js) untuk dihitung menggunakan **Algoritma Haversine** dan **Algoritma Vincenty**. Dikembangkan sebagai bagian dari penelitian Tugas Akhir di Program Studi Teknologi Rekayasa Perangkat Lunak, Politeknik Negeri Padang.

---

## ✨ Fitur Utama (Mobile)

- **QR Code Scanner:** Pemindai *Dynamic QR Code* bawaan yang merespons secara cepat dan sangat sensitif terhadap batas waktu (*timeout*).
- **High-Accuracy GPS Extraction:** Mengambil data koordinat spesifik mahasiswa secara *real-time* menggunakan *package* `geolocator`.
- **Local JWT Validation:** Memvalidasi masa aktif token (maksimal 15 menit) langsung di perangkat menggunakan `jwt_decoder` sebelum menyalakan sensor GPS untuk menghemat *resource*.
- **Device Fingerprinting:** Membaca *Device ID* unik mahasiswa untuk mencegah login ganda atau penyalahgunaan perangkat.
- **Smart Error Handling:** Penanganan *error* khusus untuk skenario kehilangan sinyal GPS (*indoor*), koneksi internet lambat (RTO), dan *session expired* (Status 401).

---

## 📂 Struktur Direktori

Aplikasi ini menggunakan arsitektur modular yang memisahkan antara logika *core*, UI, dan konfigurasi API:

```text
📦 lib
 ┣ 📂 core               # Konfigurasi utama aplikasi
 ┃ ┣ 📂 data             # Endpoint API dan global state (GlobalData)
 ┃ ┣ 📂 routes           # Manajemen navigasi (AppRoutes)
 ┃ ┣ 📂 services         # Layanan lokal (StorageService, DeviceHelper)
 ┃ ┗ 📂 ui/widgets       # Komponen UI global (Dialog, Snackbar, dll)
 ┣ 📂 modules            # Fitur spesifik (Halaman Utama)
 ┃ ┣ 📂 auth             # Halaman & Controller Login/Logout
 ┃ ┣ 📂 history          # Halaman Riwayat
 ┃ ┣ 📂 home             # Halaman Utama (Beranda)
 ┃ ┣ 📂 profile          # Halaman & Controller Login/Logout
 ┃ ┗ 📂 scanner          # Halaman Profile
 ┃ ┣ 📂 schedule         # Halaman Jadwal
 ┗ 📜 main.dart          # Entry point aplikasi (Inisialisasi & Cek Sesi)
