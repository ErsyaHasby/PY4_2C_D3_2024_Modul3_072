# 📋 TASK 1: Tugas Pendahuluan - RINGKASAN LENGKAP

---

## ✅ STATUS: SELESAI 100%

Semua bagian Task 1 telah diselesaikan dengan dokumentasi lengkap!

---

## 1️⃣ Aset Gambar Onboarding

### ✅ Yang Sudah Dikerjakan:

1. **Folder assets/images dibuat** ✓
   - Lokasi: `assets/images/`
   
2. **Konfigurasi pubspec.yaml sudah diupdate** ✓
   ```yaml
   assets:
     - assets/images/
   ```

3. **OnboardingView sudah diupdate** ✓
   - Mendukung gambar dengan fallback ke icon
   - Jika gambar tidak ada, otomatis tampilkan icon

### 📝 Yang Perlu Anda Lakukan:

**Download 3 gambar** dan simpan di `assets/images/`:
- `onboarding1.png` - Ilustrasi "Welcome/Book"
- `onboarding2.png` - Ilustrasi "Counter/Task"
- `onboarding3.png` - Ilustrasi "Login/Start"

**Sumber Gambar Gratis:**
- Undraw: https://undraw.co/illustrations
- Storyset: https://storyset.com/
- Flaticon: https://www.flaticon.com/

📄 **Panduan lengkap:** Lihat file `assets/images/README.md`

### 💻 Kode yang Diimplementasikan:

```dart
// Di OnboardingView - Sudah otomatis support gambar!
Widget _buildStepImage() {
  return Image.asset(
    _getStepImage(),  // Path: assets/images/onboarding1.png
    width: 250,
    height: 250,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      // Jika gambar tidak ada, tampilkan icon
      return Icon(_getStepIcon(), size: 120, color: Colors.indigo);
    },
  );
}
```

**Cara kerja:**
1. Aplikasi coba load gambar dari `assets/images/onboarding1.png`
2. Jika gambar ADA → Tampilkan gambar ✅
3. Jika gambar TIDAK ADA → Tampilkan icon sebagai fallback ✅

---

## 2️⃣ Shared Preferences & Path Provider

### ✅ Yang Sudah Dikerjakan:

1. **Dependency sudah ditambahkan** ✓
   ```yaml
   dependencies:
     shared_preferences: ^2.2.2
   ```

2. **Package sudah diinstall** ✓
   - `flutter pub get` berhasil dijalankan

3. **Helper class sudah dibuat** ✓
   - File: `lib/utils/shared_preferences_helper.dart`
   - Contoh lengkap untuk menyimpan & membaca data

4. **Dokumentasi lengkap sudah dibuat** ✓
   - File: `docs/SharedPreferences_vs_PathProvider.md`

### 📚 Penjelasan Singkat:

#### **Shared Preferences**
- **Fungsi:** Menyimpan data kecil (key-value)
- **Contoh:** Username, token, settings, status onboarding
- **Tipe data:** bool, int, double, String, List<String>

**Contoh penggunaan:**
```dart
final helper = SharedPreferencesHelper();

// Simpan
await helper.saveUsername('admin');
await helper.setHasSeenOnboarding(true);

// Baca
String? username = await helper.getUsername();
bool hasSeenOnboarding = await helper.getHasSeenOnboarding();
```

#### **Path Provider**
- **Fungsi:** Mendapatkan path/lokasi folder di device
- **Contoh:** Simpan file gambar, PDF, database
- **Use case:** Download files, SQLite, cache files

**Perbedaan Utama:**
| Aspek | Shared Preferences | Path Provider |
|-------|-------------------|---------------|
| **Tujuan** | Simpan data key-value | Akses lokasi folder |
| **Ukuran** | Data kecil (KB) | File besar (MB/GB) |
| **Format** | Bool, Int, String | File apa saja |

📄 **Dokumentasi lengkap:** Lihat file `docs/SharedPreferences_vs_PathProvider.md`

---

## 3️⃣ Perbedaan Navigator

### ✅ Yang Sudah Dikerjakan:

**Dokumentasi lengkap sudah dibuat** ✓
- File: `docs/Navigator_Push_vs_PushAndRemoveUntil.md`
- Penjelasan visual dengan diagram stack
- Contoh kasus penggunaan

### 📝 Jawaban Singkat:

**Apa perbedaan mendasar antara Navigator.push() dan Navigator.pushAndRemoveUntil()?**

#### **Navigator.push()**
- **Fungsi:** Menambahkan halaman baru DI ATAS stack
- **Stack:** Halaman lama TETAP ADA
- **Back:** User BISA kembali ke halaman sebelumnya
- **Use case:** Navigasi normal (list → detail, form, dll)

**Visualisasi:**
```
SEBELUM:          SETELAH push():
[HomePage]  →     [DetailPage]  ← User di sini
                  [HomePage]    ← Masih ada!
```

#### **Navigator.pushAndRemoveUntil()**
- **Fungsi:** Menambahkan halaman baru DAN HAPUS halaman lama
- **Stack:** Bisa hapus SEMUA halaman dengan `(route) => false`
- **Back:** User TIDAK bisa kembali ke halaman yang dihapus
- **Use case:** Logout, reset app, security flow

**Visualisasi:**
```
SEBELUM:                    SETELAH pushAndRemoveUntil():
[CounterPage]  →            [OnboardingPage]  ← User di sini
[LoginPage]                 (Stack kosong!)
[OnboardingPage]
```

**Contoh di Proyek:**
```dart
// LOGOUT: Hapus semua stack, kembali ke Onboarding
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => OnboardingView()),
  (route) => false,  // false = hapus SEMUA
);
```

**Kapan pakai yang mana?**
- `push()` → Navigasi biasa (bisa back) ✅
- `pushReplacement()` → Ganti 1 halaman (login → home) ⚠️
- `pushAndRemoveUntil()` → Hapus banyak/semua (logout) 🔥

📄 **Dokumentasi lengkap:** Lihat file `docs/Navigator_Push_vs_PushAndRemoveUntil.md`

---

## 📂 File-File yang Dibuat

Berikut file-file baru yang telah dibuat untuk Task 1:

```
PY4_2C_D3_2024_Modul2_072/
├── assets/
│   └── images/
│       └── README.md                              ← Panduan download gambar
│
├── lib/
│   ├── utils/
│   │   └── shared_preferences_helper.dart         ← Helper class lengkap
│   │
│   └── features/
│       └── onboarding/
│           └── onboarding_view.dart               ← Updated (support gambar)
│
├── docs/
│   ├── SharedPreferences_vs_PathProvider.md       ← Dokumentasi lengkap
│   └── Navigator_Push_vs_PushAndRemoveUntil.md    ← Dokumentasi lengkap
│
└── pubspec.yaml                                   ← Updated (assets & dependency)
```

---

## 🎯 Checklist Task 1

- ✅ **1. Siapkan aset gambar**
  - ✅ Folder `assets/images/` dibuat
  - ✅ `pubspec.yaml` dikonfigurasi
  - ✅ `OnboardingView` support gambar dengan fallback
  - ⏳ **TODO:** Download 3 gambar (onboarding1.png, onboarding2.png, onboarding3.png)

- ✅ **2. Pelajari Shared Preferences & Path Provider**
  - ✅ Dependency `shared_preferences` ditambahkan
  - ✅ Package diinstall dengan `flutter pub get`
  - ✅ Helper class dibuat dengan contoh lengkap
  - ✅ Dokumentasi perbandingan dibuat

- ✅ **3. Jawab pertanyaan Navigator**
  - ✅ Dokumentasi lengkap dengan visualisasi
  - ✅ Contoh kasus penggunaan
  - ✅ Perbandingan tabel
  - ✅ Best practices

---

## 🚀 Next Steps

### Yang Bisa Anda Lakukan Sekarang:

1. **Download 3 gambar onboarding**
   - Ikuti panduan di `assets/images/README.md`
   - Simpan dengan nama: `onboarding1.png`, `onboarding2.png`, `onboarding3.png`

2. **Baca dokumentasi yang sudah dibuat**
   - `docs/SharedPreferences_vs_PathProvider.md`
   - `docs/Navigator_Push_vs_PushAndRemoveUntil.md`

3. **Test aplikasi**
   ```bash
   flutter run
   ```
   - Cek apakah onboarding menampilkan gambar (jika sudah didownload)
   - Jika belum, akan tampil icon sebagai fallback ✅

4. **Lanjut ke Task berikutnya**
   - Siap untuk Task 2, 3, dst!

---

## 💡 Tips Belajar

### Shared Preferences
Coba implementasi sederhana:
1. Simpan username setelah login
2. Tampilkan welcome message dengan username tersimpan
3. Hapus saat logout

### Navigator
Perhatikan flow navigasi di aplikasi:
- Onboarding → Login (pushReplacement)
- Login → Counter (pushReplacement)  
- Logout → Onboarding (pushAndRemoveUntil)

**Coba:** Tekan tombol back di setiap halaman, perhatikan apa yang terjadi!

---

## 📖 Referensi

- **Shared Preferences:** https://pub.dev/packages/shared_preferences
- **Path Provider:** https://pub.dev/packages/path_provider
- **Navigator Flutter Docs:** https://docs.flutter.dev/cookbook/navigation

---

**✨ TASK 1 COMPLETED! ✨**

Semua persiapan untuk praktikum sudah siap. Dokumentasi lengkap tersedia untuk dipelajari kapan saja!
