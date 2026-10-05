import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/auth_repository.dart';
import '../../data/models/company_info_model.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  CompanyInfoModel? _companyInfo;
  CompanyInfoModel? get companyInfo => _companyInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCompanyInfoLoading = true;
  bool get isCompanyInfoLoading => _isCompanyInfoLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    _isAuthenticated = await _repository.isLoggedIn();
    await loadCompanyInfo();
    notifyListeners();
  }

  Future<void> fetchCompanyInfo({String siteId = ApiConstants.defaultSiteId}) async {
    await loadCompanyInfo(siteId: siteId);
  }

  Future<void> loadCompanyInfo({String siteId = ApiConstants.defaultSiteId}) async {
    _isCompanyInfoLoading = true;
    notifyListeners();

    try {
      _companyInfo = await _repository.fetchCompanyInfo(siteId: siteId);
    } catch (_) {
      // Handled in repo with defaults
    } finally {
      _isCompanyInfoLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String userName,
    required String password,
    String siteId = ApiConstants.defaultSiteId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(
        userName: userName,
        password: password,
        siteId: siteId,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = AuthRepository.parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '').trim();
      _errorMessage = msg.isNotEmpty ? msg : 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
