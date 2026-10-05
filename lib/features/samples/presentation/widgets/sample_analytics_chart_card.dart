import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sample_analytics_model.dart';

/// Enterprise 3D Volumetric Stacked Analytics Chart Card
/// Features:
/// - Custom 3D isometric stacked cuboid blocks with extruded volumetric depth
/// - Staggered wave entrance animation with organic physics easing
/// - True multi-segment stacking (Completed -> Pending -> Custom)
/// - Top 3D glossy diamond cap facet with specular glint
/// - Inter-segment 3D bevel seams and glowing ground neon light pools
/// - Architectural isometric grid floor & wireframe tracks
/// - Zero-overflow responsive HUD tooltip and micro-typography
class SampleAnalyticsChartCard extends StatefulWidget {
  final List<MonthlySampleAnalytics> data;
  final bool isMobile;
  final void Function(MonthlySampleAnalytics item, String status)? onMonthTap;

  const SampleAnalyticsChartCard({
    super.key,
    required this.data,
    required this.isMobile,
    this.onMonthTap,
  });

  @override
  State<SampleAnalyticsChartCard> createState() => _SampleAnalyticsChartCardState();
}

class _SampleAnalyticsChartCardState extends State<SampleAnalyticsChartCard>
    with SingleTickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _animController;
  late Animation<double> _growthAnim;

  // Curated 3D segment gradients:
  // 0: Lush Emerald Green (Completed)
  // 1: Rich Golden Amber (Pending)
  // 2: Royal Sapphire Blue
  // 3: Hot Coral / Crimson
  // 4: Electric Violet
  // 5: Deep Teal
  static const List<LinearGradient> _segmentGradients = [
    LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF047857)], // Completed (Emerald)
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Pending (Amber)
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Royal Blue
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFF43F5E), Color(0xFFBE123C)], // Hot Coral
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Electric Violet
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF0D9488), Color(0xFF0F766E)], // Deep Teal
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _growthAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant SampleAnalyticsChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _maxVal {
    int max = 0;
    for (final item in widget.data) {
      final customSum = item.customSeries.values.fold<int>(0, (a, b) => a + b);
      final stacked = item.completed + item.pending + customSum;
      final val = stacked > 0 ? stacked : item.total;
      if (val > max) max = val;
    }
    return max > 0 ? max : 5;
  }

  int get _overallTotal {
    int sum = 0;
    for (final item in widget.data) {
      final customSum = item.customSeries.values.fold<int>(0, (a, b) => a + b);
      final stacked = item.completed + item.pending + customSum;
      sum += (item.total > 0 ? item.total : stacked);
    }
    return sum;
  }

  int get _overallCompleted {
    int sum = 0;
    for (final item in widget.data) {
      sum += item.completed;
    }
    return sum;
  }

  int get _overallPending {
    int sum = 0;
    for (final item in widget.data) {
      sum += item.pending;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = _maxVal.toDouble();
    final hoveredMonth = (_hoveredIndex != null && _hoveredIndex! < widget.data.length)
        ? widget.data[_hoveredIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(
            alpha: _hoveredIndex != null ? 0.38 : 0.18,
          ),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(
              alpha: _hoveredIndex != null ? 0.14 : 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with 3D Emblem, Title, Subtitle, and Live Badge
          _buildHeader(),
          const SizedBox(height: 14),

          // Laser Horizon Divider with 3D Depth
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.55),
                  const Color(0xFF6366F1).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Responsive 4D Floating HUD Tooltip Box (Zero Overflow Protected)
          _buildHUDTooltipBox(hoveredMonth),
          const SizedBox(height: 12),

          // 3. 3D Stacked Isometric Pillars & Floor Grid Canvas
          SizedBox(
            height: widget.isMobile ? 205 : 230,
            child: AnimatedBuilder(
              animation: _growthAnim,
              builder: (context, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 3D Perspective Floor Grid Platform
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ThreeDStackedGridPainter(maxVal: maxVal),
                      ),
                    ),

                    // 12-Month Columns with Staggered 3D Isometric Stacked Cuboids
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: widget.data.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final monthItem = entry.value;
                          final isHovered = _hoveredIndex == idx;

                          // Staggered wave animation curve per month
                          final numItems = math.max(1, widget.data.length);
                          final startOffset = (idx / numItems) * 0.35;
                          final rawProgress = ((_growthAnim.value - startOffset) / (1.0 - startOffset)).clamp(0.0, 1.0);
                          final staggeredProgress = Curves.easeOutBack.transform(rawProgress);

                          return Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _hoveredIndex = idx),
                              onExit: (_) => setState(() {
                                if (_hoveredIndex == idx) _hoveredIndex = null;
                              }),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (details) {
                                  final dy = details.localPosition.dy;
                                  final h = widget.isMobile ? 205.0 : 230.0;
                                  final dyFraction = (dy / h).clamp(0.0, 1.0);
                                  final status = _resolveColumnStatus(monthItem, dyFraction);
                                  widget.onMonthTap?.call(monthItem, status);
                                },
                                child: _buildMonthTrackColumn(
                                  item: monthItem,
                                  maxVal: maxVal,
                                  isHovered: isHovered,
                                  animProgress: staggeredProgress,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // 4. Interactive 3D Legend Capsule Chips
          _buildLegendRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // 3D Holographic Icon Orb
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFF6366F1).withValues(alpha: 0.25),
                      const Color(0xFF6366F1).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.stacked_bar_chart_rounded, color: Color(0xFF6366F1), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Sample Analytics',
                            style: GoogleFonts.montserrat(
                              fontSize: widget.isMobile ? 15 : 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '3D STACKED',
                            style: GoogleFonts.montserrat(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4F46E5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monthly Stacked Progression: Completed & Pending',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // 3D Total Summary Capsule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Total: $_overallTotal',
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4338CA),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Responsive Zero-Overflow HUD Tooltip Box
  Widget _buildHUDTooltipBox(MonthlySampleAnalytics? hovered) {
    if (hovered != null) {
      final customSum = hovered.customSeries.values.fold<int>(0, (a, b) => a + b);
      final effectiveTotal = (hovered.completed + hovered.pending + customSum) > 0
          ? (hovered.completed + hovered.pending + customSum)
          : hovered.total;
      final completionPct = effectiveTotal > 0
          ? ((hovered.completed / effectiveTotal) * 100).toStringAsFixed(0)
          : '0';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B0F19), Color(0xFF172033)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Month Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF818CF8), size: 13),
                  const SizedBox(width: 5),
                  Text(
                    hovered.month,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Scrollable / Flexible breakdown chips to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildHUDItem(
                      'Total',
                      '$effectiveTotal',
                      Colors.white,
                      onTap: () => widget.onMonthTap?.call(hovered, 'All'),
                    ),
                    const SizedBox(width: 10),
                    _buildHUDItem(
                      'Completed',
                      '${hovered.completed}',
                      const Color(0xFF10B981),
                      onTap: () => widget.onMonthTap?.call(hovered, 'Completed'),
                    ),
                    const SizedBox(width: 10),
                    _buildHUDItem(
                      'Pending',
                      '${hovered.pending}',
                      const Color(0xFFF59E0B),
                      onTap: () => widget.onMonthTap?.call(hovered, 'Pending'),
                    ),
                    ...hovered.customSeries.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _buildHUDItem(
                          e.key,
                          '${e.value}',
                          const Color(0xFF38BDF8),
                          onTap: () => widget.onMonthTap?.call(hovered, e.key),
                        ),
                      );
                    }),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$completionPct% Done',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_downward_rounded, size: 10, color: Color(0xFFA5B4FC)),
                          const SizedBox(width: 3),
                          Text(
                            'Tap to drill down',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFFA5B4FC),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default static HUD banner (guaranteed zero overflow)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hover to inspect or tap any month to drill down details',
              style: GoogleFonts.montserrat(
                fontSize: widget.isMobile ? 10 : 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFC7D2FE),
                width: 0.8,
              ),
            ),
            child: Text(
              '${widget.data.length} Months Tracked',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4338CA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveColumnStatus(MonthlySampleAnalytics item, double dyFraction) {
    if (item.completed > 0 && item.pending == 0) return 'Completed';
    if (item.pending > 0 && item.completed == 0) return 'Pending';
    if (item.completed == 0 && item.pending == 0) {
      if (item.customSeries.isNotEmpty) return item.customSeries.keys.first;
      return 'All';
    }
    final total = item.completed + item.pending;
    final completedFraction = item.completed / total;
    if (dyFraction >= (1.0 - completedFraction)) {
      return 'Completed';
    } else {
      return 'Pending';
    }
  }

  Widget _buildHUDItem(String label, String value, Color color, {VoidCallback? onTap}) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.montserrat(color: const Color(0xFF94A3B8), fontSize: 10.5),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: row,
        ),
      );
    }
    return row;
  }

  /// Month column with floating badge, 3D volumetric stacked cuboid, and month label
  Widget _buildMonthTrackColumn({
    required MonthlySampleAnalytics item,
    required double maxVal,
    required bool isHovered,
    required double animProgress,
  }) {
    // 3D segments collection:
    // Segment 0: Completed (Emerald)
    // Segment 1: Pending (Amber)
    // Segment 2+: Custom
    final List<({String label, int value, LinearGradient gradient})> segments = [];

    if (item.completed > 0) {
      segments.add((
        label: 'Completed',
        value: item.completed,
        gradient: _segmentGradients[0],
      ));
    }

    if (item.pending > 0) {
      segments.add((
        label: 'Pending',
        value: item.pending,
        gradient: _segmentGradients[1],
      ));
    }

    int customIdx = 2;
    for (final entry in item.customSeries.entries) {
      if (entry.value > 0) {
        segments.add((
          label: entry.key,
          value: entry.value,
          gradient: _segmentGradients[customIdx % _segmentGradients.length],
        ));
        customIdx++;
      }
    }

    if (segments.isEmpty && item.total > 0) {
      segments.add((
        label: 'Total',
        value: item.total,
        gradient: _segmentGradients[2],
      ));
    }

    final sumSegments = segments.fold<int>(0, (sum, s) => sum + s.value);
    final effectiveTotal = sumSegments > 0 ? sumSegments : item.total;
    final hasData = effectiveTotal > 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 2 : 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 1. Sleek Floating 3D Micro-Capsule for Total Count
          Container(
            height: 22,
            alignment: Alignment.center,
            child: hasData
                ? AnimatedOpacity(
                    opacity: animProgress > 0.15 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 180),
                      offset: Offset(0, isHovered ? -0.15 : 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isHovered ? const Color(0xFF4338CA) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isHovered ? const Color(0xFF818CF8) : const Color(0xFF334155),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isHovered ? const Color(0xFF6366F1) : Colors.black)
                                  .withValues(alpha: isHovered ? 0.45 : 0.2),
                              blurRadius: isHovered ? 6 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$effectiveTotal',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 4),

          // 2. 3D Volumetric Isometric Stacked Pillar Body with Interactive Hover Lift
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                offset: Offset(0, isHovered ? -0.05 : 0),
                child: SizedBox(
                  width: widget.isMobile ? 18.0 : 26.0,
                  child: CustomPaint(
                    painter: _ThreeDStackedPillarPainter(
                      segments: segments,
                      total: effectiveTotal,
                      maxVal: maxVal,
                      isHovered: isHovered,
                      animProgress: animProgress,
                      isMobile: widget.isMobile,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 3. Bottom Month Axis Pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? const Color(0xFF4338CA).withValues(alpha: 0.15)
                  : (hasData ? const Color(0xFFEEF2FF) : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isHovered
                    ? const Color(0xFF6366F1)
                    : (hasData ? const Color(0xFFC7D2FE) : Colors.transparent),
                width: 1,
              ),
            ),
            child: Text(
              item.shortMonth,
              style: GoogleFonts.montserrat(
                fontSize: widget.isMobile ? 9 : 10.5,
                fontWeight: hasData || isHovered ? FontWeight.w800 : FontWeight.w600,
                color: isHovered
                    ? const Color(0xFF4338CA)
                    : (hasData ? const Color(0xFF3730A3) : AppColors.textSecondary),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow() {
    final latestItem = widget.data.isNotEmpty ? widget.data.last : null;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendChip(
          'Completed',
          '$_overallCompleted',
          const Color(0xFF047857),
          const Color(0xFF10B981),
          const Color(0xFFD1FAE5),
          onTap: latestItem != null ? () => widget.onMonthTap?.call(latestItem, 'Completed') : null,
        ),
        _buildLegendChip(
          'Pending',
          '$_overallPending',
          const Color(0xFFB45309),
          const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7),
          onTap: latestItem != null ? () => widget.onMonthTap?.call(latestItem, 'Pending') : null,
        ),
        _buildLegendChip(
          'Total Samples',
          '$_overallTotal',
          const Color(0xFF4338CA),
          const Color(0xFF6366F1),
          const Color(0xFFEEF2FF),
          onTap: latestItem != null ? () => widget.onMonthTap?.call(latestItem, 'All') : null,
        ),
      ],
    );
  }

  Widget _buildLegendChip(String label, String value, Color textColor, Color dotColor, Color bgColor, {VoidCallback? onTap}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: dotColor.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: chip,
      );
    }
    return chip;
  }
}

/// 3D Perspective Floor Grid Platform Painter
class _ThreeDStackedGridPainter extends CustomPainter {
  final double maxVal;

  _ThreeDStackedGridPainter({required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height - 24;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.75)
      ..strokeWidth = 1.0;

    const lines = 4;
    for (int i = 0; i <= lines; i++) {
      final y = h * (i / lines);
      _drawDashedLine(canvas, Offset(0, y), Offset(w, y), gridPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(math.min(startX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeDStackedGridPainter oldDelegate) =>
      oldDelegate.maxVal != maxVal;
}

/// Custom Painter for 3D Isometric Stacked Cuboid Pillars
class _ThreeDStackedPillarPainter extends CustomPainter {
  final List<({String label, int value, LinearGradient gradient})> segments;
  final int total;
  final double maxVal;
  final bool isHovered;
  final double animProgress;
  final bool isMobile;

  _ThreeDStackedPillarPainter({
    required this.segments,
    required this.total,
    required this.maxVal,
    required this.isHovered,
    required this.animProgress,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double w = size.width;
    final double h = size.height;

    // 3D Isometric Perspective Depths
    final double depthX = math.min(6.0, w * 0.24);
    final double depthY = math.min(6.0, h * 0.12);

    final bool hasData = total > 0 && segments.isNotEmpty;

    // 1. Empty Month Architectural Wireframe Track
    if (!hasData) {
      _drawEmptyTrack(canvas, w, h, depthX, depthY);
      return;
    }

    // 2. Active Month: 3D Stacked Volumetric Cuboids
    final dominantColor = segments.first.gradient.colors.first;

    // A. 3D Radial Neon Light Pool on Floor
    final glowPaint = Paint()
      ..color = dominantColor.withValues(alpha: isHovered ? 0.50 : 0.20)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHovered ? 10 : 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h + 2),
        width: w + (isHovered ? 10 : 4),
        height: 8,
      ),
      glowPaint,
    );

    // B. 3D Pedestal Base Plate
    final pedestalPath = Path()
      ..moveTo(-1, h)
      ..lineTo(depthX, h - depthY / 2)
      ..lineTo(w + 1, h - depthY / 2)
      ..lineTo(w - depthX + 1, h)
      ..close();

    final pedestalPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pedestalPath, pedestalPaint);

    // C. Calculate Heights for Each Stacked Segment
    final double maxAvailableHeight = h - depthY - 4;
    final double totalRatio = (total / maxVal).clamp(0.05, 1.0) * animProgress;
    final double currentTotalHeight = maxAvailableHeight * totalRatio;

    // Segments ordered from bottom to top:
    // segments[0] = Completed (bottom)
    // segments[1] = Pending (top)
    // segments[2+] = Custom (further top)
    double currentYBottom = h;

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final isTopSegment = (i == segments.length - 1);
      final segRatio = (seg.value / total);
      double segHeight = currentTotalHeight * segRatio;
      if (segHeight < 4.0 && seg.value > 0) segHeight = 4.0;

      final currentYTop = currentYBottom - segHeight;
      final segGradient = seg.gradient;
      final baseColorPrimary = segGradient.colors.first;
      final baseColorSecondary = segGradient.colors.last;

      // 3D Shading
      final sideColor = Color.lerp(baseColorSecondary, const Color(0xFF090D16), 0.42)!;
      final topColor = Color.lerp(baseColorPrimary, Colors.white, 0.52)!;

      // --- 1. FRONT FACE ---
      final frontRect = Rect.fromLTRB(0, currentYTop, w - depthX, currentYBottom);
      final frontPaint = Paint()..shader = segGradient.createShader(frontRect);

      final frontRRect = RRect.fromRectAndCorners(
        frontRect,
        bottomLeft: (i == 0) ? const Radius.circular(2.5) : Radius.zero,
        bottomRight: (i == 0) ? const Radius.circular(2.5) : Radius.zero,
        topLeft: isTopSegment ? const Radius.circular(2.5) : Radius.zero,
        topRight: isTopSegment ? const Radius.circular(2.5) : Radius.zero,
      );
      canvas.drawRRect(frontRRect, frontPaint);

      // Internal Holographic Core Shine
      final corePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: isHovered ? 0.38 : 0.16),
            Colors.white.withValues(alpha: 0.03),
          ],
        ).createShader(frontRect);

      canvas.drawRect(
        Rect.fromLTWH((w - depthX) * 0.35, currentYTop, (w - depthX) * 0.30, segHeight),
        corePaint,
      );

      // In-Segment Value Text (Safely Clamped to Prevent Overflow "OW")
      if (segHeight >= 14.0 && (w - depthX) >= 12.0) {
        final textSpan = TextSpan(
          text: '${seg.value}',
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 8.5 : 9.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 2,
              ),
            ],
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            ((w - depthX) - textPainter.width) / 2,
            currentYTop + (segHeight - textPainter.height) / 2,
          ),
        );
      }

      // --- 2. RIGHT EXTRUDED 3D FACE ---
      final rightPath = Path()
        ..moveTo(w - depthX, currentYTop)
        ..lineTo(w, currentYTop - depthY)
        ..lineTo(w, currentYBottom - depthY)
        ..lineTo(w - depthX, currentYBottom)
        ..close();

      final rightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseColorPrimary, Colors.black, 0.25)!,
            sideColor,
          ],
        ).createShader(Rect.fromLTRB(w - depthX, currentYTop - depthY, w, currentYBottom));

      canvas.drawPath(rightPath, rightPaint);

      // --- 3. INTER-SEGMENT 3D BEVEL SEAM ---
      if (!isTopSegment) {
        // Front seam
        final seamFrontPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(0, currentYTop),
          Offset(w - depthX, currentYTop),
          seamFrontPaint,
        );

        // Side shadow seam
        final seamSidePaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.45)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(w - depthX, currentYTop),
          Offset(w, currentYTop - depthY),
          seamSidePaint,
        );
      }

      // --- 4. TOP 3D CAP (ONLY FOR TOP-MOST SEGMENT) ---
      if (isTopSegment) {
        final topPath = Path()
          ..moveTo(0, currentYTop)
          ..lineTo(depthX, currentYTop - depthY)
          ..lineTo(w, currentYTop - depthY)
          ..lineTo(w - depthX, currentYTop)
          ..close();

        final topPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              topColor,
              baseColorPrimary,
            ],
          ).createShader(Rect.fromLTRB(0, currentYTop - depthY, w, currentYTop));

        canvas.drawPath(topPath, topPaint);

        // Laser Bevel Edge Highlight
        final edgeHighlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: isHovered ? 0.85 : 0.40)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(0, currentYTop),
          Offset(w - depthX, currentYTop),
          edgeHighlightPaint,
        );
        canvas.drawLine(
          Offset(w - depthX, currentYTop),
          Offset(w, currentYTop - depthY),
          edgeHighlightPaint,
        );

        // Top-Left Specular Flare
        if (isHovered) {
          final flarePaint = Paint()
            ..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          canvas.drawCircle(Offset(depthX * 0.7, currentYTop - depthY * 0.5), 1.8, flarePaint);
        }
      }

      // Step up to the next segment in the stack
      currentYBottom = currentYTop;
    }
  }

  void _drawEmptyTrack(Canvas canvas, double w, double h, double depthX, double depthY) {
    // Subtle architectural 3D track
    final trackRect = Rect.fromLTRB(0, depthY, w - depthX, h);
    final trackPaint = Paint()
      ..color = isHovered
          ? const Color(0xFF6366F1).withValues(alpha: 0.08)
          : const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isHovered
          ? const Color(0xFF6366F1).withValues(alpha: 0.35)
          : const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(trackRect, const Radius.circular(5));
    canvas.drawRRect(rrect, trackPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Resting baseline notch
    final notchPaint = Paint()
      ..color = isHovered ? const Color(0xFF818CF8) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final notchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset((w - depthX) / 2, h - 3),
        width: (w - depthX) * 0.55,
        height: 3,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(notchRect, notchPaint);
  }

  @override
  bool shouldRepaint(covariant _ThreeDStackedPillarPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.total != total ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.animProgress != animProgress;
  }
}
