// lib/screens/menu/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import 'package:flutter_pos_sqlite/db/repository.dart';
import 'package:flutter_pos_sqlite/models/item.dart';
import 'package:flutter_pos_sqlite/models/txn.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isLoading = true;
  List<Item> _items = [];
  
  // Map untuk menyimpan kuantitas pesanan (keranjang)
  // Key: item.id, Value: quantity
  final Map<int, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  // Fungsi untuk mengambil data item dari database
  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });
    final itemsFromDb = await Repo.instance.getAllItems();
    setState(() {
      _items = itemsFromDb;
      _isLoading = false;
    });
  }

  // Fungsi untuk mereset semua jumlah pesanan di keranjang
  void _resetQuantities() {
    setState(() {
      _cart.clear();
    });
  }

  // Fungsi untuk memproses transaksi
  Future<void> _processTransaction() async {
    // 1. Cek apakah keranjang kosong
    if (_cart.isEmpty || _cart.values.every((qty) => qty == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }

    // 2. Kumpulkan item yang akan dibeli dan hitung total
    final List<TxnItem> transactionItems = [];
    int total = 0;
    
    _cart.forEach((itemId, quantity) {
      if (quantity > 0) {
        final item = _items.firstWhere((i) => i.id == itemId);
        total += item.price * quantity;
        transactionItems.add(
          TxnItem(
            txnId: 0, // ID akan di-generate oleh DB
            itemId: item.id,
            qty: quantity,
            price: item.price,
          )
        );
      }
    });

    // 3. Buat objek transaksi utama
    final transaction = Txn(
      // Ganti userId dengan ID user yang sedang login jika ada
      userId: 1, 
      createdAt: DateTime.now().toIso8601String(),
      total: total,
      items: transactionItems,
    );
    
    // 4. Simpan ke database
    await Repo.instance.createTransaction(transaction);

    // 5. Tampilkan dialog sukses dan reset keranjang
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Transaksi Berhasil"),
            content: Text("Total transaksi Anda: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total)}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup pop up
                  _resetQuantities(); // Reset keranjang setelah transaksi sukses
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pisahkan item berdasarkan kategori
    final makanan = _items.where((item) => item.category.toLowerCase() == 'makanan').toList();
    final minuman = _items.where((item) => item.category.toLowerCase() == 'minuman').toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('MENU', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Kategori Makanan
                const Text('Makanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                ...makanan.map((item) => _buildMenuItemCard(item)).toList(),
                const SizedBox(height: 20),

                // Kategori Minuman
                const Text('Minuman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                ...minuman.map((item) => _buildMenuItemCard(item)).toList(),
                const SizedBox(height: 100),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _processTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Transaction'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetQuantities,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Warna berbeda untuk aksi reset
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // Widget untuk membuat satu baris item menu
  Widget _buildMenuItemCard(Item item) {
    // Ambil kuantitas dari map _cart, jika tidak ada maka 0
    final quantity = _cart[item.id] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.price),
                  style: const TextStyle(color: Colors.grey, fontSize: 14)
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    setState(() {
                      if (quantity > 0) {
                        _cart[item.id] = quantity - 1;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      _cart[item.id] = quantity + 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}