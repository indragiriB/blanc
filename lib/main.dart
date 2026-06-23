import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Text Launcher',
      debugShowCheckedModeBanner: false,
      // Mengatur tema dasar menjadi hitam murni (OLED friendly)
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Application> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  // Fungsi untuk mengambil aplikasi yang terinstal di HP
  Future<void> _loadInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true, // Hanya aplikasi yang bisa dibuka
    );

    // Mengurutkan nama aplikasi dari A sampai Z
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    setState(() {
      _apps = apps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Text(
                'loading...',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            )
          : SafeArea(
              child: ListView.builder(
                itemCount: _apps.length,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                itemBuilder: (context, index) {
                  Application app = _apps[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: GestureDetector(
                      onTap: () => DeviceApps.openApp(app.packageName),
                      child: Text(
                        app.appName.toLowerCase(), // Mengubah teks jadi lowercase demi estetika minimalis
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}