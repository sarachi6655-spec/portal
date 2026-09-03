import 'package:flutter/material.dart';
import '../../data/models/sample_model.dart';
import '../../data/models/sample_detail_model.dart';
import '../../data/sample_repository.dart';

class SampleController extends ChangeNotifier {
  final SampleRepository _repository = SampleRepository();

  List<SampleModel> _allSamples = [];
  List<SampleModel> _filteredSamples = [];
  List<SampleModel> get samples => _paginatedSamples;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedStatusFilter = 'All';
  String get selectedStatusFilter => _selectedStatusFilter;

  // Pagination
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;
  int get totalRecords => _filteredSamples.length;
  int get totalPages => (_filteredSamples.isEmpty) ? 1 : (_filteredSamples.length / _rowsPerPage).ceil();

  // Active Inspection Sample
  SampleDetailModel? _selectedSampleDetail;
  SampleDetailModel? get selectedSampleDetail => _selectedSampleDetail;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  List<SampleModel> get _paginatedSamples {
    final start = (_currentPage - 1) * _rowsPerPage;
    if (start >= _filteredSamples.length) return [];
    final end = (start + _rowsPerPage > _filteredSamples.length) ? _filteredSamples.length : start + _rowsPerPage;
    return _filteredSamples.sublist(start, end);
  }

  Future<void> loadSamples() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSamples = await _repository.fetchSamples();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
  }

  void setRowsPerPage(int rows) {
    _rowsPerPage = rows;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void _applyFilter() {
    _filteredSamples = _allSamples.where((s) {
      final matchesQuery = _searchQuery.isEmpty ||
          s.limsId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleCategory.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.requestId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All' ||
          s.sampleStatus.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> loadSampleDetail(int sampleId) async {
    _isDetailLoading = true;
    _selectedSampleDetail = null;
    notifyListeners();

    try {
      _selectedSampleDetail = await _repository.fetchSampleDetail(sampleId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedDetail() {
    _selectedSampleDetail = null;
    notifyListeners();
  }

  Future<bool> createSample(Map<String, dynamic> sampleData) async {
    try {
      await _repository.addSample(sampleData);
      await loadSamples();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
