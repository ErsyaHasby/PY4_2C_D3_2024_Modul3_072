# 📋 TASK 3: Persistent History Logger - DOKUMENTASI LENGKAP

---

## ✅ STATUS: SELESAI 100%

Aplikasi sekarang dapat "mengingat" data counter dan history meskipun aplikasi ditutup atau di-restart!

---

## 🎯 **Spesifikasi Tugas**

### 1️⃣ **Logic: Save & Load Counter Value**
✅ **SELESAI** - Auto-save setiap kali counter berubah

### 2️⃣ **History Log: Simpan Riwayat Aktivitas**
✅ **SELESAI** - History tersimpan dalam format JSON

### 3️⃣ **Data Persistence: Load saat Login**
✅ **SELESAI** - Data di-load otomatis di initState

---

## 💻 **Implementasi Detail**

### **1. Model HistoryItem dengan JSON Serialization**

**File:** `lib/features/logbook/counter_controller.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk JSON encode/decode

class HistoryItem {
  final String text;
  final String type;

  HistoryItem({required this.text, required this.type});

  // Convert ke JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
    };
  }

  // Create dari JSON (Map)
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      text: json['text'] as String,
      type: json['type'] as String,
    );
  }
}
```

**📚 Penjelasan:**
- **toJson()** = Convert object ke Map (untuk disimpan)
- **fromJson()** = Create object dari Map (saat load)
- **factory constructor** = Pattern untuk create object
- **dart:convert** = Library untuk JSON encode/decode

**Mengapa perlu JSON?**
```
SharedPreferences HANYA support tipe data primitif:
✅ int, double, bool, String, List<String>
❌ TIDAK support object custom (HistoryItem)

Solusi: Convert HistoryItem → JSON String → Simpan
        Load JSON String → Convert → HistoryItem
```

---

### **2. CounterController - Save & Load Functions**

**Keys untuk SharedPreferences:**
```dart
static const String _keyCounter = 'last_counter';
static const String _keyHistory = 'history_list';
```

**Save Counter Value:**
```dart
Future<void> saveLastValue() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyCounter, _counter);
  print('💾 Counter saved: $_counter');
}
```

**Load Counter Value:**
```dart
Future<void> loadLastValue() async {
  final prefs = await SharedPreferences.getInstance();
  _counter = prefs.getInt(_keyCounter) ?? 0; // Default: 0
  print('📂 Counter loaded: $_counter');
}
```

**📚 Penjelasan:**
- **SharedPreferences.getInstance()** = Akses ke storage (async)
- **prefs.setInt(key, value)** = Simpan int
- **prefs.getInt(key)** = Load int (bisa null)
- **?? 0** = Null-aware operator (default value jika null)
- **await** = Tunggu hasil async operation

---

**Save History:**
```dart
Future<void> saveHistory() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Convert List<HistoryItem> → List<String> (JSON)
  List<String> historyJson = _history.map((item) {
    return jsonEncode(item.toJson());
  }).toList();
  
  await prefs.setStringList(_keyHistory, historyJson);
  print('💾 History saved: ${_history.length} items');
}
```

**Load History:**
```dart
Future<void> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? historyJson = prefs.getStringList(_keyHistory);
  
  if (historyJson != null) {
    // Convert List<String> → List<HistoryItem>
    _history = historyJson.map((jsonString) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return HistoryItem.fromJson(json);
    }).toList();
    
    print('📂 History loaded: ${_history.length} items');
  } else {
    _history = [];
  }
}
```

**📚 Penjelasan:**
- **map()** = Transform setiap item dalam list
- **jsonEncode()** = Map → JSON String
- **jsonDecode()** = JSON String → Map
- **List<String>?** = Nullable (bisa null jika belum ada data)

**Flow Conversion:**
```
SAVE:
HistoryItem → toJson() → Map → jsonEncode() → String → saveStringList()

LOAD:
getStringList() → String → jsonDecode() → Map → fromJson() → HistoryItem
```

---

**Load All Data (Helper):**
```dart
Future<void> loadAllData() async {
  await loadLastValue();
  await loadHistory();
}
```

**Clear All Data (Testing):**
```dart
Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyCounter);
  await prefs.remove(_keyHistory);
  _counter = 0;
  _history = [];
  print('🗑️ All data cleared');
}
```

---

### **3. Auto-Save pada Setiap Perubahan**

**Modifikasi increment(), decrement(), reset():**

```dart
void increment() {
  _counter += _step;
  _addHistory('Menambah nilai sebesar $_step', 'add');
  saveLastValue(); // ✅ Auto-save!
}

void decrement() {
  _counter -= _step;
  _addHistory('Mengurangi nilai sebesar $_step', 'subtract');
  saveLastValue(); // ✅ Auto-save!
}

void reset() {
  _counter = 0;
  _addHistory('Reset counter ke 0', 'reset');
  saveLastValue(); // ✅ Auto-save!
}
```

**Modifikasi _addHistory():**
```dart
void _addHistory(String activity, String type) {
  // ... (existing code) ...
  
  saveHistory(); // ✅ Auto-save history!
}
```

**📚 Penjelasan:**
- Setiap kali counter berubah → langsung save
- Setiap kali history bertambah → langsung save
- User tidak perlu manually save
- Data selalu up-to-date!

---

### **4. CounterView - Load Data saat Init**

**Loading State:**
```dart
bool _isLoading = true;
```

**initState():**
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  await _controller.loadAllData();
  setState(() {
    _isLoading = false; // Selesai loading
  });
}
```

**📚 Penjelasan:**
- **initState()** = Dipanggil sekali saat widget dibuat
- **_isLoading** = Flag untuk tampilkan loading indicator
- **setState()** = Update UI setelah data di-load

---

**Loading Indicator UI:**
```dart
body: _isLoading
    ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat data...'),
          ],
        ),
      )
    : Padding(...) // Main content
```

**📚 Penjelasan:**
- Conditional rendering dengan ternary operator
- Saat `_isLoading == true` → Tampilkan loading
- Saat `_isLoading == false` → Tampilkan content
- **CircularProgressIndicator** = Loading spinner

---

**Visual Feedback (Auto-Save Badge):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.green.shade50,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.green.shade200),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.cloud_done, size: 16, color: Colors.green),
      SizedBox(width: 6),
      Text('Data tersimpan otomatis', style: TextStyle(...)),
    ],
  ),
)
```

**📚 Penjelasan:**
- Badge hijau untuk inform user bahwa data auto-saved
- **Icons.cloud_done** = Cloud icon (representasi saved to storage)
- Visual feedback meningkatkan UX

---

### **5. Clear Data Feature (Testing)**

**PopupMenu di AppBar:**
```dart
actions: [
  PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'clear') {
        _showClearDataConfirmation();
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'clear',
        child: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 10),
            Text('Hapus Data Tersimpan'),
          ],
        ),
      ),
    ],
  ),
  IconButton(...), // Logout button
],
```

**Confirmation Dialog:**
```dart
void _showClearDataConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Data Tersimpan?'),
      content: const Text('Ini akan menghapus semua data...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _controller.clearAllData();
            setState(() {}); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Data dihapus!')),
            );
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

**📚 Penjelasan:**
- **PopupMenuButton** = Menu dropdown di AppBar
- Berguna untuk testing persistence
- User bisa reset data ke kondisi awal
- Confirmation dialog untuk prevent accidental deletion

---

## 📊 **Flow Diagram Persistence**

### **SAVE Flow:**
```
User Action (increment/decrement/reset)
    ↓
Controller update _counter
    ↓
_addHistory() dipanggil
    ↓
saveLastValue() + saveHistory() otomatis dipanggil
    ↓
SharedPreferences.getInstance()
    ↓
prefs.setInt() / prefs.setStringList()
    ↓
Data tersimpan di storage device 💾
```

### **LOAD Flow:**
```
App Dibuka → LoginView → CounterView created
    ↓
initState() dipanggil
    ↓
_loadData() dipanggil
    ↓
_controller.loadAllData()
    ↓
loadLastValue() + loadHistory()
    ↓
SharedPreferences.getInstance()
    ↓
prefs.getInt() / prefs.getStringList()
    ↓
Data di-load ke _counter dan _history
    ↓
setState() → UI update dengan data tersimpan 📂
```

---

## 🧪 **Testing Scenarios**

### **Test 1: Basic Persistence**
```
1. Login ke aplikasi
2. Counter = 0 (default)
3. Klik "Tambah" 5x → Counter = 5
4. Tutup aplikasi (kill app)
5. Buka aplikasi lagi
6. Login dengan user yang sama
Expected: Counter = 5 (TIDAK kembali ke 0) ✅
```

### **Test 2: History Persistence**
```
1. Login
2. Lakukan beberapa aksi:
   - Tambah +1
   - Kurang -1
   - Reset
3. Lihat history (3 items)
4. Tutup aplikasi
5. Buka lagi & login
Expected: History tetap ada (3 items) ✅
```

### **Test 3: Hot Restart**
```
1. Counter = 10, History = 5 items
2. Run Hot Restart (Ctrl+Shift+F5)
3. Login lagi
Expected: Counter = 10, History = 5 items ✅
```

### **Test 4: Different Users**
```
1. Login sebagai "admin"
2. Counter = 10
3. Logout
4. Login sebagai "user"
Expected: Counter juga 10 (shared data antar user)

Note: Jika ingin per-user data, perlu tambah logic:
- Key: 'last_counter_admin', 'last_counter_user'
```

### **Test 5: Clear Data**
```
1. Counter = 20, History = 5 items
2. Klik menu (3 dots) → "Hapus Data Tersimpan"
3. Confirm
Expected: Counter = 0, History = kosong ✅
4. Restart app
Expected: Tetap 0 (data memang dihapus) ✅
```

---

## 📂 **File yang Dimodifikasi**

```
✅ lib/features/logbook/counter_controller.dart
   - Import shared_preferences & dart:convert
   - HistoryItem toJson() & fromJson()
   - saveLastValue() & loadLastValue()
   - saveHistory() & loadHistory()
   - loadAllData() & clearAllData()
   - Auto-save di increment/decrement/reset

✅ lib/features/logbook/counter_view.dart
   - _isLoading state
   - initState() + _loadData()
   - Loading indicator UI
   - Auto-save badge (visual feedback)
   - Clear data menu + confirmation
```

---

## 🎓 **Konsep yang Dipelajari**

### **1. SharedPreferences**
- ✅ Key-Value storage
- ✅ getInstance() pattern
- ✅ setInt(), getInt(), setStringList(), getStringList()
- ✅ Async operations dengan Future & await

### **2. JSON Serialization**
- ✅ toJson() untuk convert object → Map
- ✅ fromJson() untuk convert Map → object
- ✅ jsonEncode() untuk Map → String
- ✅ jsonDecode() untuk String → Map
- ✅ Factory constructor pattern

### **3. Lifecycle Methods**
- ✅ initState() untuk initialization
- ✅ dispose() untuk cleanup
- ✅ setState() untuk update UI

### **4. Async Programming**
- ✅ Future<T> return type
- ✅ async keyword
- ✅ await keyword
- ✅ Sequential async calls

### **5. State Management**
- ✅ Loading state pattern
- ✅ Conditional rendering
- ✅ UI update after async operation

### **6. Data Persistence Patterns**
- ✅ Auto-save (save on every change)
- ✅ Load on init
- ✅ Default values (null-aware operators)
- ✅ Clear/Reset functionality

---

## ✅ **Kriteria Lab (70%) - Status**

- [x] **Data angka terakhir tidak hilang saat aplikasi di-restart**
  - ✅ saveLastValue() dipanggil di increment/decrement/reset
  - ✅ loadLastValue() dipanggil di initState
  - ✅ Data persisten di SharedPreferences

- [x] **Riwayat aktivitas tersimpan rapi dan dapat ditampilkan kembali**
  - ✅ saveHistory() otomatis dipanggil
  - ✅ loadHistory() di initState
  - ✅ JSON serialization untuk List<HistoryItem>
  - ✅ UI menampilkan history yang di-load

- [x] **Logika penyimpanan tetap terisolasi di dalam CounterController (SRP)**
  - ✅ Semua fungsi save/load di CounterController
  - ✅ CounterView hanya panggil loadAllData()
  - ✅ Tidak ada logic persistence di View
  - ✅ Separation of Concerns terjaga

---

## 💡 **Tips Debugging**

### **1. Lihat Console Debug Logs**
```
💾 Counter saved: 10
💾 History saved: 3 items
📂 Counter loaded: 10
📂 History loaded: 3 items
```
Ini membantu tracking kapan save/load dipanggil.

### **2. Hot Reload vs Hot Restart**
```
Hot Reload (Ctrl+S / r):
- TIDAK jalankan ulang initState
- Gunakan untuk UI changes

Hot Restart (Ctrl+Shift+F5 / R):
- Jalankan ulang initState
- Gunakan untuk test persistence
```

### **3. Clear App Data (Total Reset)**
```
Jika data corrupt atau perlu total reset:
- Android: Settings → Apps → LogBook App → Clear Data
- iOS: Uninstall & reinstall app
- Atau gunakan fitur "Hapus Data Tersimpan" di app
```

### **4. Check SharedPreferences Keys**
```dart
// Add this untuk debugging
Future<void> debugPrintAllKeys() async {
  final prefs = await SharedPreferences.getInstance();
  print('All keys: ${prefs.getKeys()}');
  print('Counter: ${prefs.getInt(_keyCounter)}');
  print('History: ${prefs.getStringList(_keyHistory)}');
}
```

---

## 🚀 **Pengembangan Lanjut (Homework 30%)**

### **1. Per-User Data Storage**
```dart
// Save counter per user
Future<void> saveLastValue(String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter_$username', _counter);
}

// Load counter per user
Future<void> loadLastValue(String username) async {
  final prefs = await SharedPreferences.getInstance();
  _counter = prefs.getInt('counter_$username') ?? 0;
}
```

### **2. Timestamp untuk History**
```dart
class HistoryItem {
  final String text;
  final String type;
  final DateTime timestamp; // NEW!

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      text: json['text'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

### **3. Export/Import Data**
```dart
// Export to JSON file
Future<void> exportData() async {
  Map<String, dynamic> data = {
    'counter': _counter,
    'history': _history.map((e) => e.toJson()).toList(),
  };
  String jsonString = jsonEncode(data);
  // Save to file using path_provider
}

// Import from JSON file
Future<void> importData(String jsonString) async {
  Map<String, dynamic> data = jsonDecode(jsonString);
  _counter = data['counter'];
  _history = (data['history'] as List)
      .map((e) => HistoryItem.fromJson(e))
      .toList();
}
```

### **4. Auto-Backup ke Cloud**
```dart
// Menggunakan Firebase atau API backend
Future<void> syncToCloud() async {
  // Upload data ke cloud storage
  // Untuk disaster recovery
}
```

---

## 🎯 **Key Takeaways**

1. **SharedPreferences** = Simple key-value storage untuk data kecil
2. **JSON Serialization** = Convert custom objects ke format yang bisa disimpan
3. **Auto-save** = Save on every change untuk prevent data loss
4. **Load on Init** = initState() adalah tempat tepat untuk load data
5. **SRP** = Logic persistence di Controller, bukan di View
6. **Null Safety** = Selalu handle null dengan default values (`?? 0`)
7. **Async/Await** = Penting untuk operations yang butuh waktu

---

## 📖 **Referensi**

- **Shared Preferences Package:** https://pub.dev/packages/shared_preferences
- **JSON Serialization:** https://docs.flutter.dev/data-and-backend/serialization/json
- **Async Programming:** https://dart.dev/codelabs/async-await

---

**✨ TASK 3 COMPLETED! ✨**

Aplikasi sekarang memiliki:
- ✅ Persistent storage (data tidak hilang)
- ✅ Auto-save setiap perubahan
- ✅ Loading state yang smooth
- ✅ Visual feedback (auto-save badge)
- ✅ Clear data untuk testing
- ✅ SRP terjaga (logic di Controller)

**Data counter dan history sekarang tersimpan permanen!** 💾

**Siap lanjut ke Task berikutnya atau ada pertanyaan tentang persistence?** 🚀
