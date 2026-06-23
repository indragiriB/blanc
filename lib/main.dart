import 'dart:async';
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
      title: 'Minimal Digital Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionHandleColor: Colors.white,
        ),
      ),
      home: const MainLauncherScreen(),
    );
  }
}

class MainLauncherScreen extends StatefulWidget {
  const MainLauncherScreen({super.key});

  @override
  State<MainLauncherScreen> createState() => _MainLauncherScreenState();
}

class _MainLauncherScreenState extends State<MainLauncherScreen> {
  List<Application> _allApps = [];
  List<Application> _filteredApps = [];
  // Menyimpan package name aplikasi favorit (secara default kosong)
  final List<String> _favoritePackages = []; 
  
  bool _isDrawerOpen = false;
  bool _isLoading = true;
  
  late DateTime _now;
  late Timer _timeTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Update jam setiap 1 detik
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
    _loadApps();
  }

  @override
  void dispose() {
    _timeTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    setState(() {
      _allApps = apps;
      _filteredApps = apps;
      _isLoading = false;
      
      // Memberi rekomendasi default jika favorit masih kosong
      if (_favoritePackages.isEmpty && apps.isNotEmpty) {
        // Mengambil 3 aplikasi pertama sebagai contoh awal
        for (var i = 0; i < (apps.length > 3 ? 3 : apps.length); i++) {
          _favoritePackages.add(apps[i].packageName);
        }
      }
    });
  }

  void _filterApps(String query) {
    setState(() {
      _filteredApps = _allApps
          .where((app) => app.appName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Format Jam manual (HH:mm)
  String _formatTime() {
    String hour = _now.hour.toString().padLeft(2, '0');
    String minute = _now.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // Format Tanggal manual (hari, tanggal bulan)
  String _formatDate() {
    List<String> days = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
    List<String> months = ['jan', 'feb', 'mar', 'apr', 'mei', 'jun', 'jul', 'agu', 'sep', 'okt', 'nov', 'des'];
    
    String dayName = days[_now.weekday % 7];
    String monthName = months[_now.month - 1];
    return "$dayName, ${_now.day} $monthName";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Text('memuat esensi...', style: TextStyle(fontFamily: 'monospace', color: Colors.white54)),
        ),
      );
    }

    // Mendapatkan list object aplikasi yang difavoritkan
    List<Application> favoriteApps = _allApps.where((app) => _favoritePackages.contains(app.packageName)).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isDrawerOpen ? _buildAppDrawer() : _buildHomeScreen(favoriteApps),
          ),
        ),
      ),
    );
  }

  // 1. HALAMAN UTAMA (HOME)
  Widget _buildHomeScreen(List<Application> favoriteApps) {
    return Column(
      key: const ValueKey('HomeScreen'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        // Widget Jam Minimalis
        Text(
          _formatTime(),
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w100, letterSpacing: -2),
        ),
        // Widget Tanggal Minimalis
        Text(
          _formatDate(),
          style: const TextStyle(fontSize: 16, color: Colors.white38, fontWeight: FontWeight.w300),
        ),
        const Spacer(),
        // Menu Aplikasi Favorit
        const Text('fokus utama:', style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...favoriteApps.map((app) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: () => DeviceApps.openApp(app.packageName),
                onLongPress: () {
                  setState(() {
                    _favoritePackages.remove(app.packageName);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${app.appName.toLowerCase()} dihapus dari utama'), duration: const Duration(seconds: 1)),
                  );
                },
                child: Text(
                  app.appName.toLowerCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: 1),
                ),
              ),
            )),
        const Spacer(),
        // Tombol untuk membuka seluruh aplikasi
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isDrawerOpen = true;
              });
            },
            child: const Text(
              'semua aplikasi →',
              style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  // 2. HALAMAN DAFTAR APLIKASI (APP DRAWER)
  Widget _buildAppDrawer() {
    return Column(
      key: const ValueKey('AppDrawer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tombol Kembali
        GestureDetector(
          onTap: () {
            setState(() {
              _isDrawerOpen = false;
              _searchController.clear();
              _filterApps('');
            });
          },
          child: const Text('← kembali', style: TextStyle(color: Colors.white38, fontSize: 16)),
        ),
        const SizedBox(height: 24),
        // Search Bar Text-Only
        TextField(
          controller: _searchController,
          onChanged: _filterApps,
          autofocus: true,
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300),
          decoration: const InputDecoration(
            hintText: 'cari aplikasi...',
            hintStyle: TextStyle(color: Colors.white24),
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          ),
        ),
        const SizedBox(height: 20),
        // Hint Informasi
        const Text(
          '*tekan lama untuk menambah/menghapus dari halaman utama',
          style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        // Daftar Aplikasi Terfilter
        Expanded(
          child: ListView.builder(
            itemCount: _filteredApps.length,
            itemBuilder: (context, index) {
              Application app = _filteredApps[index];
              bool isFav = _favoritePackages.contains(app.packageName);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: GestureDetector(
                  onTap: () {
                    DeviceApps.openApp(app.packageName);
                  },
                  onLongPress: () {
                    setState(() {
                      if (isFav) {
                        _favoritePackages.remove(app.packageName);
                      } else {
                        _favoritePackages.add(app.packageName);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFav ? '${app.appName.toLowerCase()} dihapus' : '${app.appName.toLowerCase()} jadi favorit'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app.appName.toLowerCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isFav ? FontWeight.w500 : FontWeight.w300,
                          color: isFav ? Colors.white : Colors.white60,
                        ),
                      ),
                      if (isFav)
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}