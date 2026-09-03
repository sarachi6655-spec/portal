import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/client_portal_details_model.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  // Public Token for public landing details
  static const String publicPortalToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJSVkwiLCJpYXQiOjE3ODc3MzczNTEsImF1ZCI6ImFwcF91c2VycyIsImp0aSI6IkRJQUdURVNUIiwic3ViIjoiUE9SVEFMIiwicm9sZXMiOlsiVklFV0VSIl0sInNpdGVJZCI6IkRJQUdURVNUIiwiYmFzZVVybCI6IiJ9.chiKe8KyvBDRieSS-7an__E2vvvNzzWJDNAUOHH7-Mg';

  Future<ClientPortalDetailsModel> fetchClientPortalDetails({
    String siteId = 'DIAGTEST',
    String appUser = 'PORTAL',
  }) async {
    try {
      // Live API Call to https://erplx.revollims.com/erp/client-portal-details
      final response = await _apiClient.dio.get(
        ApiConstants.clientPortalDetails,
        options: Options(
          headers: {
            'Authorization': 'Bearer $publicPortalToken',
            'SITE_ID': siteId,
            'APP_USER': appUser,
            'siteid': siteId,
            'appuser': appUser,
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
}
