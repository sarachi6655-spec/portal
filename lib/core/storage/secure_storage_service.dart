import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyToken = 'portaltoken';
  static const String _keySiteId = 'siteid';
  static const String _keyPortalUserId = 'portaluserid';
  static const String _keyAppUser = 'appuser';
  static const String _keyUserRole = 'userrole';
  static const String _keyUserName = 'username';

  Future<void> saveAuthSession({
    required String token,
    required String siteId,
    required String portalUserId,
    required String appUser,
    String userRole = ApiConstants.defaultUserRole,
    String? userName,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keySiteId, value: siteId);
    await _storage.write(key: _keyPortalUserId, value: portalUserId);
    await _storage.write(key: _keyAppUser, value: appUser);
    await _storage.write(key: _keyUserRole, value: userRole);
    if (userName != null) {
      await _storage.write(key: _keyUserName, value: userName);
    }
  }

  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getSiteId() async => (await _storage.read(key: _keySiteId)) ?? ApiConstants.defaultSiteId;
  Future<String?> getPortalUserId() async => await _storage.read(key: _keyPortalUserId);
  Future<String?> getAppUser() async => (await _storage.read(key: _keyAppUser)) ?? ApiConstants.defaultAppUser;
  Future<String?> getUserRole() async => (await _storage.read(key: _keyUserRole)) ?? ApiConstants.defaultUserRole;
  Future<String?> getUserName() async => await _storage.read(key: _keyUserName);

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthSession() async {
    await _storage.deleteAll();
  }
}
