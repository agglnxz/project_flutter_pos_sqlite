import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';  

class RedTextWidget extends StatelessWidget {
  final String text;
  const RedTextWidget({super.key, required this.text});

  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: const TextStyle(color: Colors.red, fontSize: 20),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}