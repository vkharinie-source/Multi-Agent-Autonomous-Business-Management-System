import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';

  static Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_accessTokenKey, token);
  }

  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_accessTokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> removeToken() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_accessTokenKey);
  }
}
