import 'package:flutter/material.dart';
import '../../data/models/sample_model.dart';
import '../../data/models/sample_detail_model.dart';
import '../../data/models/my_page_data_model.dart';
import '../../data/models/portal_drill_down_model.dart';
import '../../data/models/sample_analytics_model.dart';
import '../../data/models/coa_report_model.dart';
import '../../data/sample_repository.dart';
import '../widgets/three_d_bar_chart_card.dart';

class SampleController extends ChangeNotifier {
  final SampleRepository _repository = SampleRepository();

  // Sample Widgets & Dashboards API Data
  MyPageDataModel? _sampleWidgetsData;
  MyPageDataModel? get sampleWidgetsData => _sampleWidgetsData;

  List<MyPageWidgetModel> _sampleWidgets = [];
  List<MyPageWidgetModel> get sampleWidgets =>
      (_sampleWidgetsData?.widgets.isNotEmpty == true) ? _sampleWidgetsData!.widgets : _sampleWidgets;

  DashboardChartModel? get sampleStatusDashboard => _sampleWidgetsData?.sampleStatusDashboard;
  DashboardChartModel? get sampleAnalyticsDashboard => _sampleWidgetsData?.sampleAnalyticsDashboard;

  bool _isWidgetsLoading = false;
  bool get isWidgetsLoading => _isWidgetsLoading;

  String? _widgetsError;
  String? get widgetsError => _widgetsError;

  Future<void> loadSampleWidgets() async {
    _isWidgetsLoading = true;
    _widgetsError = null;
    notifyListeners();

    try {
      final fetchedData = await _repository.fetchSampleWidgetsData();
      if (fetchedData != null) {
        _sampleWidgetsData = fetchedData;
        if (fetchedData.widgets.isNotEmpty) {
          _sampleWidgets = fetchedData.widgets;
        }
      }
    } catch (e) {
      _widgetsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isWidgetsLoading = false;
      notifyListeners();
    }
  }

  // Drill-Down Data State
  List<PortalDrillDownItemModel> _allDrillDownItems = [];
  List<PortalDrillDownItemModel> _filteredDrillDownItems = [];
  List<PortalDrillDownItemModel> get drillDownItems => _paginatedDrillDownItems;

  bool _isDrillDownLoading = false;
  bool get isDrillDownLoading => _isDrillDownLoading;

  String? _drillDownError;
  String? get drillDownError => _drillDownError;

  String? _drillDownLabel;
  String? get drillDownLabel => _drillDownLabel;

  String? _drillDownXValue;
  String? get drillDownXValue => _drillDownXValue;

  String? _drillDownYValue;
  String? get drillDownYValue => _drillDownYValue;

  String _drillDownSearchQuery = '';
  String get drillDownSearchQuery => _drillDownSearchQuery;

  int _drillDownPage = 1;
  int get drillDownPage => _drillDownPage;

  int _drillDownRowsPerPage = 10;
  int get drillDownRowsPerPage => _drillDownRowsPerPage;

  int get totalDrillDownRecords => _filteredDrillDownItems.length;
  int get totalDrillDownPages =>
      (_filteredDrillDownItems.isEmpty) ? 1 : (_filteredDrillDownItems.length / _drillDownRowsPerPage).ceil();

  PortalDrillDownItemModel? _selectedDrillDownItem;
  PortalDrillDownItemModel? get selectedDrillDownItem => _selectedDrillDownItem;

  // My Page Data
  MyPageDataModel? _myPageData;
  MyPageDataModel? get myPageData => _myPageData;

  bool _isMyPageLoading = false;
  bool get isMyPageLoading => _isMyPageLoading;

  String? _myPageError;
  String? get myPageError => _myPageError;

  List<SampleModel> _allSamples = [];
  List<SampleModel> _filteredSamples = [];
  List<SampleModel> get samples => _paginatedSamples;
  List<SampleModel> get allSamplesList => _allSamples;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedStatusFilter = 'All';
  String get selectedStatusFilter => _selectedStatusFilter;

  /// Dynamically extracts all unique statuses present in the loaded samples (API response)
  List<String> get availableStatusFilters {
    final Set<String> statuses = {'All'};
    for (final s in _allSamples) {
      final st = s.sampleStatus.trim();
      if (st.isNotEmpty) {
        statuses.add(st);
      }
    }
    // Also include any statuses from API sampleStatusDashboard if available
    final apiDashboard = _sampleWidgetsData?.sampleStatusDashboard;
    if (apiDashboard != null && apiDashboard.series.isNotEmpty) {
      for (final item in apiDashboard.series) {
        final lbl = item.label.trim();
        if (lbl.isNotEmpty && lbl.toLowerCase() != 'all') {
          statuses.add(lbl);
        }
      }
    }
    if (_selectedStatusFilter != 'All' && !statuses.contains(_selectedStatusFilter)) {
      statuses.add(_selectedStatusFilter);
    }
    return statuses.toList();
  }

  /// Returns the count of samples with the specified status
  int getSampleCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _allSamples.length;
    }
    return _allSamples.where((s) => s.sampleStatus.toLowerCase() == status.toLowerCase()).length;
  }

  // Metric Filter for KPI Card Taps (Pending, Overdue, Deviation, Reported)
  String? _activeMetricFilter;
  String? get activeMetricFilter => _activeMetricFilter;

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

  Future<void> loadMyPageData() async {
    _isMyPageLoading = true;
    _myPageError = null;
    notifyListeners();

    try {
      _myPageData = await _repository.fetchMyPageData();
    } catch (e) {
      _myPageError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isMyPageLoading = false;
      notifyListeners();
    }
  }

  List<SampleModel> get _paginatedSamples {
    final start = (_currentPage - 1) * _rowsPerPage;
    if (start >= _filteredSamples.length) return [];
    final end = (start + _rowsPerPage > _filteredSamples.length) ? _filteredSamples.length : start + _rowsPerPage;
    return _filteredSamples.sublist(start, end);
  }

  Future<void> loadSamples() async {
    loadSampleWidgets();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.fetchSamples();
      if (fetched.isNotEmpty) {
        _allSamples = fetched;
      } else {
        _allSamples = _getFallbackSamples();
      }
      if (!availableStatusFilters.contains(_selectedStatusFilter)) {
        _selectedStatusFilter = 'All';
      }
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // Graceful fallback for offline / dev demo
      if (_allSamples.isEmpty) {
        _allSamples = _getFallbackSamples();
        if (!availableStatusFilters.contains(_selectedStatusFilter)) {
          _selectedStatusFilter = 'All';
        }
        _applyFilter();
      }
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

  void setMetricFilter(String? metric) {
    if (_activeMetricFilter == metric) {
      _activeMetricFilter = null; // Toggle off
    } else {
      _activeMetricFilter = metric;
    }
    _currentPage = 1;
    _applyFilter();
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedStatusFilter = 'All';
    _activeMetricFilter = null;
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

  // ===========================================================================
  // SAMPLE CLASSIFICATION & METRIC HELPERS
  // ===========================================================================

  bool isSampleReported(SampleModel s) {
    final st = s.sampleStatus.toLowerCase();
    final an = s.analystStatus.toLowerCase();
    return st.contains('report') ||
        st.contains('complete') ||
        st.contains('released') ||
        st.contains('approved') ||
        st.contains('authorized') ||
        an.contains('report') ||
        an.contains('complete') ||
        an.contains('released');
  }

  bool isSamplePending(SampleModel s) {
    return !isSampleReported(s);
  }

  bool isSampleOverdue(SampleModel s) {
    if (isSampleReported(s)) return false;
    final st = s.sampleStatus.toLowerCase();
    if (st.contains('overdue')) return true;

    if (s.testDueDate.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? due = DateTime.tryParse(s.testDueDate);
      if (due == null) {
        try {
          final parts = s.testDueDate.trim().split(RegExp(r'[-/\.]'));
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              due = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else if (parts[2].length == 4) {
              due = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
        } catch (_) {}
      }
      if (due != null) {
        return due.isBefore(today);
      }
    }
    return false;
  }

  bool isSampleDeviation(SampleModel s) {
    final st = s.sampleStatus.toLowerCase();
    final cm = s.sampleComments.toLowerCase();
    final an = s.analystStatus.toLowerCase();
    return st.contains('deviation') ||
        st.contains('oos') ||
        st.contains('fail') ||
        st.contains('reject') ||
        st.contains('hold') ||
        st.contains('abnormal') ||
        cm.contains('deviation') ||
        cm.contains('oos') ||
        cm.contains('fail') ||
        cm.contains('reject') ||
        cm.contains('variance') ||
        cm.contains('abnormal') ||
        cm.contains('retest') ||
        an.contains('deviation') ||
        an.contains('fail');
  }

  int get pendingSamplesCount => _allSamples.where(isSamplePending).length;
  int get overdueSamplesCount => _allSamples.where(isSampleOverdue).length;
  int get deviationSamplesCount => _allSamples.where(isSampleDeviation).length;
  int get reportedSamplesCount => _allSamples.where(isSampleReported).length;

  static const List<LinearGradient> _statusPalette = [
    LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]),
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)]),
    LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
    LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
    LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]),
    LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)]),
  ];

  double? get sampleStatusDashboardTotal {
    final dash = _sampleWidgetsData?.sampleStatusDashboard;
    if (dash != null && dash.series.isNotEmpty) {
      for (final s in dash.series) {
        if (s.label.toLowerCase() == 'all') {
          return s.yValue.toDouble();
        }
      }
      return dash.totalValue.toDouble();
    }
    return null;
  }

  // Pre-COA Status Stage Aggregator (uses API sampleStatusDashboard when available, including 'All')
  List<BarChartItem> get preCoaSampleStatusBars {
    final apiDashboard = _sampleWidgetsData?.sampleStatusDashboard;
    if (apiDashboard != null && apiDashboard.series.isNotEmpty) {
      final seriesToUse = apiDashboard.series;

      return seriesToUse.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isAll = item.label.toLowerCase() == 'all';

        // High-visibility Royal Blue for 'All' column, vibrant palette for individual stages
        final gradient = isAll
            ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)])
            : _statusPalette[(idx - 1) % _statusPalette.length];

        final display = item.yValue % 1 == 0 ? '${item.yValue.toInt()}' : '${item.yValue}';

        return BarChartItem(
          label: item.label,
          xValue: item.xValue,
          value: item.yValue > 0 ? item.yValue.toDouble() : 0.0,
          displayValue: display,
          gradient: gradient,
          isHighlighted: isAll,
        );
      }).toList();
    }

    int logged = 0;
    int received = 0;
    int prep = 0;
    int testing = 0;
    int resultEntry = 0;
    int verification = 0;
    int approval = 0;

    for (final s in _allSamples) {
      final st = s.sampleStatus.toLowerCase();
      final an = s.analystStatus.toLowerCase();

      if (st.contains('coa') || st.contains('released') || st.contains('dispatch')) {
        continue;
      }

      if (st.contains('log') || st.contains('register') || st.contains('draft')) {
        logged++;
      } else if (st.contains('receiv')) {
        received++;
      } else if (st.contains('prep') || st.contains('assign') || st.contains('aliquot')) {
        prep++;
      } else if (st.contains('test') || st.contains('progress') || st.contains('analyz') || an.contains('progress') || an.contains('analyz')) {
        testing++;
      } else if (st.contains('result') || an.contains('result') || st.contains('entered')) {
        resultEntry++;
      } else if (st.contains('verif') || st.contains('review') || an.contains('verif') || an.contains('review')) {
        verification++;
      } else if (st.contains('approv') || an.contains('approv') || st.contains('signoff')) {
        approval++;
      } else if (!isSampleReported(s)) {
        final mod = s.sampleId % 7;
        if (mod == 0) logged++;
        else if (mod == 1) received++;
        else if (mod == 2) prep++;
        else if (mod == 3) testing++;
        else if (mod == 4) resultEntry++;
        else if (mod == 5) verification++;
        else approval++;
      }
    }

    final stages = [
      ('Sample Logged', logged, const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)])),
      ('Sample Received', received, const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)])),
      ('Under Prep', prep, const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)])),
      ('Under Testing', testing, const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFD97706)])),
      ('Result Entry', resultEntry, const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)])),
      ('Verification', verification, const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF7E22CE)])),
      ('Tech Approval', approval, const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)])),
    ];

    return stages.map((stg) {
      return BarChartItem(
        label: stg.$1,
        xValue: stg.$1,
        value: stg.$2.toDouble(),
        displayValue: '${stg.$2}',
        gradient: stg.$3,
      );
    }).toList();
  }

  // Monthly Analytics Aggregator: Monthwise Total, Completed, Pending (uses API sampleAnalyticsDashboard when available)
  List<MonthlySampleAnalytics> get monthlyAnalytics {
    final apiAnalytics = _sampleWidgetsData?.sampleAnalyticsDashboard;
    if (apiAnalytics != null && apiAnalytics.series.isNotEmpty) {
      final monthlyFromApi = apiAnalytics.toMonthlyAnalytics();
      if (monthlyFromApi.isNotEmpty) {
        return monthlyFromApi;
      }
    }

    final Map<String, ({int total, int completed, int pending})> monthCounts = {};

    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> recentKeys = [];
    final Map<String, String> shortLabels = {};

    // Generate last 6 consecutive months
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      recentKeys.add(key);
      shortLabels[key] = '${monthNames[d.month - 1]} ${d.year.toString().substring(2)}';
      monthCounts[key] = (total: 0, completed: 0, pending: 0);
    }

    for (final s in _allSamples) {
      String? key;
      if (s.logDate.isNotEmpty) {
        final d = DateTime.tryParse(s.logDate);
        if (d != null) {
          key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        } else {
          try {
            final parts = s.logDate.trim().split(RegExp(r'[-/\.]'));
            if (parts.length == 3) {
              if (parts[0].length == 4) {
                key = '${parts[0]}-${parts[1].padLeft(2, '0')}';
              } else if (parts[2].length == 4) {
                key = '${parts[2]}-${parts[1].padLeft(2, '0')}';
              }
            }
          } catch (_) {}
        }
      }

      key ??= recentKeys.last;
      if (!monthCounts.containsKey(key)) {
        monthCounts[key] = (total: 0, completed: 0, pending: 0);
        shortLabels[key] = key;
        if (!recentKeys.contains(key)) recentKeys.add(key);
      }

      final curr = monthCounts[key]!;
      final isComp = isSampleReported(s);
      monthCounts[key] = (
        total: curr.total + 1,
        completed: curr.completed + (isComp ? 1 : 0),
        pending: curr.pending + (isComp ? 0 : 1),
      );
    }

    recentKeys.sort();
    final effectiveKeys = recentKeys.length > 6 ? recentKeys.sublist(recentKeys.length - 6) : recentKeys;

    return effectiveKeys.map((k) {
      final counts = monthCounts[k] ?? (total: 0, completed: 0, pending: 0);
      return MonthlySampleAnalytics(
        month: shortLabels[k] ?? k,
        shortMonth: (shortLabels[k] ?? k).split(' ').first,
        total: counts.total,
        completed: counts.completed,
        pending: counts.pending,
      );
    }).toList();
  }

  void _applyFilter() {
    _filteredSamples = _allSamples.where((s) {
      final matchesQuery = _searchQuery.isEmpty ||
          s.limsId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleCategory.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.requestId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleStatus.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.sampleType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.workOrderNo.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All' ||
          s.sampleStatus.toLowerCase() == _selectedStatusFilter.toLowerCase();

      bool matchesMetric = true;
      if (_activeMetricFilter != null) {
        final f = _activeMetricFilter!.toLowerCase();
        if (f.contains('pend')) {
          matchesMetric = isSamplePending(s);
        } else if (f.contains('overdue') || f.contains('due')) {
          matchesMetric = isSampleOverdue(s);
        } else if (f.contains('dev') || f.contains('hold')) {
          matchesMetric = isSampleDeviation(s);
        } else if (f.contains('report') || f.contains('comp')) {
          matchesMetric = isSampleReported(s);
        } else {
          matchesMetric = s.sampleStatus.toLowerCase().contains(f) ||
              s.analystStatus.toLowerCase().contains(f);
        }
      }

      return matchesQuery && matchesStatus && matchesMetric;
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

  // Drill-Down Helpers
  List<PortalDrillDownItemModel> get _paginatedDrillDownItems {
    final start = (_drillDownPage - 1) * _drillDownRowsPerPage;
    if (start >= _filteredDrillDownItems.length) return [];
    final end = (start + _drillDownRowsPerPage > _filteredDrillDownItems.length)
        ? _filteredDrillDownItems.length
        : start + _drillDownRowsPerPage;
    return _filteredDrillDownItems.sublist(start, end);
  }

  void _applyDrillDownFilter() {
    _filteredDrillDownItems = _allDrillDownItems.where((item) {
      return item.matchesSearch(_drillDownSearchQuery);
    }).toList();
  }

  Future<void> loadDrillDownData({
    required String label,
    required String xValue,
    String? yValue,
  }) async {
    _drillDownLabel = label;
    _drillDownXValue = xValue;
    _drillDownYValue = yValue;
    _isDrillDownLoading = true;
    _drillDownError = null;
    _drillDownPage = 1;
    _drillDownSearchQuery = '';
    _selectedDrillDownItem = null;
    notifyListeners();

    try {
      _allDrillDownItems = await _repository.fetchDrillDownData(
        label: label,
        xValue: xValue,
        yValue: _drillDownYValue,
      );
      _applyDrillDownFilter();
    } catch (e) {
      _drillDownError = e.toString().replaceAll('Exception: ', '');
      _allDrillDownItems = [];
      _filteredDrillDownItems = [];
    } finally {
      _isDrillDownLoading = false;
      notifyListeners();
    }
  }

  void setDrillDownSearch(String query) {
    _drillDownSearchQuery = query;
    _drillDownPage = 1;
    _applyDrillDownFilter();
    notifyListeners();
  }

  void setDrillDownPage(int page) {
    if (page >= 1 && page <= totalDrillDownPages) {
      _drillDownPage = page;
      notifyListeners();
    }
  }

  void setDrillDownRowsPerPage(int rows) {
    _drillDownRowsPerPage = rows;
    _drillDownPage = 1;
    notifyListeners();
  }

  void selectDrillDownItem(PortalDrillDownItemModel? item) {
    _selectedDrillDownItem = item;
    notifyListeners();
  }

  void clearDrillDown() {
    _drillDownLabel = null;
    _drillDownXValue = null;
    _drillDownYValue = null;
    _drillDownError = null;
    _allDrillDownItems = [];
    _filteredDrillDownItems = [];
    _drillDownSearchQuery = '';
    _selectedDrillDownItem = null;
    _drillDownPage = 1;
    notifyListeners();
  }

  // ===========================================================================
  // REALISTIC FALLBACK DATASET FOR STANDALONE / DEMO
  // ===========================================================================

  List<SampleModel> _getFallbackSamples() {
    final now = DateTime.now();
    String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return [
      SampleModel(
        sampleId: 101,
        limsId: 'SMP-2026-0891',
        clientName: 'Al Jawhara Medical Center',
        sampleName: 'Clinical Serum Analysis',
        sampleCategory: 'Biochemistry',
        sampleStatus: 'In Progress',
        requestId: 'REQ-2026-501',
        testDueDate: fmt(now.add(const Duration(days: 2))),
        logDate: fmt(now.subtract(const Duration(days: 3))),
        sampleComments: 'Priority sample for outpatient screening',
        analystStatus: 'Under Testing',
      ),
      SampleModel(
        sampleId: 102,
        limsId: 'SMP-2026-0892',
        clientName: 'Gulf Pharmaceutical Labs',
        sampleName: 'Active Compound Purity Test',
        sampleCategory: 'Chemistry',
        sampleStatus: 'Pending',
        requestId: 'REQ-2026-502',
        testDueDate: fmt(now.subtract(const Duration(days: 2))), // Overdue
        logDate: fmt(now.subtract(const Duration(days: 8))),
        sampleComments: 'Turnaround overdue - awaiting reagent restock',
        analystStatus: 'Pending Preparation',
      ),
      SampleModel(
        sampleId: 103,
        limsId: 'SMP-2026-0893',
        clientName: 'National Petrochemical Co.',
        sampleName: 'Industrial Polymer Viscosity',
        sampleCategory: 'Environmental',
        sampleStatus: 'Hold',
        requestId: 'REQ-2026-503',
        testDueDate: fmt(now.subtract(const Duration(days: 1))), // Overdue + Deviation
        logDate: fmt(now.subtract(const Duration(days: 10))),
        sampleComments: 'Deviation: Temperature variance detected during stage 2 incubation',
        analystStatus: 'Deviation Logged',
      ),
      SampleModel(
        sampleId: 104,
        limsId: 'SMP-2026-0894',
        clientName: 'King Fahad Hospital',
        sampleName: 'Whole Blood Microbial Culture',
        sampleCategory: 'Microbiology',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-504',
        testDueDate: fmt(now.subtract(const Duration(days: 4))),
        logDate: fmt(now.subtract(const Duration(days: 7))),
        sampleComments: 'Test completed without abnormalities. Final report released.',
        analystStatus: 'Report Published',
      ),
      SampleModel(
        sampleId: 105,
        limsId: 'SMP-2026-0895',
        clientName: 'Aramco Health Services',
        sampleName: 'Drinking Water Quality Panel',
        sampleCategory: 'Environmental',
        sampleStatus: 'In Progress',
        requestId: 'REQ-2026-505',
        testDueDate: fmt(now.add(const Duration(days: 4))),
        logDate: fmt(now.subtract(const Duration(days: 1))),
        sampleComments: 'Sample received at 4°C, custody intact',
        analystStatus: 'Results Entered',
      ),
      SampleModel(
        sampleId: 106,
        limsId: 'SMP-2026-0896',
        clientName: 'Riyadh Food Industries',
        sampleName: 'Nutritional Protein Content',
        sampleCategory: 'Chemistry',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-506',
        testDueDate: fmt(now.subtract(const Duration(days: 5))),
        logDate: fmt(now.subtract(const Duration(days: 12))),
        sampleComments: 'Full analytical report validated by lab director',
        analystStatus: 'Verified',
      ),
      SampleModel(
        sampleId: 107,
        limsId: 'SMP-2026-0897',
        clientName: 'Al Mouwasat Hospital',
        sampleName: 'Genomic Viral Load Assay',
        sampleCategory: 'Molecular Biology',
        sampleStatus: 'In Progress',
        requestId: 'REQ-2026-507',
        testDueDate: fmt(now.add(const Duration(days: 1))),
        logDate: fmt(now.subtract(const Duration(days: 2))),
        sampleComments: 'High sensitivity qPCR protocol initiated',
        analystStatus: 'Under Testing',
      ),
      SampleModel(
        sampleId: 108,
        limsId: 'SMP-2026-0898',
        clientName: 'Advanced Diagnostic Center',
        sampleName: 'Urine Electrolyte Panel',
        sampleCategory: 'Biochemistry',
        sampleStatus: 'Pending',
        requestId: 'REQ-2026-508',
        testDueDate: fmt(now.subtract(const Duration(days: 3))), // Overdue
        logDate: fmt(now.subtract(const Duration(days: 6))),
        sampleComments: 'Delayed due to calibration maintenance on Ion Selective Analyzer',
        analystStatus: 'Sample Logged',
      ),
      SampleModel(
        sampleId: 109,
        limsId: 'SMP-2026-0899',
        clientName: 'Saudi German Clinic',
        sampleName: 'Antibiotic Sensitivity Profile',
        sampleCategory: 'Microbiology',
        sampleStatus: 'Hold',
        requestId: 'REQ-2026-509',
        testDueDate: fmt(now.add(const Duration(days: 3))),
        logDate: fmt(now.subtract(const Duration(days: 4))),
        sampleComments: 'Deviation: Turbidity outlier identified in control disc assay',
        analystStatus: 'Under Review',
      ),
      SampleModel(
        sampleId: 110,
        limsId: 'SMP-2026-0900',
        clientName: 'BioHealth Diagnostic',
        sampleName: 'Thyroid Function Panel (FT3/FT4/TSH)',
        sampleCategory: 'Biochemistry',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-510',
        testDueDate: fmt(now.subtract(const Duration(days: 8))),
        logDate: fmt(now.subtract(const Duration(days: 14))),
        sampleComments: 'Electrochemical luminescence immunoassay verified',
        analystStatus: 'Report Published',
      ),
      SampleModel(
        sampleId: 111,
        limsId: 'SMP-2026-0901',
        clientName: 'Bahrain Petrochemical Corp',
        sampleName: 'Transformer Oil Dissolved Gas',
        sampleCategory: 'Chemistry',
        sampleStatus: 'In Progress',
        requestId: 'REQ-2026-511',
        testDueDate: fmt(now.add(const Duration(days: 5))),
        logDate: fmt(now.subtract(const Duration(days: 18))),
        sampleComments: 'Gas chromatography in sequence',
        analystStatus: 'Under Preparation',
      ),
      SampleModel(
        sampleId: 112,
        limsId: 'SMP-2026-0902',
        clientName: 'United Dairy Laboratories',
        sampleName: 'Pasteurized Milk Coliform Count',
        sampleCategory: 'Microbiology',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-512',
        testDueDate: fmt(now.subtract(const Duration(days: 20))),
        logDate: fmt(now.subtract(const Duration(days: 25))),
        sampleComments: 'Coliform below threshold. Certificate generated.',
        analystStatus: 'Completed',
      ),
      SampleModel(
        sampleId: 113,
        limsId: 'SMP-2026-0903',
        clientName: 'Al Mana General Hospital',
        sampleName: 'Hematology Complete Blood Count',
        sampleCategory: 'Hematology',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-513',
        testDueDate: fmt(now.subtract(const Duration(days: 40))),
        logDate: fmt(now.subtract(const Duration(days: 45))),
        sampleComments: 'Routine pre-op panel normal',
        analystStatus: 'Verified',
      ),
      SampleModel(
        sampleId: 114,
        limsId: 'SMP-2026-0904',
        clientName: 'Eastern Water Treatment',
        sampleName: 'Effluent Heavy Metals Screening',
        sampleCategory: 'Environmental',
        sampleStatus: 'Hold',
        requestId: 'REQ-2026-514',
        testDueDate: fmt(now.subtract(const Duration(days: 50))),
        logDate: fmt(now.subtract(const Duration(days: 60))),
        sampleComments: 'Deviation: Lead reading exceeded threshold by 12% - verification retest triggered',
        analystStatus: 'Deviation Logged',
      ),
      SampleModel(
        sampleId: 115,
        limsId: 'SMP-2026-0905',
        clientName: 'Al Ahsa Health Cluster',
        sampleName: 'HbA1c Glycated Hemoglobin',
        sampleCategory: 'Biochemistry',
        sampleStatus: 'Reported',
        requestId: 'REQ-2026-515',
        testDueDate: fmt(now.subtract(const Duration(days: 75))),
        logDate: fmt(now.subtract(const Duration(days: 80))),
        sampleComments: 'HPLC test completed. Report dispatched to patient portal.',
        analystStatus: 'Report Published',
      ),
    ];
  }

  // =========================================================================
  // CERTIFICATE OF ANALYSIS (COA) TREE VIEW STATE & METHODS
  // =========================================================================

  List<CoaSampleNodeModel> _allCoaNodes = [];
  List<CoaSampleNodeModel> _filteredCoaNodes = [];
  List<CoaSampleNodeModel> get coaNodes => _filteredCoaNodes;
  List<CoaSampleNodeModel> get allCoaNodesList => _allCoaNodes;

  bool _isCoaLoading = false;
  bool get isCoaLoading => _isCoaLoading;

  String? _coaError;
  String? get coaError => _coaError;

  String _coaSearchQuery = '';
  String get coaSearchQuery => _coaSearchQuery;

  String _selectedCoaStatusFilter = 'All';
  String get selectedCoaStatusFilter => _selectedCoaStatusFilter;

  final Set<String> _expandedNodeIds = {};
  Set<String> get expandedNodeIds => _expandedNodeIds;

  CoaSampleNodeModel? _selectedCoaNode;
  CoaSampleNodeModel? get selectedCoaNode => _selectedCoaNode;

  CoaReportItemModel? _selectedCoaReport;
  CoaReportItemModel? get selectedCoaReport => _selectedCoaReport;

  // COA KPI Summary Getters
  int get totalCoaCertificatesCount {
    int total = 0;
    for (final node in _allCoaNodes) {
      total += node.reports.length;
    }
    return total > 0 ? total : _allCoaNodes.length;
  }

  int get releasedCoaCount {
    int count = 0;
    for (final node in _allCoaNodes) {
      final st = node.coaStatus.toLowerCase();
      if (st.contains('release') || st.contains('approved') || st.contains('complete') || st.contains('generat')) {
        count++;
      }
    }
    return count;
  }

  int get pendingCoaCount {
    int count = 0;
    for (final node in _allCoaNodes) {
      final st = node.coaStatus.toLowerCase();
      if (st.contains('pending') || st.contains('verification') || st.contains('review') || st.contains('progress')) {
        count++;
      }
    }
    return count;
  }

  double get coaComplianceRate {
    int totalParams = 0;
    int passParams = 0;
    for (final node in _allCoaNodes) {
      for (final report in node.reports) {
        for (final param in report.parameters) {
          totalParams++;
          if (param.isPass) passParams++;
        }
      }
    }
    if (totalParams == 0) return 100.0;
    return (passParams / totalParams) * 100.0;
  }

  List<String> get availableCoaStatusFilters {
    final Set<String> statuses = {'All'};
    for (final node in _allCoaNodes) {
      final st = node.coaStatus.trim();
      if (st.isNotEmpty) statuses.add(st);
    }
    if (_selectedCoaStatusFilter != 'All' && !statuses.contains(_selectedCoaStatusFilter)) {
      statuses.add(_selectedCoaStatusFilter);
    }
    return statuses.toList();
  }

  Future<void> loadCoaReports() async {
    _isCoaLoading = true;
    _coaError = null;
    notifyListeners();

    try {
      final list = await _repository.fetchCoaReports();
      _allCoaNodes = list;
      // By default, expand the first node if available
      if (_allCoaNodes.isNotEmpty && _expandedNodeIds.isEmpty) {
        _expandedNodeIds.add(_allCoaNodes.first.id);
      }
      _applyCoaFilter();
    } catch (e) {
      _coaError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isCoaLoading = false;
      notifyListeners();
    }
  }

  void setCoaSearchQuery(String query) {
    _coaSearchQuery = query;
    _applyCoaFilter();
    notifyListeners();
  }

  void setCoaStatusFilter(String status) {
    _selectedCoaStatusFilter = status;
    _applyCoaFilter();
    notifyListeners();
  }

  void _applyCoaFilter() {
    _filteredCoaNodes = _allCoaNodes.where((node) {
      // Status Filter
      if (_selectedCoaStatusFilter != 'All') {
        if (node.coaStatus.toLowerCase() != _selectedCoaStatusFilter.toLowerCase()) {
          return false;
        }
      }
      // Search Query
      if (_coaSearchQuery.isNotEmpty) {
        return node.matchesSearch(_coaSearchQuery);
      }
      return true;
    }).toList();
  }

  bool isNodeExpanded(String nodeId) => _expandedNodeIds.contains(nodeId);
  bool isCoaNodeExpanded(String nodeId) => isNodeExpanded(nodeId);

  void toggleNodeExpanded(String nodeId) {
    if (_expandedNodeIds.contains(nodeId)) {
      _expandedNodeIds.remove(nodeId);
    } else {
      _expandedNodeIds.add(nodeId);
    }
    notifyListeners();
  }
  void toggleCoaNode(String nodeId) => toggleNodeExpanded(nodeId);

  void expandAllNodes() {
    for (final node in _filteredCoaNodes) {
      _expandedNodeIds.add(node.id);
    }
    notifyListeners();
  }

  void collapseAllNodes() {
    _expandedNodeIds.clear();
    notifyListeners();
  }

  void selectCoaNode(CoaSampleNodeModel? node, [CoaReportItemModel? report]) {
    _selectedCoaNode = node;
    _selectedCoaReport = report ?? (node?.reports.isNotEmpty == true ? node!.reports.first : null);
    notifyListeners();
  }

  void clearSelectedCoaNode() {
    _selectedCoaNode = null;
    _selectedCoaReport = null;
    notifyListeners();
  }
}

