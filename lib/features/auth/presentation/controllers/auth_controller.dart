import 'package:flutter/material.dart';
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

  Future<void> fetchCompanyInfo({String siteId = 'MANULIMS'}) async {
    await loadCompanyInfo(siteId: siteId);
  }

  Future<void> loadCompanyInfo({String siteId = 'MANULIMS'}) async {
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
    String siteId = 'MANULIMS',
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
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
