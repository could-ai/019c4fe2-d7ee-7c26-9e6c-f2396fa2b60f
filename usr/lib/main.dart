import 'package:flutter/material.dart';
import 'game/block_blast_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Blast Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark background
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const BlockBlastGame(),
      },
    );
  }
}
