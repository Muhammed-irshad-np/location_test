import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final SharedPreferences prefs;

  AuthController(this.prefs);

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = prefs.getBool(Constants.isLoggedInKey) ?? false;
  }

  Future<bool> login(String username, String password) async {
    final storedPassword = prefs.getString('password_$username');
    if (storedPassword != null && storedPassword == password) {
      await prefs.setBool(Constants.isLoggedInKey, true);
      await prefs.setString(Constants.usernameKey, username);
      isLoggedIn.value = true;
      return true;
    }

    if (username == Constants.validUsername &&
        password == Constants.validPassword) {
      await prefs.setBool(Constants.isLoggedInKey, true);
      await prefs.setString(Constants.usernameKey, username);
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final existingPassword = prefs.getString('password_$username');
    if (existingPassword != null) {
      return false;
    }

    await prefs.setString('password_$username', password);
    await prefs.setBool(Constants.isLoggedInKey, true);
    await prefs.setString(Constants.usernameKey, username);
    isLoggedIn.value = true;
    return true;
  }

  Future<void> logout() async {
    await prefs.setBool(Constants.isLoggedInKey, false);
    isLoggedIn.value = false;
  }
}
