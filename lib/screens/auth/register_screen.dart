import 'package:flutter/material.dart';
import '../../db/repository.dart'; // Akses ke Repository untuk fungsi register
import 'login_screen.dart'; // Navigasi kembali ke LoginScreen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers untuk input
  final TextEditingController _fnController = TextEditingController(); // Full Name
  final TextEditingController _uController = TextEditingController();  // Username
  final TextEditingController _eController = TextEditingController();  // Email
  final TextEditingController _pController = TextEditingController();  // Password
  
  // Instance Repository
  final Repo _repo = Repo.instance;

  // Fungsi untuk menangani proses registrasi
  Future<void> _register() async {
    final fullName = _fnController.text;
    final username = _uController.text;
    final email = _eController.text;
    final password = _pController.text;

    // Validasi dasar
    if (username.isEmpty || password.isEmpty || fullName.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, Username, dan Password harus diisi.')),
      );
      return;
    }

    try {
      // Panggil fungsi register dari Repository
      // Repository akan otomatis melakukan hashing password sebelum menyimpan.
      final newId = await _repo.register(fullName, username, email, password);

      if (mounted) {
        if (newId > 0) {
          // Registrasi berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
          );
          // Navigasi kembali ke LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Gagal, tapi tidak ada exception (misalnya, error pada level DB lain)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Gagal. Coba lagi.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Tangani error (misalnya: UNIQUE constraint failed pada username/email)
        String errorMessage = 'Registrasi Gagal.';
        if (e.toString().contains('UNIQUE constraint failed')) {
            errorMessage = 'Username atau Email sudah terdaftar.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: SingleChildScrollView( // Gunakan SingleChildScrollView agar tidak error saat keyboard muncul
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input Nama Lengkap
            TextField(
              controller: _fnController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap', 
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Input Username
            TextField(
              controller: _uController,
              decoration: const InputDecoration(
                labelText: 'Username', 
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),

            // Input Email
            TextField(
              controller: _eController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email', 
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),

            // Input Password
            TextField(
              controller: _pController,
              decoration: const InputDecoration(
                labelText: 'Password', 
                border: OutlineInputBorder()
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            
            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Daftar Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}