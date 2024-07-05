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
      debugShowCheckedModeBanner: false,
      title: 'Task Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          elevation: 50,
        ),
        // floatingActionButtonTheme: FloatingActionButtonThemeData(
        //   elevation: 10,
        //   backgroundColor: Colors.deepPurple,
        //   foregroundColor: Colors.white,
        //   splashColor: Colors.green,
        // ),
        cardTheme: CardTheme(
          elevation: 15,
        ),

        // colorScheme: ColorScheme.dark(),
        // colorSchemeSeed: const Color.fromRGBO(86, 80, 14, 171),
        primaryColor: Colors.green,
        fontFamily: 'Georgia',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      // theme: ThemeData(
      //   colorSchemeSeed: const Color.fromRGBO(86, 80, 14, 171),
      //   useMaterial3: true,
      // ),


      home: LoginPage(), // Set LoginPage as the initial screen
    );
  }
}
