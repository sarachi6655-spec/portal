import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/portal_drill_down_model.dart';
import 'sample_status_badge.dart';

class DrillDownDetailDrawer extends StatelessWidget {
  final PortalDrillDownItemModel item;
  final VoidCallback onClose;

  const DrillDownDetailDrawer({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final title = item.displayTitle;
    final status = item.getValue('OrderStatus').isNotEmpty
        ? item.getValue('OrderStatus')
        : (item.getValue('EnquiryStatus').isNotEmpty ? item.getValue('EnquiryStatus') : 'Active');

    final subInfo = item.getValue('EnquiryType').isNotEmpty
        ? 'Type: ${item.getValue('EnquiryType')} • Hospital: ${item.getValue('Hospital')}'
        : (item.orderCategory.isNotEmpty
            ? 'Category: ${item.orderCategory} • Month: ${item.orderBookingMonth.isNotEmpty ? item.orderBookingMonth : "N/A"}'
            : (item.getValue('Hospital').isNotEmpty ? 'Hospital: ${item.getValue('Hospital')}' : ''));

    final sections = _buildDynamicSections(item);

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = isMobile
        ? screenWidth
        : (screenWidth < 750 ? screenWidth * 0.92 : 680.0);

    return Container(
      width: drawerWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(-6, 0),
                ),
              ],
      ),
      child: Column(
        children: [
          // Drawer Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF0FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details - $title',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlateTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subInfo.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subInfo,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SampleStatusBadge(status: status),
                const SizedBox(width: 16),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < sections.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    _buildSectionHeader(sections[i].title),
                    _buildInfoGrid(sections[i].pairs, isMobile: isMobile),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SectionData> _buildDynamicSections(PortalDrillDownItemModel item) {
    final raw = item.rawJson;
    final handledKeys = <String>{};
    final sections = <_SectionData>[];

    List<_InfoPair> getPairs(List<String> keys) {
      final pairs = <_InfoPair>[];
      for (final k in keys) {
        if (raw.containsKey(k)) {
          handledKeys.add(k);
          final v = raw[k]?.toString().trim() ?? '';
          if (v.isNotEmpty) {
            pairs.add(_InfoPair(_formatKeyLabel(k), v));
          }
        }
      }
      return pairs;
    }

    // 1. Identification & Hospital
    final idPairs = getPairs([
      'OrderReference',
      'EnquiryReference',
      'EnquiryNo',
      'ReferenceID',
      'Hospital',
      'Branch',
      'Location',
      'Site',
      'ProjectName',
    ]);
    if (idPairs.isNotEmpty) {
      sections.add(_SectionData('Identification & Facility', idPairs));
    }

    // 2. Classification & Status
    final classPairs = getPairs([
      'OrderCategory',
      'EnquiryType',
      'OrderStatus',
      'EnquiryStatus',
      'ApprovedBy',
      'ApprovedDate',
      'RejectedBy',
      'RejectedDate',
    ]);
    if (classPairs.isNotEmpty) {
      sections.add(_SectionData('Classification & Status', classPairs));
    }

    // 3. Commercials & Financials
    final commPairs = getPairs([
      'TotalValue',
      'TotalCost',
      'OrderValue',
      'GrandTotal',
      'TaxValue',
      'TaxGroup',
      'TaxExempt',
      'LocalValue',
      'SpecialDiscount',
      'MarginAmount',
      'MarginPercentage',
      'OrderCurrency',
      'CompanyCurrency',
    ]);
    if (commPairs.isNotEmpty) {
      sections.add(_SectionData('Commercials & Financials', commPairs));
    }

    // 4. Dates & Logistics
    final datePairs = getPairs([
      'BookingDate',
      'EnquiryDate',
      'PODate',
      'PONo',
      'OrderBookingMonth',
      'StartDate',
      'EndDate',
    ]);
    if (datePairs.isNotEmpty) {
      sections.add(_SectionData('Dates & Logistics', datePairs));
    }

    // 5. Personnel & Contacts
    final personPairs = getPairs([
      'SalesPerson',
      'ContactPerson',
      'AcknowledgeBy',
      'AcknowledgementDate',
    ]);
    if (personPairs.isNotEmpty) {
      sections.add(_SectionData('Personnel & Contacts', personPairs));
    }

    // 6. Remaining unhandled fields
    final otherPairs = <_InfoPair>[];
    for (final entry in raw.entries) {
      if (!handledKeys.contains(entry.key)) {
        final v = entry.value?.toString().trim() ?? '';
        if (v.isNotEmpty) {
          otherPairs.add(_InfoPair(_formatKeyLabel(entry.key), v));
        }
      }
    }
    if (otherPairs.isNotEmpty) {
      sections.add(_SectionData('Additional Information', otherPairs));
    }

    return sections;
  }

  String _formatKeyLabel(String key) {
    if (key == 'OrderReference') return 'Order Reference';
    if (key == 'EnquiryReference') return 'Enquiry Reference';
    if (key == 'EnquiryNo') return 'Enquiry No';
    if (key == 'PONo') return 'PO Number';
    if (key == 'PODate') return 'PO Date';
    if (key == 'ReferenceID') return 'Reference ID';

    final spaced = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return spaced;
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoPair> pairs, {required bool isMobile}) {
    if (isMobile) {
      return Column(
        children: pairs.map((pair) => _buildInfoRow(pair.label, pair.value)).toList(),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < pairs.length; i += 2) {
      final left = pairs[i];
      final right = (i + 1 < pairs.length) ? pairs[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(child: _buildInfoRow(left.label, left.value)),
            const SizedBox(width: 16),
            Expanded(
              child: right != null
                  ? _buildInfoRow(right.label, right.value)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  final String title;
  final List<_InfoPair> pairs;
  _SectionData(this.title, this.pairs);
}

class _InfoPair {
  final String label;
  final String value;
  _InfoPair(this.label, this.value);
}
