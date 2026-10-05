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
          final isLogin = options.path.contains(ApiConstants.portalLogin);
          final isCompanyInfo = options.path.contains(ApiConstants.getCompanyInfo);
          final isClientPortalDetails = options.path.contains(ApiConstants.clientPortalDetails) ||
              options.path.contains('client-portal-detail');

          final savedSiteId = await _storage.getSiteId();
          final effectiveSiteId = (savedSiteId == null || savedSiteId.isEmpty || savedSiteId == 'NGSQLJ21')
              ? ApiConstants.defaultSiteId
              : savedSiteId;

          if (isLogin) {
            // Unauthenticated Login endpoint: must NOT send Authorization, token, or portaluserid
            options.headers.remove('Authorization');
            options.headers.remove('authorization');
            options.headers.remove('token');
            options.headers.remove('Token');
            options.headers.remove('TOKEN');
            options.headers.remove('portaluserid');
            options.headers.remove('portal_user_id');
            options.headers.remove('portaluser');
            options.headers.remove('portal_user');
            options.headers.remove('PORTAL_USER_ID');
            options.headers.remove('PORTAL_USER');
            options.headers['siteid'] = effectiveSiteId;
            options.headers['site_id'] = effectiveSiteId;
            options.headers['appuser'] = 'CLIENT';
            options.headers['app_user'] = 'CLIENT';
            options.headers['userrole'] = 'ADMIN';
            return handler.next(options);
          }

          if (isCompanyInfo) {
            options.headers.remove('Authorization');
            options.headers.remove('authorization');
            options.headers.remove('token');
            options.headers.remove('Token');
            options.headers.remove('TOKEN');
            options.headers['siteid'] = effectiveSiteId;
            return handler.next(options);
          }

          if (isClientPortalDetails) {
            // For landing page (client-portal-details)
            options.headers.remove('token');
            options.headers.remove('Token');
            options.headers.remove('TOKEN');

            final landingToken = (await _storage.getLandingSessionToken()) ??
                (await _storage.getToken()) ??
                ApiConstants.clientPortalDetailsToken;

            options.headers['Authorization'] = 'Bearer $landingToken';
            options.headers['SITE_ID'] = effectiveSiteId;
            options.headers['APP_USER'] = 'PORTAL';
            return handler.next(options);
          }

          // Authenticated requests (e.g. /get-portal-my-page-data, /get-portal-samples)
          final token = (await _storage.getToken()) ?? ApiConstants.defaultPortalToken;
          final appUser = (await _storage.getAppUser()) ?? ApiConstants.defaultAppUser;
          final userRole = (await _storage.getUserRole()) ?? ApiConstants.defaultUserRole;
          final portalUserId = (await _storage.getPortalUserId()) ?? ApiConstants.defaultPortalUserId;

          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Token'] = token;
          options.headers['token'] = token;
          options.headers['siteid'] = effectiveSiteId;
          options.headers['site_id'] = effectiveSiteId;
          options.headers['SITE_ID'] = effectiveSiteId;
          options.headers['appuser'] = appUser;
          options.headers['app_user'] = appUser;
          options.headers['APP_USER'] = appUser;
          options.headers['portaluserid'] = portalUserId;
          options.headers['portal_user_id'] = portalUserId;
          options.headers['PORTAL_USER_ID'] = portalUserId;
          options.headers['userrole'] = userRole;
          options.headers['USER_ROLE'] = userRole;

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}
