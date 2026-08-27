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

## 🚀 Panduan Instalasi (Development)

### Prasyarat Sistem
- **Flutter SDK** (v3.x atau lebih baru)
- **Android Studio** atau **VS Code** dengan ekstensi Flutter
- Perangkat fisik Android/iOS atau Emulator

### Langkah-langkah Menjalankan Proyek

1. *Clone* repositori ini ke komputer Anda:
   ```bash
   git clone [https://github.com/username-anda/repo-mobile-absensi.git](https://github.com/username-anda/repo-mobile-absensi.git)
   cd repo-mobile-absensi
   ```

2. Unduh semua dependensi (*packages*):
   ```bash
   flutter pub get
   ```

3. **Konfigurasi URL Backend (Sangat Penting):**
   Buka file `lib/core/data/endpoint_api.dart`. Ubah *Base URL* agar mengarah ke **IP Address IPv4 lokal** komputer Anda atau URL *server production* Anda. 
   *(Catatan: Jangan gunakan `http://localhost` jika Anda menguji menggunakan smartphone fisik, karena HP tidak mengenali localhost komputer Anda).*
   ```dart
   // Contoh konfigurasi di endpoint_api.dart
   static const String baseUrl = "[http://192.168.1.15:5000/api/mobile](http://192.168.1.15:5000/api/mobile)"; 
   ```

4. Hubungkan perangkat *smartphone* Anda melalui kabel data (pastikan *USB Debugging* aktif), lalu jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 📱 Panduan Build & Instalasi APK (Distribution)

Untuk membagikan aplikasi ini kepada mahasiswa atau dosen penguji untuk keperluan demo/sidang, Anda harus mengompilasi kode menjadi file `.apk`.

1. Pastikan Anda berada di direktori *root* proyek Flutter Anda.
2. Jalankan perintah kompilasi (*Build Release*):
   ```bash
   flutter build apk --release
   ```
3. Setelah proses selesai (biasanya memakan waktu 1-3 menit), temukan file `.apk` di direktori berikut:
   `build/app/outputs/flutter-apk/app-release.apk`
4. Bagikan file `app-release.apk` ini ke *smartphone* Android yang dituju.
5. **Cara Instalasi di Smartphone:**
   - Buka file APK melalui *File Manager*.
   - Jika muncul peringatan keamanan instalasi, pilih **"Settings" / "Pengaturan"**, lalu aktifkan izin **"Allow from this source" / "Instal Aplikasi Tidak Dikenal"**.
   - Buka aplikasi dan **Wajib izinkan akses Lokasi (Precise/Akurat)** serta **Kamera**.


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

---
