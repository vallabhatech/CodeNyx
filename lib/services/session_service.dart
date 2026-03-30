import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static bool _loggedIn = false;
  static String? _email;
  static String? _teamId;
  static String? _userName;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool("loggedIn") ?? false;
    _email = prefs.getString("email") ?? prefs.getString("user_email");
    _teamId = prefs.getString("teamId") ?? prefs.getString("team_id");
    _userName = prefs.getString("user_name");
  }

  static bool get hasActiveSession =>
      _loggedIn && _email != null && _teamId != null;

  static String? get currentEmail => _email;
  static String? get currentTeamId => _teamId;
  static String? get currentUserName => _userName;

  static Future<void> saveSession(
    String email,
    String teamId, {
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();

    await prefs.setBool("loggedIn", true);
    await prefs.setString("email", normalizedEmail);
    await prefs.setString("teamId", teamId);
    await prefs.setString("user_email", normalizedEmail);
    await prefs.setString("team_id", teamId);
    if (userName != null) {
      await prefs.setString("user_name", userName);
    } else {
      await prefs.remove("user_name");
    }

    _loggedIn = true;
    _email = normalizedEmail;
    _teamId = teamId;
    _userName = userName;
  }

  static Future<bool> isLoggedIn() async {
    return hasActiveSession;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loggedIn = false;
    _email = null;
    _teamId = null;
    _userName = null;
  }

  static Future<Map<String, dynamic>> getSession() async {
    return {
      "email": _email,
      "teamId": _teamId,
      "userName": _userName,
    };
  }
}
