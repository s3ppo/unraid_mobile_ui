import 'package:flutter/material.dart';
import 'package:unraid_ui/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unraid UI',
      theme: ThemeData(
        appBarTheme:
            const AppBarTheme(backgroundColor: Colors.orange, foregroundColor: Colors.black),
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.grey, foregroundColor: Colors.white),
      ),
      home: const LoginPage(),
    );
  }
}
