import 'package:flutter/material.dart';
import '../../db/repository.dart';
import '../menu/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen ({ super.key });

  @override
  State <LoginScreen> createState() => _LoginScreenState(); // Perbaikan: Gunakan _LoginScreenState
}

class _LoginScreenState extends State <LoginScreen> {
  // Perbaikan 1: Deklarasi controller yang benar
  final _u = TextEditingController(); 
  final _p = TextEditingController();

  Future <void> _login() async {
    // Perbaikan 2: Menghapus '*' dan menggunakan variabel _p
    final user = await Repo.instance.login(_u.text, _p.text);
    
    if ( user != null && mounted ) {
      // Feedback sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil!')),
      );
      
      Navigator.pushReplacement(
        context,
        // Perbaikan 3: Sintaks builder yang benar
        MaterialPageRoute (builder: (context) => const MenuScreen()), 
      );
    } else if (mounted) {
      // Feedback gagal (penting agar pengguna tahu jika login gagal)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah.')),
      );
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Padding (
        padding : const EdgeInsets.all (24.0) ,
        child : Column (
          mainAxisAlignment : MainAxisAlignment.center ,
          children : [
            // Perbaikan 4: Menggunakan controller: _u
            TextField(controller: _u, decoration: const InputDecoration (
              labelText: 'Username'
            )),
            
            TextField(controller: _p, decoration: const InputDecoration (
              labelText: 'Password'), 
              obscureText : true 
            ),
            
            const SizedBox ( height : 20) ,
            
            ElevatedButton (onPressed : _login, child : const Text('Login')),
          ],
        ),
      ),
    );
  }
} // Tanda kurung kurawal penutup akhir
