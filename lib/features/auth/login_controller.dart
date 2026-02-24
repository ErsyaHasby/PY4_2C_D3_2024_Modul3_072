// LoginController - Bertanggung jawab HANYA untuk logic validasi
// Prinsip Single Responsibility: Tidak ada UI code di sini!

class LoginController {
  // TASK 2: Database Multiple Users menggunakan Map
  // Key: username, Value: password
  // Map lebih scalable daripada hardcode multiple if-else
  final Map<String, String> _users = {
    'admin': '123',
    'user': 'user123',
    'guest': 'guest',
    'dosen': 'polban2024',
  };

  // Fungsi untuk mendapatkan list username yang tersedia
  // Berguna untuk debugging atau menampilkan hint
  List<String> getAvailableUsers() {
    return _users.keys.toList();
  }

  // Fungsi pengecekan (Logic-Only) - UPDATED untuk Multiple Users
  // Input: username dan password dari user
  // Output: true jika cocok, false jika salah
  bool login(String username, String password) {
    // Validasi menggunakan Map
    // Cek apakah username ada di Map DAN passwordnya cocok
    if (_users.containsKey(username) && _users[username] == password) {
      return true; // Login berhasil
    }
    return false; // Login gagal (username tidak ada atau password salah)
  }

  // BONUS: Fungsi untuk cek apakah username exist
  // Berguna untuk memberikan pesan error yang lebih spesifik
  bool isUsernameExist(String username) {
    return _users.containsKey(username);
  }

  // ✅ Open-Closed Principle (OCP):
  // Struktur Map ini mudah dikembangkan:

  // void addUser(String username, String password) {
  //   _users[username] = password;
  // }

  // void removeUser(String username) {
  //   _users.remove(username);
  // }

  // Future<bool> loginFromAPI(String username, String password) async {
  //   // Bisa tambah fungsi baru untuk validasi dari server/API
  //   // tanpa mengubah fungsi login() yang sudah ada
  // }
}
