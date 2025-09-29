import 'package:sqflite/sqflite.dart';
import 'app.dart';
// import '../models/user.dart'; // Asumsikan model User dan Item ada
// import '../models/item.dart';

// --- Placeholder untuk Hashing (Sesuai Tugas 1) ---
// CATATAN: Ganti placeholder ini dengan implementasi crypto SHA-256 yang sebenarnya.
String hashPassword(String password) {
  // return sha256.convert(utf8.encode(password)).toString(); // Ini adalah kode yang sebenarnya
  return password; // Placeholder untuk saat ini
}
// ----------------------------------------------------

// Model Dummy untuk Kompilasi (Harus diganti dengan Model yang sebenarnya)
class Item {
  final int id;
  final String name;
  final int price;
  final String category;
  Item.fromMap(Map<String, dynamic> map) 
    : id = map['id'], name = map['name'], price = map['price'], category = map['category'];
}
class User {
  final int id;
  final String username;
  User.fromMap(Map<String, dynamic> map) 
    : id = map['id'], username = map['username'];
}


class Repo {
  Repo._();
  static final Repo instance = Repo._();

  Future<Database> get _db async => AppDatabase.instance.database;

  // ====================================================================
  // 1. AUTHENTIKASI (Login & Registrasi)
  // ====================================================================

  // Fungsi Login (Verifikasi Password)
  Future<User?> login(String username, String password) async {
    final hashedPassword = hashPassword(password); 

    final maps = await (await _db).query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first); 
    }
    return null;
  }

  // Fungsi Registrasi (Penyimpanan Pengguna Baru)
  Future<int> register(String fullName, String username, String email, String password) async {
    final hashedPassword = hashPassword(password); 

    return await (await _db).insert(
      'users',
      {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': hashedPassword,
      },
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // ====================================================================
  // 2. ITEM (Menu) - Termasuk Tugas 2: Pencarian
  // ====================================================================

  // Fungsi Ambil Semua Item (dengan opsi pencarian)
  Future<List<Item>> getItems({String? searchTerm}) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    // Logika Pencarian
    if (searchTerm != null && searchTerm.isNotEmpty) {
      whereClause = "name LIKE ?";
      whereArgs = ['%${searchTerm}%'];
    }

    final List<Map<String, dynamic>> maps = await (await _db).query(
      'items',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'category, name',
    );

    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // ====================================================================
  // 3. TRANSAKSI (Fungsi Khusus untuk Tugas 3)
  // ====================================================================

  // Struktur untuk menyimpan hasil laporan
  // Gantikan dengan Model yang sebenarnya
  // class DailyReport { final String date; final int total; } 

  // Fungsi untuk mendapatkan laporan total transaksi per hari
  Future<List<Map<String, dynamic>>> getDailyTransactionSummary() async {
    final db = await _db;

    // Query untuk GROUP BY tanggal (mengambil 10 karakter pertama dari created_at ISO string: YYYY-MM-DD)
    final results = await db.rawQuery('''
      SELECT 
        SUBSTR(created_at, 1, 10) AS transaction_date, 
        SUM(total) AS daily_total
      FROM txns
      GROUP BY transaction_date
      ORDER BY transaction_date DESC;
    ''');

    return results; // Mengembalikan List<Map> yang berisi [transaction_date, daily_total]
  }

  // Fungsi untuk menyimpan transaksi baru (Contoh)
  Future<int> saveTransaction({required int userId, required int total}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    
    // Memasukkan data ke tabel txns
    final txnId = await db.insert(
      'txns',
      {'user_id': userId, 'created_at': now, 'total': total},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Detail transaksi (txn_items) harus dimasukkan di sini, 
    // tetapi kita lewati untuk menjaga fokus pada Tugas 3.

    return txnId;
  }
}
