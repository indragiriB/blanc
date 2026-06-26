import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const BlancLauncher());
}

class BlancLauncher extends StatelessWidget {
  const BlancLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}