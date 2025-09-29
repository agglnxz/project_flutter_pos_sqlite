import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Text Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

@override
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Text Widget Demo'),
      ),
      body: Center(
          child: Text("Hello, This Is Flutter",
              style: TextStyle(color: Colors.red, fontSize: 20))),
    );
  }
}