import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/client_portal_details_model.dart';
import 'models/service_detail_model.dart';

class HomeRepository {
  final SecureStorageService _storage = SecureStorageService();

  // Public Fallback Token for landing details (DIAGTEST)
  static const String publicPortalToken = ApiConstants.clientPortalDetailsToken;

  /// Calls CreateSession to generate a session token for the landing page
  Future<String?> createSession({
    String siteId = ApiConstants.defaultSiteId,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        ApiConstants.createSessionUrl,
        data: {
          'SITE_ID': siteId,
          'SiteID': siteId,
        },
        options: Options(
          headers: {
            'Origin': ApiConstants.sessionOrigin,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      String? token = response.headers.value('token') ??
          response.headers.value('Token') ??
          response.headers.value('TOKEN') ??
          response.headers.value('authorization') ??
          response.headers.value('Authorization');

      if (token == null || token.isEmpty) {
        response.headers.forEach((name, values) {
          if ((name.toLowerCase() == 'token' || name.toLowerCase() == 'authorization') &&
              values.isNotEmpty) {
            token = values.first;
          }
        });
      }

      if (token != null && token!.toLowerCase().startsWith('bearer ')) {
        token = token!.substring(7).trim();
      }

      if (token != null && token!.isNotEmpty) {
        debugPrint('Successfully obtained landing session token from CreateSession API');
        await _storage.saveLandingSessionToken(token!);
        return token;
      }
    } catch (e) {
      debugPrint('CreateSession error: $e');
    }
    return null;
  }

  Future<ClientPortalDetailsModel> fetchClientPortalDetails({
    String siteId = ApiConstants.clientPortalSiteId,
    String appUser = ApiConstants.clientPortalAppUser,
    String token = ApiConstants.clientPortalDetailsToken,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // Call https://erplx.revollims.com/erp/client-portal-details exactly as defined in Postman collection
      final response = await dio.get(
        ApiConstants.clientPortalDetailsUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'SITE_ID': siteId,
            'APP_USER': appUser,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        debugPrint('Successfully fetched client portal details from API');
        return ClientPortalDetailsModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching client portal details from live API: $e');
    }

    // Return default model structure if offline or server timeout occurs
    return ClientPortalDetailsModel.fromJson({});
  }

  /// Fetches Client Services from https://erplx.revollims.com/erp/client-services
  Future<List<ServiceItemDetail>> fetchClientServices({
    String siteId = ApiConstants.clientPortalSiteId,
    String appUser = ApiConstants.clientPortalAppUser,
    String token = ApiConstants.clientPortalDetailsToken,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.get(
        ApiConstants.clientServicesUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'SITE_ID': siteId,
            'APP_USER': appUser,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final rawList = data['data'] as List<dynamic>? ?? [];
        debugPrint('Successfully fetched ${rawList.length} client services from live API');
        return rawList
            .map((item) => ServiceItemDetail.fromClientServiceJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching client services from live API: $e');
    }

    return [];
  }
}
