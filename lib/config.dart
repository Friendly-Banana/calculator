import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static late final PackageInfo packageInfo;
  static late final String appVersion;
  static late final String appDirPath;

  static late final SharedPreferences _prefs;
  static const String _modeKey = "dark";

  static bool darkMode = true;

  static Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    darkMode = _prefs.getBool(_modeKey) ?? true;

    appDirPath = (await getApplicationDocumentsDirectory()).path;

    packageInfo = await PackageInfo.fromPlatform();
    appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
  }

  static void save() {
    _prefs.setBool(_modeKey, darkMode);
  }
}
