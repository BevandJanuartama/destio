# Destio

Aplikasi mobile dan multi-platform berbasis Flutter untuk menjelajahi informasi destinasi wisata di Indonesia (khususnya wilayah Pulau Jawa), lengkap dengan sistem autentikasi pengguna & admin, bookmark, serta rating dan ulasan berbasis Firebase.

## Fitur Utama

### Pengguna (`user`)
- **Autentikasi & Role Redirect**: Registrasi dan login menggunakan Email & Password (Firebase Auth), fitur *Remember Me* (`shared_preferences`), serta pengalihan otomatis ke tampilan pengguna atau admin berdasarkan `level` di Firestore.
- **Jelajah Destinasi**: Beranda dengan *carousel slider*, pencarian rekomendasi destinasi (kategori *Mountain*, *Beach*, dan *Attraction*), serta daftar destinasi berdasarkan provinsi (Jawa Timur, Daerah Istimewa Yogyakarta, DKI Jakarta, Jawa Tengah, Jawa Barat, dan Banten).
- **Detail Destinasi**: Menampilkan galeri foto, deskripsi, jam operasional, harga tiket, nama jalan/alamat, tautan langsung ke Google Maps (`url_launcher`), serta daftar rekomendasi travel, penginapan, dan kuliner.
- **Bookmark**: Menyimpan dan menghapus destinasi favorit ke daftar bookmark pengguna di Cloud Firestore.
- **Rating & Ulasan**: Melihat daftar ulasan destinasi dan memberikan rating bintang beserta komentar.
- **Profil Pengguna**: Melihat dan memperbarui data profil (`username`, nomor telepon, tanggal lahir, URL foto profil), mengubah kata sandi, serta logout.

### Admin (`admin`)
- **Dashboard Admin**: Memantau daftar rekomendasi destinasi dan daftar destinasi per provinsi.
- **Manajemen Destinasi (CRUD)**: Menambah, mengedit, dan menghapus data destinasi (nama, provinsi, deskripsi, jam operasional, harga tiket, alamat, tautan Google Maps, URL gambar, serta rekomendasi travel, penginapan, dan kuliner) pada koleksi Firestore `destio`.

## Tech Stack

- **Framework**: Flutter (Dart SDK `^3.8.1`)
- **Backend & Database**:
  - `firebase_core`
  - `firebase_auth` & `firebase_auth_web` (Autentikasi Email/Password)
  - `cloud_firestore` (Database koleksi `users`, `destio`, `bookmark`, dan `rating`)
  - `firebase_storage` & `firebase_storage_web`
- **Package Pendukung**:
  - `carousel_slider` (Slider gambar di beranda)
  - `url_launcher` (Membuka tautan Google Maps)
  - `shared_preferences` (Penyimpanan lokal untuk fitur *Remember Me*)
  - `image_picker`, `file_picker`, `http`

## Struktur Proyek

```text
destio/
├── assets/
│   └── image/                  # Aset gambar & logo aplikasi
├── lib/
│   ├── firebase_options.dart   # Konfigurasi platform Firebase (FlutterFire)
│   ├── main.dart               # Entry point & LandingPage (pengecekan auth/level)
│   ├── models/
│   │   ├── destinasi_model.dart
│   │   └── rating_model.dart
│   ├── screens/
│   │   ├── admin/
│   │   │   └── tambah.dart     # Form tambah & edit destinasi (Admin)
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard.dart  # Dashboard utama Admin
│   │   ├── detail/
│   │   │   └── deskripsi.dart  # Detail destinasi & aksi edit/hapus (Admin)
│   │   ├── provinsi/
│   │   │   └── provinsi.dart   # Daftar destinasi berdasarkan provinsi
│   │   └── user/
│   │       ├── bookmark.dart
│   │       ├── deskripsi.dart  # Detail destinasi, bookmark & maps (User)
│   │       ├── edit_profile.dart
│   │       ├── give_rating.dart
│   │       ├── profile.dart
│   │       ├── rating.dart
│   │       ├── user_dashboard.dart
│   │       └── user_main_page.dart
│   ├── services/
│   │   └── destinasi_service.dart
│   ├── utils/
│   │   └── constants.dart
│   └── widgets/
│       ├── custom_textfield.dart
│       └── tempat_card.dart
├── firebase.json               # Konfigurasi proyek FlutterFire
└── pubspec.yaml                # Dependensi dan konfigurasi aset Flutter
```

## Instalasi & Menjalankan Proyek

1. **Prasyarat**
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.8.1`)
   - Android Studio / Xcode / Chrome (sesuai target platform)

2. **Clone repositori & instal dependensi**
   ```bash
   git clone https://github.com/BevandJanuartama/destio.git
   cd destio
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```
   Untuk menjalankan di platform tertentu (misalnya Chrome atau perangkat Android yang terhubung):
   ```bash
   flutter run -d chrome
   # atau
   flutter run -d <device_id>
   ```

## Konfigurasi Environment / Firebase

Proyek ini tidak menggunakan file `.env` maupun `.env.example`, melainkan terhubung langsung ke layanan **Firebase** melalui file konfigurasi FlutterFire:
- `firebase.json`
- `lib/firebase_options.dart`
- `android/app/google-services.json`

Jika Anda ingin menghubungkan proyek ke instance Firebase milik sendiri:
1. Buat proyek baru di [Firebase Console](https://console.firebase.google.com/) dan aktifkan **Authentication (Email/Password)** serta **Cloud Firestore**.
2. Jalankan FlutterFire CLI untuk menimpa konfigurasi:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Pastikan struktur koleksi Firestore sesuai dengan yang digunakan aplikasi (`users`, `destio`, `bookmark`, `rating`), di mana dokumen pada koleksi `users` memiliki field `level` bernilai `'user'` atau `'admin'`.
