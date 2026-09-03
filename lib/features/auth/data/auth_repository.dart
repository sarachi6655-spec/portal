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
      String? token;
      response.headers.forEach((name, values) {
        if (name.toLowerCase() == 'token' && values.isNotEmpty) {
          token = values.first;
        }
      });

      final data = response.data;
      if (token == null && data is Map && data.containsKey('token')) {
        token = data['token'];
      }

      if (token == null || token!.isEmpty) {
        throw Exception('Token not received from server');
      }

      final portalUserId = data['portalUserId']?.toString() ?? '1';
      final appUser = data['appUser']?.toString() ?? ApiConstants.defaultAppUser;

      await _storage.saveAuthSession(
        token: token!,
        siteId: siteId,
        portalUserId: portalUserId,
        appUser: appUser,
        userRole: ApiConstants.defaultUserRole,
        userName: userName,
      );

      return {
        'token': token,
        'portalUserId': portalUserId,
        'appUser': appUser,
        'userName': userName,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed. Please check credentials.';
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    await _storage.clearAuthSession();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.isAuthenticated();
  }
}
