import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) async =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: _refreshKey, value: token);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }
}
