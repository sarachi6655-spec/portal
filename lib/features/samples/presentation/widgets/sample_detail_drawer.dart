import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/sample_detail_model.dart';
import 'sample_status_badge.dart';

class SampleDetailDrawer extends StatelessWidget {
  final SampleDetailModel detail;
  final VoidCallback onClose;

  const SampleDetailDrawer({
    super.key,
    required this.detail,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: isMobile ? MediaQuery.of(context).size.width : 680,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
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
                    Icons.local_hospital_outlined,
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
                        'Sample Details - ${detail.limsId.isNotEmpty ? detail.limsId : "N/A"}',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlateTitle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sample Name: ${detail.sampleName}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SampleStatusBadge(status: detail.sampleStatus),
                const SizedBox(width: 16),
                // Circular Close Button matching portal.css .modal-close
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
                  // Section 1: Sample Identification
                  _buildSectionHeader('Sample Identification'),
                  _buildInfoGrid([
                    _InfoPair('LIMS ID', detail.limsId),
                    _InfoPair('Sample ID', detail.sampleId),
                    _InfoPair('Job No', detail.jobNo),
                    _InfoPair('Client ID', detail.clientId),
                    _InfoPair('Sample Category', detail.sampleCategory),
                    _InfoPair('Sample Type', detail.sampleType),
                    _InfoPair('Sub Type', detail.subType),
                    _InfoPair('Delta Check', detail.isDeltaCheck ? 'Yes' : 'No'),
                  ], isMobile: isMobile),

                  const SizedBox(height: 20),

                  // Section 2: Patient & Requester Details
                  _buildSectionHeader('Patient & Requester Details'),
                  _buildInfoGrid([
                    _InfoPair('Patient Name', detail.patientName),
                    _InfoPair('Patient Code', detail.patientCode),
                    _InfoPair('CPR No', detail.cprNo),
                    _InfoPair('HID No', detail.hidNo),
                    _InfoPair('Doctor Name', detail.doctorName),
                    _InfoPair('Request ID', detail.requestId),
                    _InfoPair('Order No', detail.orderNo),
                    _InfoPair('Work Order No', detail.workOrderNo),
                  ], isMobile: isMobile),

                  const SizedBox(height: 20),

                  // Section 3: Specimen & Logistics
                  _buildSectionHeader('Specimen & Logistics'),
                  _buildInfoGrid([
                    _InfoPair('Sample Nature', detail.sampleNature),
                    _InfoPair('Container', detail.sampleContainer),
                    _InfoPair('Quantity', '${detail.sampleQuantity} ${detail.sampleQtyUnit}'.trim()),
                    _InfoPair('Reference No', detail.referenceNo),
                    _InfoPair('Logged By', detail.loggedBy),
                    _InfoPair('Log Date', detail.logDate),
                    _InfoPair('Received Date', detail.receivedDate),
                    _InfoPair('Expiry Date', detail.expiryDate),
                  ], isMobile: isMobile),

                  const SizedBox(height: 20),

                  // Section 4: Testing & Laboratory
                  _buildSectionHeader('Testing & Laboratory Workflow'),
                  _buildInfoGrid([
                    _InfoPair('Sample Status', detail.sampleStatus),
                    _InfoPair('Test Limits', detail.testLimits),
                    _InfoPair('Test Due Date', detail.testDueDate),
                    _InfoPair('Inspection Due Date', detail.inspectionDueDate),
                    _InfoPair('Result Entered By', detail.resultEnteredBy),
                    _InfoPair('Result Entry Date', detail.resultEntryDate),
                    _InfoPair('Responsible Lab', detail.responsibleLab),
                    _InfoPair('Department', '${detail.branch} / ${detail.department}'.trim()),
                  ], isMobile: isMobile),

                  if (detail.sampleComments.isNotEmpty || detail.remarks.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader('Remarks & Comments'),
                    if (detail.sampleComments.isNotEmpty)
                      _buildCommentCard('Sample Comments', detail.sampleComments),
                    if (detail.remarks.isNotEmpty)
                      _buildCommentCard('Remarks', detail.remarks),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
            color: AppColors.primary.withOpacity(0.25),
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

    // 2 columns
    final rows = <Widget>[];
    for (int i = 0; i < pairs.length; i += 2) {
      final left = pairs[i];
      final right = (i + 1 < pairs.length) ? pairs[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoRow(left.label, left.value)),
            const SizedBox(width: 32),
            Expanded(
              child: right != null ? _buildInfoRow(right.label, right.value) : const SizedBox(),
            ),
          ],
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildInfoRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.dashBorder,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.hoverBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _InfoPair {
  final String label;
  final String value;
  _InfoPair(this.label, this.value);
}
