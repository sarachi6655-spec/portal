import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../dashboard/presentation/widgets/portal_sidebar.dart';
import '../../dashboard/presentation/widgets/portal_header.dart';
import 'controllers/sample_controller.dart';
import 'widgets/sample_status_badge.dart';
import 'widgets/sample_detail_drawer.dart';
import 'widgets/add_sample_dialog.dart';

class SampleListScreen extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLogout;

  const SampleListScreen({
    super.key,
    required this.authController,
    required this.onLogout,
  });

  @override
  State<SampleListScreen> createState() => _SampleListScreenState();
}

class _SampleListScreenState extends State<SampleListScreen> {
  final SampleController _sampleController = SampleController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool _isSidebarCollapsed = false;
  int _selectedNavIndex = 0; // My Page active by default

  @override
  void initState() {
    super.initState();
    _sampleController.addListener(_onStateChanged);
    _sampleController.loadSamples();
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
        );
      } else {
        _scaffoldKey.currentState?.openEndDrawer();
      }
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
                  setState(() => _selectedNavIndex = idx);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      endDrawer: !isMobile && _sampleController.selectedSampleDetail != null
          ? Drawer(
              width: 680,
              child: SampleDetailDrawer(
                detail: _sampleController.selectedSampleDetail!,
                onClose: () {
                  Navigator.of(context).pop();
                  _sampleController.clearSelectedDetail();
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
              onItemSelected: (idx) => setState(() => _selectedNavIndex = idx),
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
                    onRefresh: _sampleController.loadSamples,
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

        // Quick Stats Summary Badges (5 KPI boxes on My Page, 4 Quick Stat boxes on the other 5 menus)
        if (_selectedNavIndex == 0) ...[
          _buildMyPageStats(isMobile),
          const SizedBox(height: 20),
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
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isNarrow ? 1.8 : 2.4,
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
        return _buildMyPageDashboards(context, isMobile);
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      default:
        return _buildSampleListSection(context, isMobile);
    }
  }

  // My Page Content: 3 Bar Chart Dashboards (Sample Status, Orders, Payments)
  Widget _buildMyPageDashboards(BuildContext context, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1080;
        final isTablet = constraints.maxWidth >= 720 && constraints.maxWidth < 1080;

        final sampleStatusCard = _buildSampleStatusBarChart(isMobile);
        final ordersCard = _buildOrdersBarChart(isMobile);
        final paymentsCard = _buildPaymentsBarChart(isMobile);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sampleStatusCard),
              const SizedBox(width: 16),
              Expanded(child: ordersCard),
              const SizedBox(width: 16),
              Expanded(child: paymentsCard),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              sampleStatusCard,
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ordersCard),
                  const SizedBox(width: 16),
                  Expanded(child: paymentsCard),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              sampleStatusCard,
              const SizedBox(height: 16),
              ordersCard,
              const SizedBox(height: 16),
              paymentsCard,
            ],
          );
        }
      },
    );
  }

  // Dashboard 1: Sample Status Bar Chart
  Widget _buildSampleStatusBarChart(bool isMobile) {
    final completed = _getSampleCount('Complete').toDouble();
    final inProgress = _getSampleCount('Progress').toDouble();
    final sampling = _getSampleCount('Sampling').toDouble();
    final received = _getSampleCount('Received').toDouble();
    final pendingHold = (_getSampleCount('Pending') + _getSampleCount('Hold')).toDouble();
    final total = _sampleController.samples.length;

    return _buildBarChartCard(
      title: 'Sample Status',
      subtitle: 'Testing stages breakdown',
      icon: Icons.analytics_rounded,
      iconColor: const Color(0xFF2490EB),
      summaryBadge: 'Total: $total',
      badgeBgColor: const Color(0xFFD3E9FB),
      badgeTextColor: const Color(0xFF14457B),
      isMobile: isMobile,
      bars: [
        _BarData(
          label: 'Completed',
          value: completed > 0 ? completed : 0.2,
          displayValue: '${completed.toInt()}',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
        ),
        _BarData(
          label: 'In Progress',
          value: inProgress > 0 ? inProgress : 0.2,
          displayValue: '${inProgress.toInt()}',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
        ),
        _BarData(
          label: 'Sampling',
          value: sampling > 0 ? sampling : 0.2,
          displayValue: '${sampling.toInt()}',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          ),
        ),
        _BarData(
          label: 'Received',
          value: received > 0 ? received : 0.2,
          displayValue: '${received.toInt()}',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          ),
        ),
        _BarData(
          label: 'Pending',
          value: pendingHold > 0 ? pendingHold : 0.2,
          displayValue: '${pendingHold.toInt()}',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF97316), Color(0xFFC2410C)],
          ),
        ),
      ],
    );
  }

  // Dashboard 2: Orders Bar Chart
  Widget _buildOrdersBarChart(bool isMobile) {
    return _buildBarChartCard(
      title: 'Orders Dashboard',
      subtitle: 'Monthly purchase orders',
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF0D9488),
      summaryBadge: 'Total: 93',
      badgeBgColor: const Color(0xFFCCFBF1),
      badgeTextColor: const Color(0xFF0F766E),
      isMobile: isMobile,
      bars: [
        _BarData(
          label: 'Apr',
          value: 8,
          displayValue: '8',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
          ),
        ),
        _BarData(
          label: 'May',
          value: 14,
          displayValue: '14',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
          ),
        ),
        _BarData(
          label: 'Jun',
          value: 19,
          displayValue: '19',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
          ),
        ),
        _BarData(
          label: 'Jul',
          value: 12,
          displayValue: '12',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
          ),
        ),
        _BarData(
          label: 'Aug',
          value: 24,
          displayValue: '24',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          ),
        ),
        _BarData(
          label: 'Sep',
          value: 16,
          displayValue: '16',
          isHighlighted: true,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D9488), Color(0xFF115E59)],
          ),
        ),
      ],
    );
  }

  // Dashboard 3: Payments Bar Chart
  Widget _buildPaymentsBarChart(bool isMobile) {
    return _buildBarChartCard(
      title: 'Payments Dashboard',
      subtitle: 'Monthly collections (SAR k)',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFFD97706),
      summaryBadge: 'SAR 126.5k',
      badgeBgColor: const Color(0xFFFEF3C7),
      badgeTextColor: const Color(0xFFB45309),
      isMobile: isMobile,
      bars: [
        _BarData(
          label: 'Apr',
          value: 12.5,
          displayValue: '12.5k',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
          ),
        ),
        _BarData(
          label: 'May',
          value: 18.2,
          displayValue: '18.2k',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
          ),
        ),
        _BarData(
          label: 'Jun',
          value: 25.0,
          displayValue: '25.0k',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
          ),
        ),
        _BarData(
          label: 'Jul',
          value: 16.8,
          displayValue: '16.8k',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
          ),
        ),
        _BarData(
          label: 'Aug',
          value: 32.4,
          displayValue: '32.4k',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
          ),
        ),
        _BarData(
          label: 'Sep',
          value: 21.6,
          displayValue: '21.6k',
          isHighlighted: true,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD97706), Color(0xFF92400E)],
          ),
        ),
      ],
    );
  }

  // Reusable Bar Chart Card Component
  Widget _buildBarChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String summaryBadge,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required List<_BarData> bars,
    required bool isMobile,
  }) {
    double maxVal = 0;
    for (final b in bars) {
      if (b.value > maxVal) maxVal = b.value;
    }
    if (maxVal == 0) maxVal = 1;

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
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  summaryBadge,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 20),

          // Bar Chart Content Area
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                final ratio = (bar.value / maxVal).clamp(0.05, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Top Value Text
                        Text(
                          bar.displayValue,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: bar.isHighlighted ? iconColor : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Bar Column
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: ratio,
                              widthFactor: isMobile ? 0.6 : 0.45,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: bar.gradient,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: bar.gradient.colors.first.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Bottom X-axis label
                        SizedBox(
                          height: 28,
                          child: Text(
                            bar.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: bar.isHighlighted ? FontWeight.w700 : FontWeight.w500,
                              color: bar.isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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

  Widget _buildMyPageStats(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (width >= 1100) {
          crossAxisCount = 5;
          childAspectRatio = 1.75;
        } else if (width >= 750) {
          crossAxisCount = 3;
          childAspectRatio = 2.2;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 1.7;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Enquiry',
              '0',
              const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
              Icons.help_outline,
            ),
            _buildStatCard(
              'Payment',
              '0',
              const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
              Icons.account_balance_wallet_outlined,
            ),
            _buildStatCard(
              'Completed Samples',
              '${_getSampleCount('Complete')}',
              const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              Icons.check_circle_outline,
            ),
            _buildStatCard(
              'Result Due Samples',
              '${_getResultDueCount()}',
              const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              Icons.hourglass_top_outlined,
            ),
            _buildStatCard(
              'Sending Due Samples',
              '${_getSendingDueCount()}',
              const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
              Icons.local_shipping_outlined,
            ),
          ],
        );
      },
    );
  }

  int _getSampleCount(String keyword) {
    return _sampleController.samples.where((s) => s.sampleStatus.toLowerCase().contains(keyword.toLowerCase())).length;
  }

  int _getResultDueCount() {
    return _sampleController.samples.where((s) {
      final st = s.sampleStatus.toLowerCase();
      return st.contains('sampling') || st.contains('received') || st.contains('progress') || st.contains('due');
    }).length;
  }

  int _getSendingDueCount() {
    return _sampleController.samples.where((s) {
      final st = s.sampleStatus.toLowerCase();
      return st.contains('pending') || st.contains('hold') || st.contains('send') || st.contains('dispatch');
    }).length;
  }

  Widget _buildStatCard(String label, String value, LinearGradient gradient, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.92),
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
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
                  items: ['All', 'In Progress', 'Completed', 'Pending', 'Hold'].map((st) {
                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
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
              items: ['All', 'In Progress', 'Completed', 'Pending', 'Hold'].map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Text('Status: $st', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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

class _BarData {
  final String label;
  final double value;
  final String displayValue;
  final LinearGradient gradient;
  final bool isHighlighted;

  _BarData({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.gradient,
    this.isHighlighted = false,
  });
}

