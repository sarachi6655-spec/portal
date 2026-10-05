import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BarChartItem {
  final String label;
  final String? xValue;
  final double value;
  final String displayValue;
  final LinearGradient gradient;
  final bool isHighlighted;

  const BarChartItem({
    required this.label,
    this.xValue,
    required this.value,
    required this.displayValue,
    required this.gradient,
    this.isHighlighted = false,
  });
}

class ThreeDBarChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String summaryBadge;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final List<BarChartItem> bars;
  final bool isMobile;
  final double totalValue;
  final String unit;

  const ThreeDBarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.summaryBadge,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.bars,
    required this.isMobile,
    this.totalValue = 0,
    this.unit = '',
    this.onBarTap,
  });

  final void Function(BarChartItem item)? onBarTap;

  @override
  State<ThreeDBarChartCard> createState() => _ThreeDBarChartCardState();
}

class _ThreeDBarChartCardState extends State<ThreeDBarChartCard>
    with SingleTickerProviderStateMixin {
  int? _hoveredIndex;

  late AnimationController _growthAnimController;
  late Animation<double> _growthAnim;

  @override
  void initState() {
    super.initState();
    // One-shot entrance animation
    _growthAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _growthAnim = CurvedAnimation(
      parent: _growthAnimController,
      curve: Curves.easeOutCubic,
    );
    _growthAnimController.forward();
  }

  @override
  void didUpdateWidget(covariant ThreeDBarChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bars != widget.bars) {
      _growthAnimController.reset();
      _growthAnimController.forward();
    }
  }

  @override
  void dispose() {
    _growthAnimController.dispose();
    super.dispose();
  }

  double get _computedTotal {
    if (widget.totalValue > 0) return widget.totalValue;
    double sum = 0;
    for (final b in widget.bars) {
      sum += b.value;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final b in widget.bars) {
      if (b.value > maxVal) maxVal = b.value;
    }
    if (maxVal == 0) maxVal = 1;

    final total = _computedTotal;
    final hoveredBar = _hoveredIndex != null && _hoveredIndex! < widget.bars.length
        ? widget.bars[_hoveredIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.iconColor.withValues(
            alpha: _hoveredIndex != null ? 0.35 : 0.20,
          ),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: widget.iconColor.withValues(
              alpha: _hoveredIndex != null ? 0.14 : 0.06,
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
          // Header Section
          _buildHeader(hoveredBar, total),
          const SizedBox(height: 14),

          // 3D Laser Horizon Divider
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.iconColor.withValues(alpha: 0.5),
                  widget.iconColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 4D Floating HUD Tooltip Box (Zero Overflow Protected)
          _buildActiveHUDTooltipBox(hoveredBar, total),
          const SizedBox(height: 12),

          // 3D Cyber Platform & Pillars Canvas
          SizedBox(
            height: widget.isMobile ? 190 : 215,
            child: AnimatedBuilder(
              animation: _growthAnim,
              builder: (context, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 3D Perspective Floor Grid Platform
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ThreeDGridPlatformPainter(
                          maxVal: maxVal,
                          accentColor: widget.iconColor,
                        ),
                      ),
                    ),

                    // 3D Isometric Cyber Pillars
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: widget.bars.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final bar = entry.value;
                          final isHovered = _hoveredIndex == idx;
                          final ratio = (bar.value / maxVal).clamp(0.04, 1.0) *
                              _growthAnim.value;

                          return Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _hoveredIndex = idx),
                              onExit: (_) => setState(() {
                                if (_hoveredIndex == idx) _hoveredIndex = null;
                              }),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _hoveredIndex = idx;
                                  });
                                  widget.onBarTap?.call(bar);
                                },
                                child: _buildCyberPillarColumn(
                                  bar: bar,
                                  ratio: ratio,
                                  isHovered: isHovered,
                                  isMobile: widget.isMobile,
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

          // Interactive 3D Legend Capsule Chips
          _buildLegendRow(),
        ],
      ),
    );
  }

  // Header with Live Sync Status
  Widget _buildHeader(BarChartItem? hoveredBar, double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // 3D Hexagon/Orb Icon Emblem
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      widget.iconColor.withValues(alpha: 0.2),
                      widget.iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
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
                            widget.title,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF059669),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
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

        // Live Total Badge with Neon Rim
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: hoveredBar != null
                ? hoveredBar.gradient.colors.first.withValues(alpha: 0.15)
                : widget.badgeBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hoveredBar != null
                  ? hoveredBar.gradient.colors.first.withValues(alpha: 0.6)
                  : widget.iconColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              if (hoveredBar != null)
                BoxShadow(
                  color: hoveredBar.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hoveredBar != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hoveredBar.gradient.colors.first,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                hoveredBar != null
                    ? '${hoveredBar.label}: ${hoveredBar.displayValue}'
                    : widget.summaryBadge,
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: hoveredBar != null
                      ? hoveredBar.gradient.colors.first
                      : widget.badgeTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4D Floating HUD Tooltip Box (Zero Overflow Protected)
  Widget _buildActiveHUDTooltipBox(BarChartItem? hoveredBar, double total) {
    if (hoveredBar == null) {
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.radar_rounded,
              size: 15,
              color: widget.iconColor.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hover or tap any 3D pillar to drill down details',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final percentVal = total > 0 ? (hoveredBar.value / total) : 0.0;
    final percentStr = (percentVal * 100).toStringAsFixed(1);
    final accentColor = hoveredBar.gradient.colors.first;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onBarTap?.call(hoveredBar),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF090D16),
                Color(0xFF131D2F),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.75),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          // Left: Dot + Series Name + Period Capsule (Wrapped to prevent overflow)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: hoveredBar.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    hoveredBar.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hoveredBar.xValue != null && hoveredBar.xValue!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      hoveredBar.xValue!,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Value + Visual Progress Meter + Percentage (Compact & No Overflow)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Count: ',
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                hoveredBar.displayValue,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),

              // Visual Mini Meter
              Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentVal.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: hoveredBar.gradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(color: accentColor, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Percentage Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '$percentStr%',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),

              // Interactive Drill-Down Chip
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Data',
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }

  // 3D Pillar Column with Hover Lift
  Widget _buildCyberPillarColumn({
    required BarChartItem bar,
    required double ratio,
    required bool isHovered,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Top Number Value
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 140),
            style: GoogleFonts.montserrat(
              fontSize: isHovered ? 13 : 11,
              fontWeight: isHovered ? FontWeight.w900 : FontWeight.w700,
              color: isHovered
                  ? bar.gradient.colors.first
                  : (bar.isHighlighted
                      ? widget.iconColor
                      : AppColors.textPrimary),
              shadows: isHovered
                  ? [
                      Shadow(
                        color: bar.gradient.colors.first.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              bar.displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),

          // 3D Cyber Pillar Body
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                offset: Offset(0, isHovered ? -0.05 : 0),
                child: FractionallySizedBox(
                  heightFactor: ratio,
                  widthFactor: isMobile ? 0.74 : 0.60,
                  child: CustomPaint(
                    painter: _ThreeDPillarPainter(
                      gradient: bar.gradient,
                      isHovered: isHovered,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bottom X-Axis Capsule Label
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? bar.gradient.colors.first.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isHovered
                    ? bar.gradient.colors.first.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                bar.xValue != null && bar.xValue!.isNotEmpty
                    ? '${bar.xValue}'
                    : bar.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: isMobile ? 9.5 : 10.5,
                  fontWeight: isHovered || bar.isHighlighted
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: isHovered
                      ? bar.gradient.colors.first
                      : (bar.isHighlighted
                          ? AppColors.textPrimary
                          : AppColors.textSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Legend Capsules Row
  Widget _buildLegendRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.bars.asMap().entries.map((entry) {
        final idx = entry.key;
        final bar = entry.value;
        final isHovered = _hoveredIndex == idx;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoveredIndex = idx),
          onExit: (_) => setState(() {
            if (_hoveredIndex == idx) _hoveredIndex = null;
          }),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _hoveredIndex = idx;
              });
              widget.onBarTap?.call(bar);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isHovered
                    ? bar.gradient.colors.first.withValues(alpha: 0.18)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered
                      ? bar.gradient.colors.first.withValues(alpha: 0.7)
                      : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: bar.gradient.colors.first.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: bar.gradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bar.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: isHovered ? FontWeight.w800 : FontWeight.w500,
                      color: isHovered
                          ? bar.gradient.colors.first
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 3D Perspective Floor Grid Platform Painter
class _ThreeDGridPlatformPainter extends CustomPainter {
  final double maxVal;
  final Color accentColor;

  _ThreeDGridPlatformPainter({
    required this.maxVal,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height - 34; // leave room for X-axis labels

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.75)
      ..strokeWidth = 1.0;

    final nodePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // 4 Horizontal Perspective Grid Planes
    for (int i = 0; i < 4; i++) {
      final y = h * (i / 3.0);
      final levelVal = (maxVal * (1.0 - i / 3.0)).round();

      canvas.drawLine(Offset(28, y), Offset(w, y), gridPaint);

      // Node dot on left axis
      canvas.drawCircle(Offset(28, y), 2.0, nodePaint);

      // Level text
      final textSpan = TextSpan(
        text: '$levelVal',
        style: GoogleFonts.montserrat(
          fontSize: 9.5,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(24 - textPainter.width, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeDGridPlatformPainter oldDelegate) {
    return oldDelegate.maxVal != maxVal || oldDelegate.accentColor != accentColor;
  }
}

// Custom Painter for 3D Cyber Isometric Bar Pillars
class _ThreeDPillarPainter extends CustomPainter {
  final LinearGradient gradient;
  final bool isHovered;

  _ThreeDPillarPainter({
    required this.gradient,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double w = size.width;
    final double h = size.height;

    // 3D Perspective Extrusion Depths
    final double depthX = math.min(7.0, w * 0.24);
    final double depthY = math.min(7.0, h * 0.16);

    final baseColorPrimary = gradient.colors.first;
    final baseColorSecondary = gradient.colors.last;

    // Derived 3D Shading
    final sideColor = Color.lerp(baseColorSecondary, Colors.black, 0.38)!;
    final topColor = Color.lerp(baseColorPrimary, Colors.white, 0.50)!;

    // 1. Base 3D Radial Neon Light Pool
    final glowPaint = Paint()
      ..color = baseColorPrimary.withValues(alpha: isHovered ? 0.50 : 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHovered ? 10 : 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h + 3),
        width: w + (isHovered ? 8 : 4),
        height: 10,
      ),
      glowPaint,
    );

    // 2. 3D Pedestal Platform Base Plate
    final pedestalPath = Path()
      ..moveTo(-2, h)
      ..lineTo(depthX, h - depthY / 2)
      ..lineTo(w + 2, h - depthY / 2)
      ..lineTo(w - depthX + 2, h)
      ..close();

    final pedestalPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pedestalPath, pedestalPaint);

    // 3. Front Face (Main Energy Gradient)
    final frontRect = Rect.fromLTRB(0, depthY, w - depthX, h);
    final frontPaint = Paint()..shader = gradient.createShader(frontRect);

    final frontRRect = RRect.fromRectAndCorners(
      frontRect,
      topLeft: const Radius.circular(3),
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );
    canvas.drawRRect(frontRRect, frontPaint);

    // Internal Holographic Light Beam Core
    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isHovered ? 0.40 : 0.18),
          Colors.white.withValues(alpha: 0.04),
        ],
      ).createShader(frontRect);

    canvas.drawRect(
      Rect.fromLTWH((w - depthX) * 0.35, depthY, (w - depthX) * 0.3, h - depthY),
      corePaint,
    );

    // 4. Right 3D Extruded Face (Shadowed Volumetric Depth)
    final rightPath = Path()
      ..moveTo(w - depthX, depthY)
      ..lineTo(w, 0)
      ..lineTo(w, h - depthY)
      ..lineTo(w - depthX, h)
      ..close();

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(baseColorPrimary, Colors.black, 0.22)!,
          sideColor,
        ],
      ).createShader(Rect.fromLTRB(w - depthX, 0, w, h));

    canvas.drawPath(rightPath, rightPaint);

    // 5. Top 3D Faceted Crystal Cap / Roof (Specular Glint)
    final topPath = Path()
      ..moveTo(0, depthY)
      ..lineTo(depthX, 0)
      ..lineTo(w, 0)
      ..lineTo(w - depthX, depthY)
      ..close();

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          topColor,
          baseColorPrimary,
        ],
      ).createShader(Rect.fromLTRB(0, 0, w, depthY));

    canvas.drawPath(topPath, topPaint);

    // 6. Laser Bevel Edge Highlights
    final edgeHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isHovered ? 0.70 : 0.30)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, depthY),
      Offset(w - depthX, depthY),
      edgeHighlightPaint,
    );
    canvas.drawLine(
      Offset(w - depthX, depthY),
      Offset(w, 0),
      edgeHighlightPaint,
    );

    // Top-Left Specular Star Flare
    if (isHovered) {
      final flarePaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(depthX * 0.7, depthY * 0.4), 2.0, flarePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeDPillarPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.isHovered != isHovered;
  }
}
