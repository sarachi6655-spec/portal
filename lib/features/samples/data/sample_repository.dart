import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/sample_model.dart';
import 'models/sample_detail_model.dart';
import 'models/code_master_model.dart';

class SampleRepository {
  final ApiClient _apiClient = ApiClient();

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
}
