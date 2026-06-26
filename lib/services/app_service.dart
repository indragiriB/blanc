import 'package:installed_apps/installed_apps.dart';

class AppService {
  Future<List<dynamic>> getApps() async {
    return await InstalledApps.getInstalledApps(
      true,
      true,
    );
  }
}