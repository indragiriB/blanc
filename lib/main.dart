import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const MainApp());
}
const List<String> stoicQuotes = [
  "attention is your most valuable asset",
  "what you do every day shapes who you become",
  "focus is a decision",
  "the obstacle becomes the way",
  "time is life itself",
  "simplicity reveals what matters",
  "discipline creates freedom",
  "your mind becomes what it consumes",
  "be present with what is important",
  "less noise, more purpose",
];

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
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
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
    // Pada versi 1.2.0, argumen dibaca secara urut (posisional):
    // Arg 1: excludeSystemApps -> false (agar aplikasi bawaan HP tetap muncul)
    // Arg 2: withIcon -> false (karena kita murni teks hitam-putih)
    List<AppInfo> apps = await InstalledApps.getInstalledApps(false, false);
    
    // Urutkan aplikasi A-Z
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _allApps = apps;
      _filteredApps = apps;
      _isLoading = false;
      
      // Memberikan 3 aplikasi pertama sebagai default jika favorit kosong
      if (_favoritePackages.isEmpty && apps.isNotEmpty) {
        for (var i = 0; i < (apps.length > 3 ? 3 : apps.length); i++) {
          _favoritePackages.add(apps[i].packageName);
        }
      }
    });
  }

  void _filterApps(String query) {
    setState(() {
      _filteredApps = _allApps
          .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String _formatTime() {
    String hour = _now.hour.toString().padLeft(2, '0');
    String minute = _now.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDate() {
    List<String> days = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
    List<String> months = ['jan', 'feb', 'mar', 'apr', 'mei', 'jun', 'jul', 'agu', 'sep', 'okt', 'nov', 'des'];
    
    String dayName = days[_now.weekday % 7];
    String monthName = months[_now.month - 1];
    return "$dayName, ${_now.day} $monthName";
  }

  // Fungsi utilitas kecil agar aman saat aplikasi gagal dibuka
  void _openApp(AppInfo app) {
    try {
      InstalledApps.startApp(app.packageName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka ${app.name.toLowerCase()}'), 
          duration: const Duration(seconds: 1)
        ),
      );
    }
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

    List<AppInfo> favoriteApps = _allApps.where((app) => _favoritePackages.contains(app.packageName)).toList();

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

  Widget _buildHomeScreen(List<AppInfo> favoriteApps) {
    return Column(
      key: const ValueKey('HomeScreen'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          _formatTime(),
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w100, letterSpacing: -2),
        ),
        Text(
          _formatDate(),
          style: const TextStyle(fontSize: 16, color: Colors.white38, fontWeight: FontWeight.w300),
        ),
        const Spacer(),
        const Text('fokus utama:', style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...favoriteApps.map((app) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: () => _openApp(app),
                onLongPress: () {
                  setState(() {
                    _favoritePackages.remove(app.packageName);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${app.name.toLowerCase()} dihapus dari utama'), duration: const Duration(seconds: 1)),
                  );
                },
                child: Text(
                  app.name.toLowerCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: 1),
                ),
              ),
            )),
        const Spacer(),
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

  Widget _buildAppDrawer() {
    return Column(
      key: const ValueKey('AppDrawer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const Text(
          '*tekan lama untuk menambah/menghapus dari halaman utama',
          style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredApps.length,
            itemBuilder: (context, index) {
              AppInfo app = _filteredApps[index];
              bool isFav = _favoritePackages.contains(app.packageName);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: GestureDetector(
                  onTap: () => _openApp(app),
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
                        content: Text(isFav ? '${app.name.toLowerCase()} dihapus' : '${app.name.toLowerCase()} jadi favorit'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Membungkus nama aplikasi dengan Flexible agar tidak error jika namanya terlalu panjang
                      Flexible(
                        child: Text(
                          app.name.toLowerCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isFav ? FontWeight.w500 : FontWeight.w300,
                            color: isFav ? Colors.white : Colors.white60,
                          ),
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