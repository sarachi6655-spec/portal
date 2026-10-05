import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/sample_controller.dart';
import '../../data/models/portal_drill_down_model.dart';
import 'sample_status_badge.dart';

class DrillDownGridSection extends StatefulWidget {
  final SampleController controller;
  final bool isMobile;
  final VoidCallback onBackToDashboard;
  final void Function(PortalDrillDownItemModel item) onInspectItem;

  final String sourceTitle;

  const DrillDownGridSection({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.onBackToDashboard,
    required this.onInspectItem,
    this.sourceTitle = 'My Page',
  });

  @override
  State<DrillDownGridSection> createState() => _DrillDownGridSectionState();
}

class _DrillDownGridSectionState extends State<DrillDownGridSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.drillDownSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isMobile = widget.isMobile;
    final label = controller.drillDownLabel ?? 'Dashboard';
    final xValue = controller.drillDownXValue ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Navigation Breadcrumb & Back Header
          _buildNavigationHeader(label, xValue, isMobile),

          const SizedBox(height: 18),

          // 2. Control Bar (Search + Rows Per Page + Refresh)
          _buildControlBar(isMobile),

          const SizedBox(height: 16),

          // 3. Main Content: Loading, Error, Empty, or Data Table
          if (controller.isDrillDownLoading)
            const SizedBox(
              height: 340,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 14),
                    Text(
                      'Loading drill-down details...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.drillDownError != null)
            _buildErrorState(controller.drillDownError!)
          else if (controller.drillDownItems.isEmpty)
            _buildEmptyState(label, xValue)
          else
            _buildDataTable(context),

          const SizedBox(height: 16),

          // 4. Pagination Footer
          _buildPaginationFooter(isMobile),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader(String label, String xValue, bool isMobile) {
    final total = widget.controller.totalDrillDownRecords;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Back Button
          ElevatedButton.icon(
            onPressed: widget.onBackToDashboard,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(isMobile ? 'Back' : 'Back to ${widget.sourceTitle}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Breadcrumbs & Status
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  widget.sourceTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (xValue.isNotEmpty) ...[
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7DD3FC)),
                    ),
                    child: Text(
                      xValue,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$total records',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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

  Widget _buildControlBar(bool isMobile) {
    return Row(
      children: [
        // Search Box
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => widget.controller.setDrillDownSearch(val),
              style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: isMobile ? 'Search drill-down records...' : 'Search order ref, category, salesperson, status, PO number...',
                hintStyle: GoogleFonts.montserrat(fontSize: 12.5, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          widget.controller.setDrillDownSearch('');
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Reload Button
        IconButton.outlined(
          onPressed: () {
            final l = widget.controller.drillDownLabel;
            final x = widget.controller.drillDownXValue;
            final y = widget.controller.drillDownYValue;
            if (l != null && x != null) {
              widget.controller.loadDrillDownData(label: l, xValue: x, yValue: y);
            }
          },
          tooltip: 'Refresh Data',
          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(11),
          ),
        ),
      ],
    );
  }

  List<String> _extractColumns(List<PortalDrillDownItemModel> items) {
    if (items.isEmpty) return [];

    const priorityKeys = [
      'OrderReference',
      'EnquiryReference',
      'EnquiryNo',
      'Hospital',
      'OrderCategory',
      'EnquiryType',
      'OrderStatus',
      'EnquiryStatus',
      'TotalValue',
      'TotalCost',
      'OrderValue',
      'TaxValue',
      'GrandTotal',
      'LocalValue',
      'BookingDate',
      'EnquiryDate',
      'PODate',
      'SalesPerson',
      'Branch',
      'ContactPerson',
      'PONo',
    ];

    final availableKeys = <String>{};
    for (final item in items) {
      availableKeys.addAll(item.rawJson.keys);
    }

    final orderedKeys = <String>[];
    for (final pk in priorityKeys) {
      if (availableKeys.contains(pk)) {
        orderedKeys.add(pk);
      }
    }

    for (final k in availableKeys) {
      if (!orderedKeys.contains(k) && k != 'ReferenceID') {
        orderedKeys.add(k);
      }
    }

    return orderedKeys.take(12).toList();
  }

  String _formatColumnHeader(String key) {
    if (key == 'OrderReference') return 'ORDER REF';
    if (key == 'EnquiryReference') return 'ENQUIRY REF';
    if (key == 'EnquiryNo') return 'ENQ NO';
    if (key == 'EnquiryType') return 'TYPE';
    if (key == 'OrderStatus' || key == 'EnquiryStatus') return 'STATUS';
    if (key == 'OrderCategory') return 'CATEGORY';
    if (key == 'PONo') return 'PO NO';

    final spaced = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return spaced.toUpperCase();
  }

  Widget _buildCellContent(PortalDrillDownItemModel item, String col) {
    final val = item.getValue(col);

    if (col.toLowerCase().contains('status')) {
      return SampleStatusBadge(status: val.isNotEmpty ? val : 'Active');
    }

    if (col.toLowerCase().contains('reference') || col == 'EnquiryNo') {
      return Text(
        val.isNotEmpty ? val : '-',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkBlue,
        ),
      );
    }

    if (col.toLowerCase().contains('total') || col.toLowerCase().contains('value') || col.toLowerCase().contains('cost')) {
      final currency = item.effectiveCurrency;
      final numVal = double.tryParse(val);
      final formatted = numVal != null ? '$currency ${numVal.toStringAsFixed(2)}' : (val.isNotEmpty ? '$currency $val' : '-');
      return Text(
        formatted,
        style: TextStyle(
          fontWeight: col.toLowerCase().contains('grand') || col.toLowerCase().contains('total') ? FontWeight.w700 : FontWeight.w500,
        ),
      );
    }

    if (col == 'SalesPerson' || col == 'Hospital' || col == 'Branch') {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          val.isNotEmpty ? val : '-',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Text(val.isNotEmpty ? val : '-');
  }

  Widget _buildDataTable(BuildContext context) {
    final startIndex = (widget.controller.drillDownPage - 1) * widget.controller.drillDownRowsPerPage;
    final items = widget.controller.drillDownItems;
    final columns = _extractColumns(items);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.hoverBg),
          headingTextStyle: GoogleFonts.montserrat(
            fontSize: 11.5,
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
          dataRowMaxHeight: 54,
          columns: [
            const DataColumn(label: Text('S.NO')),
            const DataColumn(label: Text('ACTION')),
            ...columns.map((c) => DataColumn(label: Text(_formatColumnHeader(c)))),
          ],
          rows: List<DataRow>.generate(items.length, (index) {
            final item = items[index];
            final sNo = startIndex + index + 1;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '$sNo',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataCell(
                  OutlinedButton.icon(
                    onPressed: () => widget.onInspectItem(item),
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
                ...columns.map((col) => DataCell(_buildCellContent(item, col))),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String label, String xValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              size: 44,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Drill-Down Data Found',
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            xValue.isNotEmpty ? 'No data was returned for "$label" with filter "$xValue".' : 'No data was returned for "$label".',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: widget.onBackToDashboard,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Dashboards'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load drill-down records',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  error,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final l = widget.controller.drillDownLabel;
              final x = widget.controller.drillDownXValue;
              final y = widget.controller.drillDownYValue;
              if (l != null && x != null) {
                widget.controller.loadDrillDownData(label: l, xValue: x, yValue: y);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(bool isMobile) {
    final controller = widget.controller;
    final total = controller.totalDrillDownRecords;
    final page = controller.drillDownPage;
    final rowsPerPage = controller.drillDownRowsPerPage;
    final totalPages = controller.totalDrillDownPages;

    final start = total == 0 ? 0 : (page - 1) * rowsPerPage + 1;
    final end = (page * rowsPerPage > total) ? total : page * rowsPerPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $start to $end of $total entries',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rows per page dropdown
            if (!isMobile) ...[
              Text(
                'Rows: ',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              DropdownButton<int>(
                value: rowsPerPage,
                underline: const SizedBox.shrink(),
                items: [10, 25, 50].map((r) {
                  return DropdownMenuItem<int>(
                    value: r,
                    child: Text('$r', style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.setDrillDownRowsPerPage(val);
                  }
                },
              ),
              const SizedBox(width: 14),
            ],

            // Previous Button
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: page > 1 ? () => controller.setDrillDownPage(page - 1) : null,
              color: AppColors.textPrimary,
              disabledColor: AppColors.textMuted,
            ),
            Text(
              '$page of $totalPages',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            // Next Button
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: page < totalPages ? () => controller.setDrillDownPage(page + 1) : null,
              color: AppColors.textPrimary,
              disabledColor: AppColors.textMuted,
            ),
          ],
        ),
      ],
    );
  }
}
