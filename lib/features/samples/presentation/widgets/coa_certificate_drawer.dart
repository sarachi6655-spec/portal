import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/coa_report_model.dart';
import 'sample_status_badge.dart';

class CoaCertificateDrawer extends StatelessWidget {
  final CoaSampleNodeModel node;
  final CoaReportItemModel report;
  final VoidCallback onClose;

  const CoaCertificateDrawer({
    super.key,
    required this.node,
    required this.report,
    required this.onClose,
  });

  Future<void> _handleDownload(BuildContext context) async {
    final pdfUrl = report.resolvedPdfUrl;
    if (pdfUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PDF file path or file name available for this report.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final encodedUrl = Uri.encodeFull(pdfUrl);
    final uri = Uri.tryParse(encodedUrl);
    if (uri != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opening PDF from server: ${report.fileName}...',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri);
        }
      } catch (e) {
        debugPrint('Launch external failed: $e');
        try {
          await launchUrl(uri);
        } catch (err) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load COA PDF: $err'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = isMobile
        ? screenWidth
        : (screenWidth < 850 ? screenWidth * 0.94 : 780.0);

    return Container(
      width: drawerWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 32,
                  offset: const Offset(-8, 0),
                ),
              ],
      ),
      child: Column(
        children: [
          // 1. Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certificate of Analysis',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlateTitle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.fileName.isNotEmpty ? report.fileName : report.certificateNo} • ${node.sampleName}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SampleStatusBadge(status: report.reportStatus.isNotEmpty ? report.reportStatus : report.status),
                const SizedBox(width: 14),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBlue,
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

          // 2. Scrollable Certificate Document Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Certificate Official Letterhead Banner
                  _buildCertificateBanner(isMobile),

                  const SizedBox(height: 20),

                  // Section 1: COA Report Details
                  _buildSectionTitle('1. COA Report & Document Details'),
                  _buildInfoGrid([
                    _InfoPair('LIMS ID', node.limsId.isNotEmpty ? node.limsId : '-'),
                    _InfoPair('Report Number', report.reportNumber.isNotEmpty ? '#${report.reportNumber}' : report.certificateNo),
                    _InfoPair('Report Type', report.reportType.isNotEmpty ? report.reportType : 'Apollo COA Report'),
                    _InfoPair('Report Name', report.reportName.isNotEmpty ? report.reportName : 'Test Report'),
                    _InfoPair('PDF File Name', report.fileName.isNotEmpty ? report.fileName : '${report.certificateNo}.pdf'),
                    _InfoPair('Storage File Path', report.filePath.isNotEmpty ? report.filePath : '-'),
                    _InfoPair('Generated Date', report.generatedDate.isNotEmpty ? report.generatedDate : (report.issueDate.isNotEmpty ? report.issueDate : '-')),
                    _InfoPair('Report Status', report.reportStatus.isNotEmpty ? report.reportStatus : report.status),
                    if (node.clientName.isNotEmpty) _InfoPair('Client Name', node.clientName),
                    if (node.sampleCategory.isNotEmpty) _InfoPair('Category', node.sampleCategory),
                  ], isMobile: isMobile),

                  const SizedBox(height: 14),

                  // Direct Server PDF Access Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.link, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Text(
                              'SERVER PDF URL',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Copy URL',
                              icon: const Icon(Icons.copy, size: 14, color: Color(0xFF15803D)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: report.resolvedPdfUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Server PDF URL copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          report.resolvedPdfUrl,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 11,
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _handleDownload(context),
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('Open PDF from Server'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (report.sampleDescription.isNotEmpty && report.sampleDescription != report.reportName) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESCRIPTION',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.sampleDescription,
                            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (report.parameters.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // Section 2: Laboratory Test Results Table (only when parameters are in API)
                    _buildSectionTitle('2. Laboratory Test Results & Specifications'),
                    _buildTestParametersTable(isMobile),

                    const SizedBox(height: 24),

                    // Section 3: Conformity Statement & Signatory
                    _buildSectionTitle('3. Authorization & Statement of Conformity'),
                    _buildConformityAndSignatureCard(isMobile),
                  ],
                ],
              ),
            ),
          ),

          // 3. Bottom Action Bar (Download PDF, Print, Close)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleDownload(context),
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Open PDF (Server)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.biotech_rounded,
                      color: Color(0xFF60A5FA),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REVOL LABORATORY SERVICES',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Accredited Testing & Calibration Facility',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'ISO/IEC 17025',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF34D399),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CERTIFICATE NO: ${report.certificateNo}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF38BDF8),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'STATUS: ${report.status.toUpperCase()}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.darkSlateTitle,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoRow(left.label, left.value)),
            const SizedBox(width: 24),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dashBorder, width: 1)),
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
              value,
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

  Widget _buildTestParametersTable(bool isMobile) {
    if (report.parameters.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          'No test parameter records attached to this certificate.',
          style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            headingTextStyle: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
            dataTextStyle: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            columnSpacing: 18,
            horizontalMargin: 16,
            headingRowHeight: 40,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 48,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('TEST PARAMETER')),
              DataColumn(label: Text('TEST METHOD')),
              DataColumn(label: Text('SPECIFICATION')),
              DataColumn(label: Text('RESULT')),
              DataColumn(label: Text('UNIT')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('ANALYST')),
            ],
            rows: List<DataRow>.generate(
              report.parameters.length,
              (index) {
                final param = report.parameters[index];
                final isPass = param.isPass;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(param.parameterName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(param.testMethod)),
                    DataCell(Text(param.specification)),
                    DataCell(
                      Text(
                        param.result,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPass ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                    DataCell(Text(param.unit.isNotEmpty ? param.unit : '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPass ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isPass ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                          ),
                        ),
                        child: Text(
                          param.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPass ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(param.analyst.isNotEmpty ? param.analyst : '-')),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConformityAndSignatureCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATEMENT OF CONFORMITY:',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The sample(s) tested meet all specifications and quality criteria established by laboratory standard operating procedures and applicable regulatory standards. Results relate strictly to the item(s) tested.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUTHORIZED BY',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.authorizedBy,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlateTitle,
                    ),
                  ),
                  Text(
                    'Quality Assurance & Laboratory Director',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'DIGITALLY SIGNED',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
