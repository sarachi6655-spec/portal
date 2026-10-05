import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../dashboard/presentation/widgets/portal_sidebar.dart';
import '../../dashboard/presentation/widgets/portal_header.dart';
import 'controllers/sample_controller.dart';
import '../data/models/my_page_data_model.dart';
import '../data/models/portal_drill_down_model.dart';
import 'widgets/sample_status_badge.dart';
import 'widgets/sample_detail_drawer.dart';
import 'widgets/drill_down_detail_drawer.dart';
import 'widgets/drill_down_grid_section.dart';
import 'widgets/add_sample_dialog.dart';
import 'widgets/three_d_bar_chart_card.dart';
import 'widgets/three_d_stat_card.dart';
import 'widgets/sample_tracking_stats.dart';
import 'widgets/sample_analytics_chart_card.dart';
import '../data/models/coa_report_model.dart';
import 'widgets/coa_tree_view_section.dart';
import 'widgets/coa_certificate_drawer.dart';

class SampleListScreen extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLogout;
  final int initialNavIndex;

  const SampleListScreen({
    super.key,
    required this.authController,
    required this.onLogout,
    this.initialNavIndex = 4, // Default to Sample Tracking screen
  });

  @override
  State<SampleListScreen> createState() => _SampleListScreenState();
}

class _SampleListScreenState extends State<SampleListScreen> {
  final SampleController _sampleController = SampleController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool _isSidebarCollapsed = false;
  late int _selectedNavIndex;

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = widget.initialNavIndex;
    _sampleController.addListener(_onStateChanged);
    _sampleController.loadSamples();
    _sampleController.loadMyPageData();
    _sampleController.loadSampleWidgets();
    _sampleController.loadCoaReports();
  }

  @override
  void dispose() {
    _sampleController.removeListener(_onStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _openAddSampleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddSampleDialog(controller: _sampleController),
    );
  }

  void _openSampleDetail(int sampleId) async {
    await _sampleController.loadSampleDetail(sampleId);
    if (!mounted) return;

    final detail = _sampleController.selectedSampleDetail;
    if (detail != null) {
      if (Responsive.isMobile(context)) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SampleDetailDrawer(
                detail: detail,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ).then((_) {
          _sampleController.clearSelectedDetail();
        });
      } else {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'SampleDetail',
          barrierColor: Colors.black.withValues(alpha: 0.45),
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (dialogContext, anim1, anim2) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: SampleDetailDrawer(
                  detail: detail,
                  onClose: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            );
          },
          transitionBuilder: (dialogContext, anim1, anim2, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: anim1,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ).then((_) {
          _sampleController.clearSelectedDetail();
        });
      }
    }
  }

  void _handleDrillDown(String label, String xValue, {String? yValue}) {
    _sampleController.loadDrillDownData(label: label, xValue: xValue, yValue: yValue);
  }

  void _openDrillDownDetail(PortalDrillDownItemModel item) {
    _sampleController.selectDrillDownItem(item);
    if (Responsive.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: DrillDownDetailDrawer(
              item: item,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ).then((_) {
        _sampleController.selectDrillDownItem(null);
      });
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'DrillDownDetail',
        barrierColor: Colors.black.withValues(alpha: 0.45),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (dialogContext, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: DrillDownDetailDrawer(
                item: item,
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          );
        },
        transitionBuilder: (dialogContext, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ).then((_) {
        _sampleController.selectDrillDownItem(null);
      });
    }
  }

  void _openCoaCertificate(CoaSampleNodeModel node, CoaReportItemModel report) {
    _sampleController.selectCoaNode(node, report);
    if (Responsive.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.92,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CoaCertificateDrawer(
              node: node,
              report: report,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ).then((_) {
        _sampleController.clearSelectedCoaNode();
      });
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'CoaCertificate',
        barrierColor: Colors.black.withValues(alpha: 0.45),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (dialogContext, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: CoaCertificateDrawer(
                node: node,
                report: report,
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          );
        },
        transitionBuilder: (dialogContext, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ).then((_) {
        _sampleController.clearSelectedCoaNode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgBody,
      drawer: isMobile
          ? Drawer(
              child: PortalSidebar(
                isCollapsed: false,
                selectedIndex: _selectedNavIndex,
                onItemSelected: (idx) {
                  if (_sampleController.drillDownLabel != null) {
                    _sampleController.clearDrillDown();
                  }
                  setState(() => _selectedNavIndex = idx);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Left Sidebar on Tablet/Desktop
          if (!isMobile)
            PortalSidebar(
              isCollapsed: _isSidebarCollapsed,
              selectedIndex: _selectedNavIndex,
              onItemSelected: (idx) {
                if (_sampleController.drillDownLabel != null) {
                  _sampleController.clearDrillDown();
                }
                setState(() => _selectedNavIndex = idx);
              },
            ),

          // Main Scrollable Dashboard Content
          Expanded(
            child: Column(
              children: [
                PortalHeader(
                  onToggleMenu: () {
                    if (isMobile) {
                      _scaffoldKey.currentState?.openDrawer();
                    } else {
                      setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
                    }
                  },
                  authController: widget.authController,
                  onLogout: widget.onLogout,
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        _sampleController.loadSamples(),
                        _sampleController.loadMyPageData(),
                        _sampleController.loadCoaReports(),
                      ]);
                    },
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 14 : 24),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Header & Quick Stats
                              _buildWelcomeAndStats(isMobile),

                              // 2. Main Section View
                              _buildMainViewContent(context, isMobile),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeAndStats(bool isMobile) {
    String title;
    String subtitle;

    switch (_selectedNavIndex) {
      case 0:
        title = 'My Page';
        subtitle = 'Track and manage your enquiries, payments, and laboratory samples';
        break;
      case 1:
        title = 'Enquiry';
        subtitle = 'Submit and track customer enquiries and laboratory quotations';
        break;
      case 2:
        title = 'Orders';
        subtitle = 'View and manage laboratory purchase orders, invoices, and receipts';
        break;
      case 3:
        title = 'Sample Registration';
        subtitle = 'Register, categorize, and submit new laboratory sample batches';
        break;
      case 4:
        title = 'Sample Tracking';
        subtitle = 'Monitor real-time progress, testing milestones, and turnaround time';
        break;
      case 5:
        title = 'Certificate of Analysis';
        subtitle = 'Verify, review, and download official laboratory test certificates (COA)';
        break;
      default:
        title = 'Portal';
        subtitle = 'Manage laboratory operations';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Stats Summary Badges (5 KPI boxes on My Page, 4 KPI cards on Sample Tracking, 4 Quick Stat boxes on other menus, none on Certificate of Analysis)
        if (_selectedNavIndex == 0) ...[
          _buildMyPageStats(isMobile),
          const SizedBox(height: 20),
        ] else if (_selectedNavIndex == 4) ...[
          SampleTrackingStats(
            controller: _sampleController,
            isMobile: isMobile,
            onDrillDown: (label, xValue) => _handleDrillDown(label, xValue),
          ),
          const SizedBox(height: 20),
        ] else if (_selectedNavIndex == 5) ...[
          // No widgets on Certificate of Analysis screen
          const SizedBox(height: 6),
        ] else ...[
          _buildSampleListStats(isMobile),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSampleListStats(bool isMobile) {
    final total = _sampleController.totalRecords;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        return GridView.count(
          crossAxisCount: isNarrow ? 2 : 4,
          shrinkWrap: true,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isNarrow ? 1.7 : 2.25,
          children: [
            _buildStatCard('Total Samples', '$total', AppColors.cardBlueGradient, Icons.inventory_2_outlined),
            _buildStatCard('Completed', '${_getSampleCount('Complete')}', AppColors.cardGreenGradient, Icons.check_circle_outline),
            _buildStatCard('In Progress', '${_getSampleCount('Progress')}', const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF6366F1)]), Icons.hourglass_top),
            _buildStatCard('Pending / Hold', '${_getSampleCount('Pending') + _getSampleCount('Hold')}', AppColors.cardOrangeGradient, Icons.pending_actions),
          ],
        );
      },
    );
  }

  Widget _buildMainViewContent(BuildContext context, bool isMobile) {
    switch (_selectedNavIndex) {
      case 0:
        if (_sampleController.drillDownLabel != null) {
          return DrillDownGridSection(
            controller: _sampleController,
            isMobile: isMobile,
            sourceTitle: 'My Page',
            onBackToDashboard: () => _sampleController.clearDrillDown(),
            onInspectItem: (item) => _openDrillDownDetail(item),
          );
        }
        return _buildMyPageDashboards(context, isMobile);
      case 4:
        if (_sampleController.drillDownLabel != null) {
          return DrillDownGridSection(
            controller: _sampleController,
            isMobile: isMobile,
            sourceTitle: 'Sample Tracking',
            onBackToDashboard: () => _sampleController.clearDrillDown(),
            onInspectItem: (item) => _openDrillDownDetail(item),
          );
        }
        return _buildSampleTrackingContent(context, isMobile);
      case 1:
      case 2:
      case 3:
        return _buildSampleListSection(context, isMobile);
      case 5:
        return CoaTreeViewSection(
          controller: _sampleController,
          isMobile: isMobile,
          onInspectCoa: (node, report) => _openCoaCertificate(node, report),
        );
      default:
        return _buildSampleListSection(context, isMobile);
    }
  }

  Widget _buildSampleTrackingContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Two Analytical Charts: Sample Status & Sample Analytics
        _buildSampleTrackingCharts(context, isMobile),

        const SizedBox(height: 20),

        // 2. Existing Grid List
        _buildSampleListSection(context, isMobile),
      ],
    );
  }

  Widget _buildSampleTrackingCharts(BuildContext context, bool isMobile) {
    final preCoaBars = _sampleController.preCoaSampleStatusBars;
    final totalPreCoa = _sampleController.sampleStatusDashboardTotal ??
        preCoaBars.fold<double>(0.0, (sum, item) => sum + item.value);

    final title = _sampleController.sampleStatusDashboard?.chartName.isNotEmpty == true
        ? _sampleController.sampleStatusDashboard!.chartName
        : 'Sample Status';

    final isApiDashboard = _sampleController.sampleStatusDashboard != null;

    final chart1 = ThreeDBarChartCard(
      title: title,
      subtitle: isApiDashboard ? 'Status breakdown' : 'All status before COA Generation',
      icon: Icons.donut_large_rounded,
      iconColor: const Color(0xFF0284C7),
      summaryBadge: 'Total: ${totalPreCoa.toInt()}',
      badgeBgColor: const Color(0xFFE0F2FE),
      badgeTextColor: const Color(0xFF0369A1),
      isMobile: isMobile,
      totalValue: totalPreCoa,
      unit: 'samples',
      bars: preCoaBars,
      onBarTap: (bar) {
        final label = _sampleController.sampleStatusDashboard?.chartName.isNotEmpty == true
            ? _sampleController.sampleStatusDashboard!.chartName
            : 'Sample Status Dashboard';
        final xValue = (bar.xValue != null && bar.xValue!.isNotEmpty) ? bar.xValue! : bar.label;
        _handleDrillDown(label, xValue);
      },
    );

    final chart2 = SampleAnalyticsChartCard(
      data: _sampleController.monthlyAnalytics,
      isMobile: isMobile,
      onMonthTap: (item, status) {
        final label = status;
        final monthOnly = item.shortMonth.isNotEmpty
            ? item.shortMonth.trim().split(RegExp(r'[- /]')).first
            : item.month.trim().split(RegExp(r'[- /]')).first;
        _handleDrillDown(label, monthOnly);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1080;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart1),
              const SizedBox(width: 16),
              Expanded(child: chart2),
            ],
          );
        } else {
          return Column(
            children: [
              chart1,
              const SizedBox(height: 16),
              chart2,
            ],
          );
        }
      },
    );
  }

  // My Page Content: Bar Chart Dashboards (Sample Status, Orders, Payments)
  Widget _buildMyPageDashboards(BuildContext context, bool isMobile) {
    if (_sampleController.isMyPageLoading && _sampleController.myPageData == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final myPage = _sampleController.myPageData;
    if (myPage == null) {
      return const SizedBox.shrink();
    }

    final sampleStatus = myPage.sampleStatusDashboard;
    final orders = myPage.ordersDashboard;
    final payments = myPage.paymentsDashboard;

    final List<Widget> chartCards = [];
    if (sampleStatus != null && sampleStatus.series.isNotEmpty) {
      chartCards.add(_buildSampleStatusBarChart(isMobile, sampleStatus));
    }
    if (orders != null && orders.series.isNotEmpty) {
      chartCards.add(_buildOrdersBarChart(isMobile, orders));
    }
    if (payments != null && payments.series.isNotEmpty) {
      chartCards.add(_buildPaymentsBarChart(isMobile, payments));
    }

    if (chartCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1080;
        final isTablet = constraints.maxWidth >= 720 && constraints.maxWidth < 1080;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < chartCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: chartCards[i]),
              ],
            ],
          );
        } else if (isTablet && chartCards.length > 1) {
          return Column(
            children: [
              chartCards.first,
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 1; i < chartCards.length; i++) ...[
                    if (i > 1) const SizedBox(width: 16),
                    Expanded(child: chartCards[i]),
                  ],
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              for (int i = 0; i < chartCards.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                chartCards[i],
              ],
            ],
          );
        }
      },
    );
  }

  static const List<LinearGradient> _sampleStatusGradients = [
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
    LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
    LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
    LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
    LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)]),
  ];

  static const List<LinearGradient> _ordersGradients = [
    LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]),
    LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)]),
    LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)]),
    LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]),
    LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)]),
    LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFDB2777)]),
  ];

  static const List<LinearGradient> _paymentsGradients = [
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF047857)]),
    LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFD97706)]),
    LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
    LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
    LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
  ];

  List<BarChartItem> _buildBarsFromChart(
    DashboardChartModel? chart,
    List<LinearGradient> palette,
  ) {
    if (chart == null || chart.series.isEmpty) return [];

    return chart.series.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      final gradient = palette[idx % palette.length];
      final display = item.yValue % 1 == 0 ? '${item.yValue.toInt()}' : '${item.yValue}';

      return BarChartItem(
        label: item.label,
        xValue: item.xValue,
        value: item.yValue > 0 ? item.yValue.toDouble() : 0.0,
        displayValue: display,
        gradient: gradient,
        isHighlighted: idx == chart.series.length - 1,
      );
    }).toList();
  }

  // Dashboard 1: Sample Status 3D Bar Chart
  Widget _buildSampleStatusBarChart(bool isMobile, DashboardChartModel dashboard) {
    final bars = _buildBarsFromChart(dashboard, _sampleStatusGradients);
    final summary = 'Total: ${dashboard.totalValue % 1 == 0 ? dashboard.totalValue.toInt() : dashboard.totalValue}';

    return ThreeDBarChartCard(
      title: dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Sample Status',
      subtitle: 'Testing stages breakdown',
      icon: Icons.analytics_rounded,
      iconColor: const Color(0xFF2490EB),
      summaryBadge: summary,
      badgeBgColor: const Color(0xFFD3E9FB),
      badgeTextColor: const Color(0xFF14457B),
      isMobile: isMobile,
      totalValue: dashboard.totalValue.toDouble(),
      unit: 'samples',
      bars: bars,
      onBarTap: (bar) {
        final label = dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Sample Status Dashboard';
        final xValue = (bar.xValue != null && bar.xValue!.isNotEmpty) ? bar.xValue! : bar.label;
        _handleDrillDown(label, xValue);
      },
    );
  }

  // Dashboard 2: Orders 3D Bar Chart
  Widget _buildOrdersBarChart(bool isMobile, DashboardChartModel dashboard) {
    final bars = _buildBarsFromChart(dashboard, _ordersGradients);
    final summary = 'Total: ${dashboard.totalValue % 1 == 0 ? dashboard.totalValue.toInt() : dashboard.totalValue}';

    return ThreeDBarChartCard(
      title: dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Orders Dashboard',
      subtitle: 'Monthly purchase orders',
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF0D9488),
      summaryBadge: summary,
      badgeBgColor: const Color(0xFFCCFBF1),
      badgeTextColor: const Color(0xFF0F766E),
      isMobile: isMobile,
      totalValue: dashboard.totalValue.toDouble(),
      unit: 'orders',
      bars: bars,
      onBarTap: (bar) {
        final label = dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Orders Dashboard';
        final xValue = (bar.xValue != null && bar.xValue!.isNotEmpty) ? bar.xValue! : bar.label;
        _handleDrillDown(label, xValue);
      },
    );
  }

  // Dashboard 3: Payments 3D Bar Chart
  Widget _buildPaymentsBarChart(bool isMobile, DashboardChartModel dashboard) {
    final bars = _buildBarsFromChart(dashboard, _paymentsGradients);
    final summary = 'Total: ${dashboard.totalValue % 1 == 0 ? dashboard.totalValue.toInt() : dashboard.totalValue}';

    return ThreeDBarChartCard(
      title: dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Payments Dashboard',
      subtitle: 'Collections breakdown',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFFD97706),
      summaryBadge: summary,
      badgeBgColor: const Color(0xFFFEF3C7),
      badgeTextColor: const Color(0xFFB45309),
      isMobile: isMobile,
      totalValue: dashboard.totalValue.toDouble(),
      unit: 'SAR',
      bars: bars,
      onBarTap: (bar) {
        final label = dashboard.chartName.isNotEmpty ? dashboard.chartName : 'Payments Dashboard';
        final xValue = (bar.xValue != null && bar.xValue!.isNotEmpty) ? bar.xValue! : bar.label;
        _handleDrillDown(label, xValue);
      },
    );
  }

  Widget _buildSampleListSection(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Control Bar: Search + Status Filter + Add Button
          _buildTableControls(isMobile),

          const SizedBox(height: 16),

          // Loading Spinner or Table Grid
          if (_sampleController.isLoading)
            const SizedBox(
              height: 320,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_sampleController.samples.isEmpty)
            _buildEmptyState()
          else
            _buildDataTable(context),

          const SizedBox(height: 16),

          // Pagination Footer Controls
          _buildPaginationFooter(isMobile),
        ],
      ),
    );
  }

  (IconData, LinearGradient) _getWidgetStyle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('enquiry')) {
      return (
        Icons.help_outline_rounded,
        const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
      );
    } else if (lower.contains('order')) {
      return (
        Icons.receipt_long_rounded,
        const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)]),
      );
    } else if (lower.contains('payment')) {
      return (
        Icons.account_balance_wallet_rounded,
        const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
      );
    } else if (lower.contains('complete')) {
      return (
        Icons.check_circle_outline_rounded,
        const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
      );
    } else if (lower.contains('result')) {
      return (
        Icons.hourglass_top_rounded,
        const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
      );
    } else if (lower.contains('send')) {
      return (
        Icons.local_shipping_outlined,
        const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
      );
    }
    return (
      Icons.analytics_outlined,
      AppColors.cardBlueGradient,
    );
  }

  Widget _buildMyPageStats(bool isMobile) {
    if (_sampleController.isMyPageLoading && _sampleController.myPageData == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final myPage = _sampleController.myPageData;
    if (myPage == null || myPage.widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> statCards = [];
    for (final w in myPage.widgets) {
      final style = _getWidgetStyle(w.name);
      final icon = style.$1;
      final gradient = style.$2;
      final displayValue = w.value % 1 == 0 ? '${w.value.toInt()}' : '${w.value}';
      statCards.add(
        _buildStatCard(
          w.name,
          displayValue,
          gradient,
          icon,
          onTap: () {
            final xVal = (w.xValue != null && w.xValue!.trim().isNotEmpty)
                ? w.xValue!.trim()
                : '';
            final label = (w.label != null && w.label!.trim().isNotEmpty)
                ? w.label!.trim()
                : w.name;
            _handleDrillDown(label, xVal);
          },
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (width >= 1200) {
          crossAxisCount = statCards.length.clamp(1, 6);
          childAspectRatio = 1.72;
        } else if (width >= 750) {
          crossAxisCount = statCards.length > 3 ? 3 : statCards.length;
          childAspectRatio = 2.05;
        } else {
          crossAxisCount = statCards.length > 1 ? 2 : 1;
          childAspectRatio = 1.62;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: childAspectRatio,
          children: statCards,
        );
      },
    );
  }

  int _getSampleCount(String keyword) {
    return _sampleController.samples.where((s) => s.sampleStatus.toLowerCase().contains(keyword.toLowerCase())).length;
  }

  Widget _buildStatCard(
    String label,
    String value,
    LinearGradient gradient,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ThreeDStatCard(
      label: label,
      value: value,
      gradient: gradient,
      icon: icon,
      onTap: onTap,
    );
  }

  Widget _buildTableControls(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => _sampleController.setSearchQuery(val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search samples...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _sampleController.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sampleController.selectedStatusFilter,
                  isExpanded: true,
                  items: _sampleController.availableStatusFilters.map((st) {
                    final count = _sampleController.getSampleCountByStatus(st);
                    final label = st == 'All' ? 'All ($count)' : '$st ($count)';
                    return DropdownMenuItem(
                      value: st,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _sampleController.setStatusFilter(val);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Add Sample Button
              ElevatedButton.icon(
                onPressed: _openAddSampleDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Sample'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Live Search Input matching portal.css .search-input
        SizedBox(
          width: 280,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => _sampleController.setSearchQuery(val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by LIMS ID, Client, Sample...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _sampleController.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Status Filter Pill Dropdown
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.formBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sampleController.selectedStatusFilter,
              icon: const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
              items: _sampleController.availableStatusFilters.map((st) {
                final count = _sampleController.getSampleCountByStatus(st);
                final label = st == 'All' ? 'Status: All ($count)' : 'Status: $st ($count)';
                return DropdownMenuItem(
                  value: st,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) _sampleController.setStatusFilter(val);
              },
            ),
          ),
        ),

        const Spacer(),

        // Add Sample Primary Button matching .sample-add-btn
        ElevatedButton.icon(
          onPressed: _openAddSampleDialog,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Sample'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final startIndex = (_sampleController.currentPage - 1) * _sampleController.rowsPerPage;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.hoverBg),
          headingTextStyle: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
          dataTextStyle: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          columnSpacing: 22,
          horizontalMargin: 16,
          headingRowHeight: 46,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 52,
          columns: const [
            DataColumn(label: Text('S.NO')),
            DataColumn(label: Text('LIMS ID')),
            DataColumn(label: Text('CLIENT NAME')),
            DataColumn(label: Text('SAMPLE NAME')),
            DataColumn(label: Text('ACTION')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('REQUEST ID')),
            DataColumn(label: Text('TEST DUE DATE')),
            DataColumn(label: Text('LOG DATE')),
            DataColumn(label: Text('ANALYST STATUS')),
          ],
          rows: List<DataRow>.generate(
            _sampleController.samples.length,
            (index) {
              final sample = _sampleController.samples[index];
              final sNo = startIndex + index + 1;

              return DataRow(
                cells: [
                  DataCell(Text('$sNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataCell(Text(sample.limsId.isNotEmpty ? sample.limsId : '-', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkBlue))),
                  DataCell(Text(sample.clientName.isNotEmpty ? sample.clientName : '-')),
                  DataCell(Text(sample.sampleName.isNotEmpty ? sample.sampleName : '-')),
                  DataCell(
                    OutlinedButton.icon(
                      onPressed: () => _openSampleDetail(sample.sampleId),
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: const Size(60, 30),
                        side: const BorderSide(color: Color(0xFF14467B)),
                        foregroundColor: AppColors.textSecondary,
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(Text(sample.sampleCategory.isNotEmpty ? sample.sampleCategory : '-')),
                  DataCell(SampleStatusBadge(status: sample.sampleStatus)),
                  DataCell(Text(sample.requestId.isNotEmpty ? sample.requestId : '-')),
                  DataCell(Text(sample.testDueDate.isNotEmpty ? sample.testDueDate : '-')),
                  DataCell(Text(sample.logDate.isNotEmpty ? sample.logDate : '-')),
                  DataCell(SampleStatusBadge(status: sample.analystStatus)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No sample records found',
            style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(bool isMobile) {
    final total = _sampleController.totalRecords;
    final start = total == 0 ? 0 : (_sampleController.currentPage - 1) * _sampleController.rowsPerPage + 1;
    final end = (_sampleController.currentPage * _sampleController.rowsPerPage > total)
        ? total
        : _sampleController.currentPage * _sampleController.rowsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page Info text
        Text(
          'Showing $start to $end of $total entries',
          style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
        ),

        // Pagination buttons
        Row(
          children: [
            // Rows per page dropdown (Desktop)
            if (!isMobile) ...[
              Text('Rows per page: ', style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted)),
              DropdownButton<int>(
                value: _sampleController.rowsPerPage,
                items: [10, 25, 50, 100].map((r) {
                  return DropdownMenuItem(value: r, child: Text('$r', style: const TextStyle(fontSize: 12)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) _sampleController.setRowsPerPage(val);
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 14),
            ],

            // Previous button
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _sampleController.currentPage > 1
                  ? () => _sampleController.setPage(_sampleController.currentPage - 1)
                  : null,
            ),

            // Page Number Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_sampleController.currentPage} / ${_sampleController.totalPages}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),

            // Next button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _sampleController.currentPage < _sampleController.totalPages
                  ? () => _sampleController.setPage(_sampleController.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

}

