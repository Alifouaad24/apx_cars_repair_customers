import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  final SharedPreferences prefs;

  TokenService(this.prefs);

  String? get token => prefs.getString("token");
}