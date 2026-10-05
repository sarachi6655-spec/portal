import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/sample_model.dart';
import 'models/sample_detail_model.dart';
import 'models/code_master_model.dart';
import 'models/my_page_data_model.dart';
import 'models/portal_drill_down_model.dart';
import 'models/coa_report_model.dart';

class SampleRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<PortalDrillDownItemModel>> fetchDrillDownData({
    required String label,
    required String xValue,
    String? yValue,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'label': label,
        'xValue': xValue,
      };
      if (yValue != null && yValue.isNotEmpty) {
        queryParams['yValue'] = yValue;
      }
      final response = await _apiClient.dio.get(
        ApiConstants.getPortalDrillDownData,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'];
        if (rawData is List) {
          return rawData.whereType<Map<String, dynamic>>().map((e) => PortalDrillDownItemModel.fromJson(e)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      if (msg != null && msg.toString().toLowerCase().contains('no portal drill-down data found')) {
        return [];
      }
      throw Exception(msg ?? 'Failed to fetch drill-down data');
    }
  }

  Future<MyPageDataModel?> fetchMyPageData() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.getPortalMyPageData);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return MyPageDataModel.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch My Page data');
    }
  }

  Future<List<SampleModel>> fetchSamples() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.getPortalSamples);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> sampleList = response.data['samples'] ?? [];
        return sampleList.map((e) => SampleModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch samples');
    }
  }

  Future<SampleDetailModel?> fetchSampleDetail(int sampleId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.getPortalSampleDetails,
        queryParameters: {'sampleId': sampleId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> details = response.data['sampleDetails'] ?? [];
        if (details.isNotEmpty) {
          return SampleDetailModel.fromJson(details.first);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load sample details');
    }
  }

  Future<List<CodeMasterModel>> fetchCodeMasters(String categoryName) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.getCodeMasters}/$categoryName',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['codeMasters'] ?? [];
        return list.map((e) => CodeMasterModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [
        CodeMasterModel(id: '1', name: 'Sample Point'),
        CodeMasterModel(id: '2', name: 'Item'),
        CodeMasterModel(id: '3', name: 'Equipment'),
      ];
    }
  }

  Future<List<SampleMasterItemModel>> fetchSampleMastersByCategory(String categoryId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.getSampleMastersByCategory}/$categoryId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['sampleMasters'] ?? [];
        return list.map((e) => SampleMasterItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String> addSample(Map<String, dynamic> sampleData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.integratePortalSample,
        data: sampleData,
      );

      if (response.statusCode == 200) {
        return response.data?['ResponseMessage'] ?? response.data?['message'] ?? 'Sample created successfully';
      }
      throw Exception('Failed to add sample');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Error adding sample');
    }
  }

  Future<MyPageDataModel?> fetchSampleWidgetsData() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.getSampleWidgets);

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          final inner = data['data'];
          if (inner is Map<String, dynamic>) {
            return MyPageDataModel.fromJson(inner);
          }
          return MyPageDataModel.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch sample widgets');
    }
  }

  Future<List<MyPageWidgetModel>> fetchSampleWidgets() async {
    final model = await fetchSampleWidgetsData();
    return model?.widgets ?? [];
  }

  /// Hardcoded COA report dataset as requested by user.
  static const bool useHardcodedCoaReports = false;

  static const Map<String, dynamic> hardcodedCoaReportsResponse = {
    "data": [
      {"limsId": "202608060154", "reportNumber": "48", "reportType": "Apollo COA Report", "reportName": "Test Report", "fileName": "Test Report-48.pdf", "filePath": "/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA", "generatedDate": "2026-09-16 05:02:26", "reportStatus": "Generated"},
      {"limsId": "202608060152", "reportNumber": "48", "reportType": "Apollo COA Report", "reportName": "Test Report", "fileName": "Test Report-48.pdf", "filePath": "/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA", "generatedDate": "2026-09-16 05:02:26", "reportStatus": "Generated"},
      {"limsId": "202608060153", "reportNumber": "13", "reportType": "Apollo COA Report", "reportName": "Test Report", "fileName": "Test Report-13.pdf", "filePath": "/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA", "generatedDate": "2026-08-06 12:32:07", "reportStatus": "Generated"},
      {"limsId": "202608080172", "reportNumber": "54", "reportType": "Apollo COA Report", "reportName": "Test Report", "fileName": "Test Report-54.pdf", "filePath": "/home/user/Revol_Application/nextgen/DIAGNOSTIC_LIMS/Temp/Smr_COA", "generatedDate": "2026-10-05 05:44:44", "reportStatus": "Generated"}
    ],
    "status": "success",
    "message": "COA report list fetched successfully."
  };

  Future<List<CoaSampleNodeModel>> fetchCoaReports() async {
    if (useHardcodedCoaReports) {
      return CoaSampleNodeModel.parseList(hardcodedCoaReportsResponse);
    }

    try {
      final response = await _apiClient.dio.get(ApiConstants.getCoaReports);

      if (response.statusCode == 200 && response.data != null) {
        return CoaSampleNodeModel.parseList(response.data);
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (msg != null && msg.toString().toLowerCase().contains('no')) {
        return [];
      }
      throw Exception(msg ?? 'Failed to fetch COA reports from server');
    } catch (e) {
      throw Exception('Failed to load COA reports: $e');
    }
  }
}
