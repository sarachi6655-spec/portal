import 'package:flutter/material.dart';
import '../../data/home_repository.dart';
import '../../data/models/client_portal_details_model.dart';
import '../../data/models/service_detail_model.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  ClientPortalDetailsModel? _portalDetails;
  ClientPortalDetailsModel? get portalDetails => _portalDetails;

  List<ServiceItemDetail> _clientServices = [];
  List<ServiceItemDetail> get clientServices => _clientServices;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isClientServicesLoading = true;
  bool get isClientServicesLoading => _isClientServicesLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadPortalDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _portalDetails = await _repository.fetchClientPortalDetails();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClientServices() async {
    _isClientServicesLoading = true;
    notifyListeners();

    try {
      final services = await _repository.fetchClientServices();
      _clientServices = services;
    } catch (e) {
      debugPrint('Error loading client services: $e');
    } finally {
      _isClientServicesLoading = false;
      notifyListeners();
    }
  }
}
