# 📋 TASK 2: The Login Portal - DOKUMENTASI LENGKAP

---

## ✅ STATUS: SELESAI 100%

Semua fitur security dan validasi telah diimplementasikan dengan sempurna!

---

## 🎯 **Spesifikasi Tugas**

### 1️⃣ **Controller: Multiple Users dengan Map**
✅ **SELESAI** - LoginController mendukung 4 akun berbeda

### 2️⃣ **Security Logic**
✅ **SELESAI** - Validasi input kosong dengan pesan error
✅ **SELESAI** - Batas 3x percobaan login + disable 10 detik

### 3️⃣ **View: Show/Hide Password**
✅ **SELESAI** - Fitur toggle password dengan icon mata

---

## 💻 **Implementasi Detail**

### **1. LoginController - Multiple Users (Map)**

**File:** `lib/features/auth/login_controller.dart`

```dart
class LoginController {
  // Database Multiple Users menggunakan Map<String, String>
  final Map<String, String> _users = {
    'admin': '123',
    'user': 'user123',
    'guest': 'guest',
    'dosen': 'polban2024',
  };

  // Validasi login dengan Map
  bool login(String username, String password) {
    if (_users.containsKey(username) && _users[username] == password) {
      return true; // Login berhasil
    }
    return false; // Login gagal
  }

  // Bonus: Cek apakah username exist
  bool isUsernameExist(String username) {
    return _users.containsKey(username);
  }

  // Bonus: Get available users
  List<String> getAvailableUsers() {
    return _users.keys.toList();
  }
}
```

**📚 Penjelasan:**
- **Map<String, String>** = Key-Value pairs (username → password)
- **containsKey()** = Cek apakah username ada di Map
- **_users[username]** = Ambil password dari username
- **Scalable** = Mudah tambah/hapus user tanpa ubah logic

**Keuntungan Map vs Hardcode:**
```dart
// ❌ CARA LAMA (Hardcode):
if (username == "admin" && password == "123") return true;
if (username == "user" && password == "user123") return true;
// Harus tambah if terus... tidak scalable!

// ✅ CARA BARU (Map):
return _users.containsKey(username) && _users[username] == password;
// Satu baris, support banyak user!
```

---

### **2. Security Logic - Validasi Input Kosong**

**File:** `lib/features/auth/login_view.dart`

```dart
void _handleLogin() {
  String user = _userController.text;
  String pass = _passController.text;

  // Validasi input kosong
  if (user.isEmpty || pass.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Username dan Password tidak boleh kosong!"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
    return; // Stop execution
  }
  
  // Lanjut ke validasi login...
}
```

**📚 Penjelasan:**
- **isEmpty** = Cek apakah String kosong ("")
- **return** = Stop fungsi jika validasi gagal
- **SnackBar** = Notifikasi pop-up di bawah layar
- **backgroundColor: Colors.orange** = Warning color (bukan error)

---

### **3. Security Logic - Batas Percobaan Login (3x)**

**State Variables:**
```dart
int _loginAttempts = 0;        // Counter percobaan
bool _isButtonDisabled = false; // Status tombol
int _remainingSeconds = 10;    // Countdown timer
```

**Logic Flow:**
```dart
void _handleLogin() {
  // ... validasi kosong ...
  
  bool isSuccess = _controller.login(user, pass);

  if (isSuccess) {
    // Reset attempts saat berhasil
    setState(() {
      _loginAttempts = 0;
    });
    // Navigasi ke Counter...
  } else {
    // Increment attempts
    setState(() {
      _loginAttempts++;
    });

    // Cek apakah sudah 3x
    if (_loginAttempts >= 3) {
      _disableButtonTemporarily(); // Disable 10 detik
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 Terlalu banyak percobaan gagal!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Tampilkan sisa percobaan
      int remaining = 3 - _loginAttempts;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Login Gagal! Sisa percobaan: $remaining"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Disable Button Temporarily:**
```dart
void _disableButtonTemporarily() {
  setState(() {
    _isButtonDisabled = true;
    _remainingSeconds = 10;
  });

  // Timer countdown setiap 1 detik
  Future.delayed(const Duration(seconds: 1), _countdown);
}

void _countdown() {
  if (_remainingSeconds > 0) {
    setState(() {
      _remainingSeconds--;
    });
    Future.delayed(const Duration(seconds: 1), _countdown);
  } else {
    // Setelah 10 detik, enable button dan reset attempts
    setState(() {
      _isButtonDisabled = false;
      _loginAttempts = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Tombol login sudah aktif kembali!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

**📚 Penjelasan:**
- **Future.delayed()** = Timer async (tunggu x detik)
- **Rekursif countdown** = Fungsi _countdown() panggil dirinya sendiri
- **setState()** = Update UI setiap detik
- **_isButtonDisabled** = Flag untuk disable/enable button

**Tombol dengan Status Disabled:**
```dart
ElevatedButton(
  onPressed: _isButtonDisabled ? null : _handleLogin,
  style: ElevatedButton.styleFrom(
    backgroundColor: _isButtonDisabled ? Colors.grey : Colors.indigo,
    disabledBackgroundColor: Colors.grey,
  ),
  child: Text(
    _isButtonDisabled 
        ? "Tunggu $_remainingSeconds detik..." 
        : "Masuk",
  ),
)
```

**📚 Penjelasan:**
- **null** = onPressed null → button disabled
- **Conditional color** = Grey saat disabled, Indigo saat aktif
- **Dynamic text** = Tampilkan countdown saat disabled

---

### **4. Show/Hide Password Feature**

**State Variable:**
```dart
bool _obscurePassword = true; // true = tersembunyi, false = terlihat
```

**TextField Password:**
```dart
TextField(
  controller: _passController,
  obscureText: _obscurePassword, // Control visibility
  decoration: InputDecoration(
    labelText: "Password",
    prefixIcon: const Icon(Icons.lock),
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword 
            ? Icons.visibility      // Mata tertutup
            : Icons.visibility_off, // Mata terbuka
      ),
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword; // Toggle
        });
      },
    ),
  ),
)
```

**📚 Penjelasan:**
- **obscureText** = true → ••••, false → text
- **Toggle dengan !** = NOT operator (true jadi false, vice versa)
- **Icons.visibility** = Icon mata
- **suffixIcon** = Icon di kanan TextField

---

## 📊 **Flow Diagram Security Logic**

```
User tekan "Masuk"
    ↓
Cek: Input kosong?
    ├─ Ya → SnackBar warning (orange) → STOP
    └─ Tidak → Lanjut
        ↓
    Validasi login (Controller)
        ├─ Berhasil → Reset attempts → Navigasi ke Counter ✅
        └─ Gagal → attempts++
            ↓
        Cek: attempts >= 3?
            ├─ Ya → Disable button 10 detik
            │       └─ Countdown setiap detik
            │           └─ Setelah 10 detik → Enable + Reset
            └─ Tidak → SnackBar "Sisa percobaan: X"
```

---

## 🧪 **Testing Scenarios**

### **Test 1: Login Berhasil**
```
Input: admin / 123
Expected: ✅ Navigasi ke Counter, username = "admin"
```

### **Test 2: Login dengan User Lain**
```
Input: user / user123
Expected: ✅ Navigasi ke Counter, username = "user"

Input: guest / guest
Expected: ✅ Navigasi ke Counter, username = "guest"

Input: dosen / polban2024
Expected: ✅ Navigasi ke Counter, username = "dosen"
```

### **Test 3: Input Kosong**
```
Input: "" / ""
Expected: ⚠️ SnackBar orange "Username dan Password tidak boleh kosong!"

Input: admin / ""
Expected: ⚠️ SnackBar orange (sama)

Input: "" / 123
Expected: ⚠️ SnackBar orange (sama)
```

### **Test 4: Login Salah 1-2x**
```
Attempt 1: admin / wrong
Expected: ❌ SnackBar "Login Gagal! Sisa percobaan: 2"

Attempt 2: admin / wrong2
Expected: ❌ SnackBar "Login Gagal! Sisa percobaan: 1"
```

### **Test 5: Login Salah 3x (Disable Button)**
```
Attempt 1: admin / wrong
Attempt 2: admin / wrong
Attempt 3: admin / wrong
Expected: 
  - 🔒 SnackBar "Terlalu banyak percobaan gagal!"
  - Tombol berubah grey
  - Text tombol: "Tunggu 10 detik..."
  - Countdown 10 → 9 → 8 → ... → 0
  - Setelah 0 detik: Tombol aktif, SnackBar hijau
```

### **Test 6: Show/Hide Password**
```
1. Default: Password tersembunyi (••••)
2. Klik icon mata: Password terlihat (plain text)
3. Klik lagi: Password tersembunyi lagi
Expected: ✅ Toggle berfungsi smooth
```

---

## 📂 **File yang Dimodifikasi**

```
✅ lib/features/auth/login_controller.dart  (Multiple Users Map)
✅ lib/features/auth/login_view.dart        (Security Logic + UI)
```

---

## 🎓 **Konsep yang Dipelajari**

### **1. Data Structures**
- ✅ **Map<K, V>** = Key-Value pairs untuk data terstruktur
- ✅ **containsKey()** = Cek keberadaan key
- ✅ **map[key]** = Akses value berdasarkan key

### **2. State Management**
- ✅ **setState()** = Update UI saat state berubah
- ✅ **Boolean flags** = Kontrol state (enabled/disabled)
- ✅ **Counter pattern** = Track jumlah percobaan

### **3. Async Programming**
- ✅ **Future.delayed()** = Timer asynchronous
- ✅ **Recursive function** = Countdown pattern
- ✅ **Callback** = Eksekusi fungsi setelah delay

### **4. Security Patterns**
- ✅ **Input validation** = Cegah empty input
- ✅ **Rate limiting** = Batasi percobaan login
- ✅ **Temporary disable** = Anti brute force attack
- ✅ **User feedback** = Informasi sisa percobaan

### **5. UI/UX Best Practices**
- ✅ **SnackBar** = Non-intrusive notification
- ✅ **Color coding** = Orange (warning), Red (error), Green (success)
- ✅ **Dynamic button text** = Countdown feedback
- ✅ **Disabled state** = Visual feedback (grey color)
- ✅ **Show/Hide password** = User control

---

## ✅ **Kriteria Lab (70%) - Status**

- [x] **Berhasil login dengan minimal 2 akun berbeda dari Map**
  - ✅ admin/123
  - ✅ user/user123
  - ✅ guest/guest
  - ✅ dosen/polban2024

- [x] **Pesan SnackBar muncul jika login gagal**
  - ✅ Input kosong → Orange SnackBar
  - ✅ Login gagal 1-2x → Red SnackBar dengan sisa percobaan
  - ✅ Login gagal 3x → Red SnackBar disable warning
  - ✅ Button aktif kembali → Green SnackBar

- [x] **Fitur Show/Hide Password berfungsi dengan lancar**
  - ✅ Icon mata (visibility/visibility_off)
  - ✅ Toggle dengan setState()
  - ✅ Smooth transition

---

## 🚀 **Cara Testing**

1. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

2. **Test Multiple Users:**
   - Coba login dengan: admin/123 ✅
   - Logout, coba login dengan: user/user123 ✅
   - Logout, coba login dengan: guest/guest ✅

3. **Test Security:**
   - Masukkan password salah 3x
   - Perhatikan tombol disable + countdown
   - Tunggu 10 detik
   - Tombol aktif kembali

4. **Test Show/Hide Password:**
   - Klik icon mata di password field
   - Password jadi visible
   - Klik lagi, password jadi hidden

---

## 💡 **Tips Pengembangan Lanjut**

### **1. Persist Login Attempts (Homework 30%)**
Gunakan Shared Preferences untuk simpan attempts:
```dart
// Simpan attempts
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setInt('login_attempts', _loginAttempts);

// Baca saat init
int savedAttempts = prefs.getInt('login_attempts') ?? 0;
```

### **2. Enhanced Security**
```dart
// Hash password (jangan simpan plain text!)
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}
```

### **3. Better UX**
```dart
// Progress indicator saat countdown
LinearProgressIndicator(
  value: _remainingSeconds / 10,
  backgroundColor: Colors.grey,
  color: Colors.red,
)

// Hapus TextField saat countdown
Opacity(
  opacity: _isButtonDisabled ? 0.5 : 1.0,
  child: TextField(...),
)
```

---

## 🎯 **Key Takeaways**

1. **Map** lebih scalable daripada hardcode untuk multiple users
2. **setState()** adalah kunci untuk update UI secara reactive
3. **Future.delayed()** untuk timer/countdown
4. **Security layering** = Validasi input + rate limiting
5. **User feedback** sangat penting (SnackBar, countdown, etc)

---

**✨ TASK 2 COMPLETED! ✨**

Aplikasi sekarang memiliki sistem login yang aman dengan:
- ✅ Multiple users support
- ✅ Input validation
- ✅ Anti brute-force (3x limit)
- ✅ Show/Hide password
- ✅ Excellent UX with feedback

**Siap lanjut ke Task berikutnya?** 🚀
