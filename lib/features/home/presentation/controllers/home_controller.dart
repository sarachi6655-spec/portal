import 'package:flutter/material.dart';
import '../../data/home_repository.dart';
import '../../data/models/client_portal_details_model.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  ClientPortalDetailsModel? _portalDetails;
  ClientPortalDetailsModel? get portalDetails => _portalDetails;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

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
}
