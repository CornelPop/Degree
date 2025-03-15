import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {

  Future<void> storeRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember', remember);
  }

  Future<bool?> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember');
  }
}
