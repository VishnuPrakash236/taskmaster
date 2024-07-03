import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          elevation: 50,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 10,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          splashColor: Colors.green,
        ),
        cardTheme: CardTheme(
          elevation: 15,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        primaryColor: Colors.green,
        fontFamily: 'Georgia',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // Set LoginPage as the initial screen
    );
  }
}
