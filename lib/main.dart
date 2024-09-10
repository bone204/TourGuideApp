// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart'; // Import đường dẫn đến file mới

void main() {
  runApp(MaterialApp(
    home: SafeArea(
      child: Scaffold(
        body: HomePage(),
      )
    ),
    debugShowCheckedModeBanner: false,
  ));
}
