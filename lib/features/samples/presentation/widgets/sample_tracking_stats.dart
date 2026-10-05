import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/sample_controller.dart';
import 'three_d_stat_card.dart';

class SampleTrackingStats extends StatelessWidget {
  final SampleController controller;
  final bool isMobile;
  final void Function(String label, String xValue)? onDrillDown;

  const SampleTrackingStats({
    super.key,
    required this.controller,
    required this.isMobile,
    this.onDrillDown,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilter = controller.activeMetricFilter;
    final widgets = controller.sampleWidgets;

    // Use API widgets if available, otherwise fallback to computed metric cards
    final List<({
      String label,
      String value,
      LinearGradient gradient,
      IconData icon,
      String metricKey,
      String xValue,
      String drillDownLabel,
    })> cards = [];

    final defaultDashboardLabel = controller.sampleStatusDashboard?.chartName.isNotEmpty == true
        ? controller.sampleStatusDashboard!.chartName
        : 'Sample Status Dashboard';

    if (widgets.isNotEmpty) {
      for (final w in widgets) {
        final conf = _getCardConfig(w.name, '${w.value}', w.label);
        final xVal = (w.xValue != null && w.xValue!.trim().isNotEmpty)
            ? w.xValue!.trim()
            : _resolveStatus(null, w.name, conf.metricKey);
        final dLabel = (w.label != null && w.label!.trim().isNotEmpty)
            ? w.label!.trim()
            : defaultDashboardLabel;
        cards.add((
          label: conf.label,
          value: conf.value,
          gradient: conf.gradient,
          icon: conf.icon,
          metricKey: conf.metricKey,
          xValue: xVal,
          drillDownLabel: dLabel,
        ));
      }
    } else {
      cards.addAll([
        (
          label: 'Pending Samples',
          value: '${controller.pendingSamplesCount}',
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.pending_actions_rounded,
          metricKey: 'pending',
          xValue: 'Pending',
          drillDownLabel: defaultDashboardLabel,
        ),
        (
          label: 'Overdue Samples',
          value: '${controller.overdueSamplesCount}',
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.alarm_on_rounded,
          metricKey: 'overdue',
          xValue: 'Overdue',
          drillDownLabel: defaultDashboardLabel,
        ),
        (
          label: 'Deviation Samples',
          value: '${controller.deviationSamplesCount}',
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.alt_route_rounded,
          metricKey: 'deviation',
          xValue: 'Deviation',
          drillDownLabel: defaultDashboardLabel,
        ),
        (
          label: 'Reported Samples',
          value: '${controller.reportedSamplesCount}',
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.assignment_turned_in_rounded,
          metricKey: 'reported',
          xValue: 'Reported',
          drillDownLabel: defaultDashboardLabel,
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1050;

            final childAspectRatio = isNarrow
                ? 1.72
                : (isTablet ? 1.95 : 2.25);

            final crossAxisCount = isNarrow ? 2 : (cards.length > 4 ? (isTablet ? 3 : cards.length.clamp(2, 5)) : 4);

            return GridView.builder(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildKpiCard(
                  label: card.label,
                  value: card.value,
                  gradient: card.gradient,
                  icon: card.icon,
                  metricKey: card.metricKey,
                  xValue: card.xValue,
                  drillDownLabel: card.drillDownLabel,
                  isActive: activeFilter == card.metricKey,
                  context: context,
                );
              },
            );
          },
        ),

        // Active Quick Filter Banner if any KPI card is selected
        if (activeFilter != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filtering grid list by: ${_getFilterTitle(activeFilter)} (${controller.totalRecords} matching)',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => controller.setMetricFilter(null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear Filter',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  ({String label, String value, LinearGradient gradient, IconData icon, String metricKey}) _getCardConfig(
    String name,
    String value,
    String? label,
  ) {
    final lower = name.toLowerCase();
    final displayLabel = (label != null && label.isNotEmpty) ? label : name;

    if (lower.contains('pend')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.pending_actions_rounded,
        metricKey: 'pending',
      );
    } else if (lower.contains('overdue') || lower.contains('due')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.alarm_on_rounded,
        metricKey: 'overdue',
      );
    } else if (lower.contains('dev') || lower.contains('hold') || lower.contains('oos')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.alt_route_rounded,
        metricKey: 'deviation',
      );
    } else if (lower.contains('report') || lower.contains('comp') || lower.contains('release')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.assignment_turned_in_rounded,
        metricKey: 'reported',
      );
    } else if (lower.contains('enquiry') || lower.contains('inquiry')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.contact_support_rounded,
        metricKey: lower,
      );
    } else if (lower.contains('order')) {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.receipt_long_rounded,
        metricKey: lower,
      );
    } else {
      return (
        label: displayLabel,
        value: value,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.insights_rounded,
        metricKey: lower,
      );
    }
  }

  String _resolveStatus(String? xVal, String name, String metricKey) {
    if (xVal != null && xVal.trim().isNotEmpty) {
      final trimmed = xVal.trim();
      final isMonth = RegExp(r'^(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|\d{4})', caseSensitive: false).hasMatch(trimmed);
      if (!isMonth) {
        return trimmed;
      }
    }
    final lower = name.toLowerCase();
    if (lower.contains('pend')) return 'Pending';
    if (lower.contains('overdue') || lower.contains('due')) return 'Overdue';
    if (lower.contains('dev') || lower.contains('hold') || lower.contains('oos')) return 'Deviation';
    if (lower.contains('report') || lower.contains('comp') || lower.contains('release')) return 'Reported';
    return name.isNotEmpty ? name : metricKey;
  }

  String _getFilterTitle(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending Samples';
      case 'overdue':
        return 'Overdue Samples';
      case 'deviation':
        return 'Deviation Samples';
      case 'reported':
        return 'Reported Samples';
      default:
        return filter[0].toUpperCase() + filter.substring(1);
    }
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required LinearGradient gradient,
    required IconData icon,
    required String metricKey,
    required String xValue,
    required String drillDownLabel,
    required bool isActive,
    required BuildContext context,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Tooltip(
            message: 'Click to drill down into $label records',
            textStyle: GoogleFonts.montserrat(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ThreeDStatCard(
              label: label,
              value: value,
              gradient: gradient,
              icon: icon,
              onTap: () {
                if (onDrillDown != null) {
                  onDrillDown!(drillDownLabel, xValue);
                } else {
                  controller.setMetricFilter(metricKey);
                }
              },
            ),
          ),
          if (isActive)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: gradient.colors.first,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
