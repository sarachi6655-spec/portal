import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if custom headers were already provided explicitly
          final hasAuth = options.headers.containsKey('Authorization') ||
              options.headers.containsKey('authorization');
          final hasSiteId = options.headers.containsKey('siteid') ||
              options.headers.containsKey('SITE_ID');
          final hasAppUser = options.headers.containsKey('appuser') ||
              options.headers.containsKey('APP_USER');

          final token = await _storage.getToken();
          final siteId = await _storage.getSiteId();
          final appUser = await _storage.getAppUser();
          final userRole = await _storage.getUserRole();
          final portalUserId = await _storage.getPortalUserId();

          if (!hasAuth && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (!hasSiteId && siteId != null) {
            options.headers['siteid'] = siteId;
            options.headers['SITE_ID'] = siteId;
          }
          if (!hasAppUser && appUser != null) {
            options.headers['appuser'] = appUser;
            options.headers['APP_USER'] = appUser;
          }
          if (!options.headers.containsKey('userrole') && userRole != null) {
            options.headers['userrole'] = userRole;
          }
          if (!options.headers.containsKey('portaluserid') && portalUserId != null) {
            options.headers['portaluserid'] = portalUserId;
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}
