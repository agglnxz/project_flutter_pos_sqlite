import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  // Perbaikan 1: Mengganti .*() dengan _ (Constructor private yang benar)
  AppDatabase._(); 
  static final AppDatabase instance = AppDatabase._(); // Perbaikan 2: Mengganti .*()

  Database? _db;

  Future < Database > get database async {
    if (_db != null ) return _db !;
    _db = await _init ();
    return _db !;
  }

  Future < Database > _init () async {
    final dbPath = await getDatabasesPath ();
    final path = join (dbPath , 'pos_app.db'); // Perbaikan 3: Mengganti ’ dengan '
    return await openDatabase (
      path ,
      version : 1,
      onCreate : _onCreate ,
    );
  }

  Future <void > _onCreate ( Database db , int version ) async {
    // Perbaikan 4: Menghapus tanda kutip luar (‘’’) dan menyisakan db.execute
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        full_name TEXT ,
        username TEXT UNIQUE ,
        email TEXT ,
        password TEXT
      )
    '''); // Menghapus tanda kutip penutup yang salah

    // Perbaikan 5: Menghapus blok komentar ‘‘‘ dan ‘‘‘ yang salah dan menyisakan perintah execute
    await db.execute(''' 
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        name TEXT ,
        price INTEGER ,
        category TEXT
      ) 
    ''');

    await db.execute(''' 
      CREATE TABLE txns (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        user_id INTEGER ,
        created_at TEXT ,
        total INTEGER
      ) 
    ''');

    await db.execute(''' 
      CREATE TABLE txn_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        txn_id INTEGER ,
        item_id INTEGER ,
        qty INTEGER ,
        price INTEGER
      ) 
    ''');
    
  }
}
