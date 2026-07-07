import 'package:flutter/material.dart';

class Text1 extends StatelessWidget {
  final String text;
  const Text1(this.text, {super.key});

  
  @override
  Widget build(context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28.5,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
