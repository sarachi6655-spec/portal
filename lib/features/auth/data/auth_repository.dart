import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/company_info_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  Future<CompanyInfoModel> fetchCompanyInfo({String siteId = ApiConstants.defaultSiteId}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.getCompanyInfo,
        options: Options(headers: {
          'siteid': siteId,
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        return CompanyInfoModel.fromJson(response.data);
      }
      throw Exception('Failed to load company info');
    } catch (e) {
      // Fallback default info if network fails
      return CompanyInfoModel(
        website: 'www.revolsolutions.com',
        email: 'sales@revollims.com',
        headerDescription: 'Welcome to Revol LIMS Client Portal. Access live test reports, sample statuses, and submit samples with real-time laboratory tracking.',
        backgroundImage: '',
        logo: '',
        smallLogo: '',
      );
    }
  }

  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
    String siteId = ApiConstants.defaultSiteId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.portalLogin,
        data: {
          'userName': userName,
          'username': userName,
          'password': password,
        },
        options: Options(
          headers: {
            'siteid': siteId,
            'appuser': ApiConstants.defaultAppUser,
            'userrole': ApiConstants.defaultUserRole,
            'Accept': 'application/json',
          },
        ),
      );

      // Extract Token from response headers (Case-insensitive check)
      String? token = response.headers.value('token') ??
          response.headers.value('Token') ??
          response.headers.value('TOKEN') ??
          response.headers.value('authorization') ??
          response.headers.value('Authorization');

      if (token == null || token.isEmpty) {
        response.headers.forEach((name, values) {
          if ((name.toLowerCase() == 'token' || name.toLowerCase() == 'authorization') && values.isNotEmpty) {
            token = values.first;
          }
        });
      }

      final data = response.data;
      if ((token == null || token!.isEmpty) && data is Map) {
        token = data['token']?.toString() ??
            data['Token']?.toString() ??
            data['TOKEN']?.toString() ??
            data['jwt']?.toString() ??
            data['accessToken']?.toString();
      }

      // Strip "Bearer " prefix if included in the header
      if (token != null && token!.toLowerCase().startsWith('bearer ')) {
        token = token!.substring(7).trim();
      }

      if (token == null || token!.isEmpty) {
        throw Exception('Token not received from server');
      }

      final portalUserId = (data is Map && data['portalUserId'] != null)
          ? data['portalUserId'].toString()
          : ApiConstants.defaultPortalUserId;
      final appUser = (data is Map && data['appUser'] != null)
          ? data['appUser'].toString()
          : ApiConstants.defaultAppUser;
      final serverUserName = (data is Map && data['userName'] != null)
          ? data['userName'].toString()
          : userName;

      await _storage.saveAuthSession(
        token: token!,
        siteId: siteId,
        portalUserId: portalUserId,
        appUser: appUser,
        userRole: ApiConstants.defaultUserRole,
        userName: serverUserName,
      );

      return {
        'token': token,
        'portalUserId': portalUserId,
        'appUser': appUser,
        'userName': userName,
      };
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Parses any DioException into a user-friendly message guiding the user to retry
  static String parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Please check your internet connection and try again.';
    }

    if (e.type == DioExceptionType.cancel) {
      return 'Login request was cancelled. Please try again.';
    }

    if (e.type == DioExceptionType.badCertificate) {
      return 'Security certificate verification failed. Please try again.';
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String? serverMsg;

      if (data is Map) {
        serverMsg = data['message']?.toString() ??
            data['error']?.toString() ??
            data['ErrorMessage']?.toString() ??
            data['ResponseMessage']?.toString();
      }

      if (serverMsg != null && serverMsg.trim().isNotEmpty) {
        final cleanMsg = serverMsg.trim();
        final lower = cleanMsg.toLowerCase();
        if (lower.contains('please try again') || lower.contains('try again')) {
          return cleanMsg;
        }
        if (lower.contains('auth') || lower.contains('invalid') || lower.contains('credential') || lower.contains('password')) {
          return '$cleanMsg. Please check your credentials and try again.';
        }
        return '$cleanMsg. Please try again.';
      }

      if (statusCode == 400 || statusCode == 401) {
        return 'Invalid username or password. Please try again.';
      } else if (statusCode == 403) {
        return 'Access denied. Please check your account permissions or try again.';
      } else if (statusCode == 404) {
        return 'Login service not found. Please try again later.';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Server error ($statusCode). Please try again later.';
      }

      return 'Login failed. Please try again.';
    }

    // Handle unknown errors (e.g. XMLHttpRequest or socket errors on Web)
    final rawMsg = e.message ?? '';
    if (rawMsg.contains('XMLHttpRequest') ||
        rawMsg.contains('Failed host lookup') ||
        rawMsg.contains('Connection refused')) {
      return 'Network connection failed. Please check your network and try again.';
    }

    return 'Login failed. Please try again.';
  }

  Future<void> logout() async {
    await _storage.clearAuthSession();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.isAuthenticated();
  }
}
