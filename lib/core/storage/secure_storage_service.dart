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
  static const String _keyLandingSessionToken = 'landing_session_token';

  Future<void> saveLandingSessionToken(String token) async {
    await _storage.write(key: _keyLandingSessionToken, value: token);
  }

  Future<String?> getLandingSessionToken() async {
    return await _storage.read(key: _keyLandingSessionToken);
  }

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

  Future<String?> getToken() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null || token.isEmpty) {
      return null;
    }
    if (token.contains('TUFOVUxJTVM') ||
        token.contains('xJdlG81isWLaYqvXPqA8jRTmTQ_FIhMuPG0eD6hXkAU') ||
        token.contains('NGSQLJ21')) {
      await clearAuthSession();
      return null;
    }
    return token;
  }

  Future<String?> getSiteId() async {
    final site = await _storage.read(key: _keySiteId);
    if (site == null || site.isEmpty || site == 'NGSQLJ21') {
      return ApiConstants.defaultSiteId;
    }
    return site;
  }

  Future<String?> getPortalUserId() async {
    final id = await _storage.read(key: _keyPortalUserId);
    if (id == null || id.isEmpty || id == '3yiFcFKcm4vmJj9xKWrStQ' || id == '1') {
      return ApiConstants.defaultPortalUserId;
    }
    return id;
  }
  Future<String?> getAppUser() async => (await _storage.read(key: _keyAppUser)) ?? ApiConstants.defaultAppUser;
  Future<String?> getUserRole() async => (await _storage.read(key: _keyUserRole)) ?? ApiConstants.defaultUserRole;
  Future<String?> getUserName() async => await _storage.read(key: _keyUserName);

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null || token.isEmpty) {
      return false;
    }
    if (token.contains('TUFOVUxJTVM') ||
        token.contains('xJdlG81isWLaYqvXPqA8jRTmTQ_FIhMuPG0eD6hXkAU') ||
        token.contains('NGSQLJ21')) {
      await clearAuthSession();
      return false;
    }
    return true;
  }

  Future<void> clearAuthSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keySiteId);
    await _storage.delete(key: _keyPortalUserId);
    await _storage.delete(key: _keyAppUser);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserName);
    await _storage.deleteAll();
  }
}
