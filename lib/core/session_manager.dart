import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyToken     = 'token';
  static const _keyAccountId = 'accountId';
  static const _keyName      = 'name';
  static const _keyRole      = 'role';
  static const _keyEmail     = 'email';
  static const _keyPhone     = 'phone';

  static Future<void> save({
    required String token,
    required dynamic accountId,
    required String name,
    required String role,
    String email = '',
    String phone = '',
  }) async {
    final p = await SharedPreferences.getInstance();
    final int id = accountId is int
        ? accountId
        : int.tryParse(accountId?.toString() ?? '0') ?? 0;
    await p.setString(_keyToken,     token);
    await p.setInt   (_keyAccountId, id);
    await p.setString(_keyName,      name);
    await p.setString(_keyRole,      role);
    await p.setString(_keyEmail,     email);
    await p.setString(_keyPhone,     phone);
  }

  static Future<String?> getToken()     async => (await SharedPreferences.getInstance()).getString(_keyToken);
  static Future<int?>    getAccountId() async => (await SharedPreferences.getInstance()).getInt(_keyAccountId);
  static Future<String?> getName()      async => (await SharedPreferences.getInstance()).getString(_keyName);
  static Future<String?> getRole()      async => (await SharedPreferences.getInstance()).getString(_keyRole);
  static Future<String?> getEmail()     async => (await SharedPreferences.getInstance()).getString(_keyEmail);
  static Future<String?> getPhone()     async => (await SharedPreferences.getInstance()).getString(_keyPhone);

  static Future<void> clear() async => (await SharedPreferences.getInstance()).clear();
}
