import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:installed_apps/installed_apps.dart';

class AppDrawerScreen extends StatefulWidget {
  const AppDrawerScreen({super.key});

  @override
  State<AppDrawerScreen> createState() =>
      _AppDrawerScreenState();
}

class _AppDrawerScreenState
    extends State<AppDrawerScreen> {
  List apps = [];
  List filteredApps = [];
  final StorageService storage =
    StorageService();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    try {
      final result =
          await InstalledApps.getInstalledApps(
        true,
        true,
      );

      result.sort(
        (a, b) => a.name
            .toLowerCase()
            .compareTo(
              b.name.toLowerCase(),
            ),
      );

      setState(() {
        apps = result;
        filteredApps = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Error loading apps: $e",
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void searchApps(String query) {
    setState(() {
      filteredApps = apps.where(
        (app) {
          return app.name
              .toLowerCase()
              .contains(
                query.toLowerCase(),
              );
        },
      ).toList();
    });
  }

Future<void> openApp(
  String packageName,
  String appName,
) async {
  try {
    final counter =
        await storage.loadCounter();

    counter[appName] =
        (counter[appName] ?? 0) + 1;

    await storage.saveCounter(
      counter,
    );

    await InstalledApps.startApp(
      packageName,
    );
  } catch (e) {
    debugPrint(
      "Error opening app: $e",
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_downward,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  const Text(
                    "Apps",
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextField(
                onChanged:
                    searchApps,

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),

                autofocus: true,

                decoration:
                    InputDecoration(
                  hintText:
                      "Cari aplikasi...",
                  hintStyle:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                  filled: true,
                  fillColor:
                      Colors.white10,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount:
                          filteredApps
                              .length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final app =
                            filteredApps[
                                index];

                        return InkWell(
                          onTap: () {
                            openApp(
                              app.packageName,
                                app.name,
                            );
                          },
                          child:
                              Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  24,
                              vertical:
                                  14,
                            ),
                            child:
                                Text(
                              app.name,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}