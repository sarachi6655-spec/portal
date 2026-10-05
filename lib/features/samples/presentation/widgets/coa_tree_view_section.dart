import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/coa_report_model.dart';
import '../controllers/sample_controller.dart';
import 'coa_pdf_preview_panel.dart';
import 'sample_status_badge.dart';

class CoaTreeViewSection extends StatefulWidget {
  final SampleController controller;
  final bool isMobile;
  final void Function(CoaSampleNodeModel node, CoaReportItemModel report)? onInspectCoa;
  final void Function(CoaSampleNodeModel node, CoaReportItemModel report)? onViewCoa;

  const CoaTreeViewSection({
    super.key,
    required this.controller,
    required this.isMobile,
    this.onInspectCoa,
    this.onViewCoa,
  });

  @override
  State<CoaTreeViewSection> createState() => _CoaTreeViewSectionState();
}

class _CoaTreeViewSectionState extends State<CoaTreeViewSection> {
  final TextEditingController _searchController = TextEditingController();
  CoaSampleNodeModel? _selectedPreviewNode;
  CoaReportItemModel? _selectedPreviewReport;
  bool _isFullscreenPreview = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.coaSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectReport(CoaSampleNodeModel node, CoaReportItemModel report) {
    if (widget.onViewCoa != null) {
      widget.onViewCoa!(node, report);
      return;
    }

    if (widget.isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.92,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CoaPdfPreviewPanel(
              node: node,
              report: report,
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _selectedPreviewNode = node;
      _selectedPreviewReport = report;
      _isFullscreenPreview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Automatically select the first item by default if available and none selected
    final nodes = controller.coaNodes;
    if (nodes.isNotEmpty) {
      if (_selectedPreviewNode == null || !nodes.any((n) => n.id == _selectedPreviewNode!.id)) {
        _selectedPreviewNode = nodes.first;
        _selectedPreviewReport = nodes.first.reports.isNotEmpty ? nodes.first.reports.first : null;
      } else if (_selectedPreviewReport == null && _selectedPreviewNode!.reports.isNotEmpty) {
        _selectedPreviewReport = _selectedPreviewNode!.reports.first;
      }
    } else {
      _selectedPreviewNode = null;
      _selectedPreviewReport = null;
    }

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
      padding: EdgeInsets.all(widget.isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Control Bar (Search & Filter)
          _buildControlBar(controller),

          const SizedBox(height: 18),

          // 2. Content / State Handlers
          if (controller.isCoaLoading)
            const SizedBox(
              height: 320,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (controller.coaError != null)
            _buildErrorState(controller)
          else if (controller.coaNodes.isEmpty)
            _buildEmptyState(controller)
          else
            _buildMainLayout(controller),
        ],
      ),
    );
  }

  Widget _buildMainLayout(SampleController controller) {
    final listWidget = _buildReportsList(controller);

    if (!widget.isMobile && _selectedPreviewReport != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final panelHeight = (screenHeight - 160).clamp(750.0, 1000.0);

      if (_isFullscreenPreview) {
        return SizedBox(
          height: panelHeight,
          child: CoaPdfPreviewPanel(
            node: _selectedPreviewNode!,
            report: _selectedPreviewReport!,
            isFullscreen: true,
            onToggleFullscreen: () => setState(() => _isFullscreenPreview = false),
            onClose: () => setState(() => _isFullscreenPreview = false),
          ),
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Clean Report Cards List (~35% width)
          Expanded(
            flex: 4,
            child: SizedBox(
              height: panelHeight,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 6),
                  child: listWidget,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right: Live Interactive PDF Preview Panel (~65% width)
          Expanded(
            flex: 7,
            child: SizedBox(
              height: panelHeight,
              child: CoaPdfPreviewPanel(
                node: _selectedPreviewNode!,
                report: _selectedPreviewReport!,
                isFullscreen: false,
                onToggleFullscreen: () => setState(() => _isFullscreenPreview = true),
                onClose: () {},
              ),
            ),
          ),
        ],
      );
    }

    return listWidget;
  }

  Widget _buildControlBar(SampleController controller) {
    if (widget.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => controller.setCoaSearchQuery(val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by LIMS ID or File Name...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        controller.setCoaSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.selectedCoaStatusFilter,
                  isExpanded: true,
                  items: controller.availableCoaStatusFilters.map((st) {
                    return DropdownMenuItem(
                      value: st,
                      child: Text(
                        st == 'All' ? 'Status: All' : st,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.setCoaStatusFilter(val);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: controller.loadCoaReports,
                icon: const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
                tooltip: 'Refresh Reports',
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Live Search Input
        SizedBox(
          width: 320,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => controller.setCoaSearchQuery(val),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by LIMS ID, File Name, Report...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        controller.setCoaSearchQuery('');
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
              value: controller.selectedCoaStatusFilter,
              icon: const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
              items: controller.availableCoaStatusFilters.map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Text(
                    st == 'All' ? 'Status: All' : 'Status: $st',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.setCoaStatusFilter(val);
              },
            ),
          ),
        ),

        const Spacer(),

        // Refresh Button
        IconButton(
          onPressed: controller.loadCoaReports,
          icon: const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
          tooltip: 'Refresh COA Reports',
        ),
      ],
    );
  }

  Widget _buildReportsList(SampleController controller) {
    final nodes = controller.coaNodes;

    final List<_CoaCardItem> cardItems = [];
    for (final node in nodes) {
      if (node.reports.isEmpty) {
        cardItems.add(_CoaCardItem(
          node: node,
          report: CoaReportItemModel(
            coaId: node.id,
            certificateNo: node.limsId,
            reportDate: '',
            issueDate: '',
            authorizedBy: '',
            status: node.coaStatus,
            downloadUrl: '',
            parameters: [],
          ),
        ));
      } else {
        for (final r in node.reports) {
          cardItems.add(_CoaCardItem(node: node, report: r));
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cardItems.length,
      itemBuilder: (context, index) {
        final item = cardItems[index];
        return _buildReportCard(context, item.node, item.report);
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    CoaSampleNodeModel node,
    CoaReportItemModel report,
  ) {
    final bool isSelected = _selectedPreviewNode?.id == node.id &&
        ((_selectedPreviewReport?.reportNumber.isNotEmpty == true &&
          _selectedPreviewReport?.reportNumber == report.reportNumber) ||
         (_selectedPreviewReport?.fileName.isNotEmpty == true &&
          _selectedPreviewReport?.fileName == report.fileName) ||
         (_selectedPreviewReport?.coaId == report.coaId));

    final statusText = report.reportStatus.isNotEmpty ? report.reportStatus : report.status;
    final fileName = report.fileName.isNotEmpty
        ? report.fileName
        : (report.reportName.isNotEmpty ? report.reportName : 'Certificate of Analysis');
    final limsIdText = node.limsId.isNotEmpty
        ? node.limsId
        : (node.sampleId.isNotEmpty ? node.sampleId : (node.id.isNotEmpty ? node.id : 'N/A'));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectReport(node, report),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LIMS ID & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LIMS ID: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              limsIdText,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.darkBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SampleStatusBadge(status: statusText),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. File Name with PDF Icon
                Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 16,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF1D4ED8) : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(SampleController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No Certificate of Analysis records found',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search query or status filter',
            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              controller.setCoaSearchQuery('');
              controller.setCoaStatusFilter('All');
            },
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SampleController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(
            'Failed to load Certificate of Analysis reports',
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            controller.coaError ?? 'An unexpected error occurred.',
            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.loadCoaReports,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoaCardItem {
  final CoaSampleNodeModel node;
  final CoaReportItemModel report;
  const _CoaCardItem({required this.node, required this.report});
}
