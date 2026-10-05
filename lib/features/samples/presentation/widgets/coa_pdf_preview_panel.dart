import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/coa_report_model.dart';
import 'pdf_embed_view.dart';
import 'sample_status_badge.dart';

class CoaPdfPreviewPanel extends StatelessWidget {
  final CoaSampleNodeModel node;
  final CoaReportItemModel report;
  final VoidCallback onClose;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const CoaPdfPreviewPanel({
    super.key,
    required this.node,
    required this.report,
    required this.onClose,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  Future<void> _openExternal(BuildContext context) async {
    final pdfUrl = report.resolvedPdfUrl;
    if (pdfUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PDF file path or file name is available for this report.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final encoded = Uri.encodeFull(pdfUrl);
    final uri = Uri.tryParse(encoded);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) await launchUrl(uri);
      } catch (e) {
        try {
          await launchUrl(uri);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = report.reportStatus.isNotEmpty ? report.reportStatus : report.status;
    final encodedUrl = Uri.encodeFull(report.resolvedPdfUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            ),
            child: Row(
              children: [
                // PDF Icon Badge
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFDC2626),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Report Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              report.reportNumber.isNotEmpty
                                  ? 'Report #${report.reportNumber} • ${report.fileName.isNotEmpty ? report.fileName : "Certificate of Analysis"}'
                                  : (report.fileName.isNotEmpty ? report.fileName : 'COA Document'),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkSlateTitle,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SampleStatusBadge(status: statusText),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LIMS ID: ${node.limsId}${report.generatedDate.isNotEmpty ? " • Generated: ${report.generatedDate}" : ""}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Download PDF
                IconButton(
                  tooltip: 'Download PDF',
                  icon: const Icon(Icons.download_rounded, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () => _openExternal(context),
                  visualDensity: VisualDensity.compact,
                ),

                // Open in External Tab
                IconButton(
                  tooltip: 'Open in new tab',
                  icon: const Icon(Icons.open_in_new, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () => _openExternal(context),
                  visualDensity: VisualDensity.compact,
                ),

                // Fullscreen Toggle
                if (onToggleFullscreen != null)
                  IconButton(
                    tooltip: isFullscreen ? 'Exit fullscreen' : 'Expand preview',
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      size: 20,
                    ),
                    color: AppColors.textSecondary,
                    onPressed: onToggleFullscreen,
                    visualDensity: VisualDensity.compact,
                  ),

                // Close Preview
                IconButton(
                  tooltip: 'Close preview',
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // 2. Embedded PDF Viewer (IFrame on web)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: encodedUrl.isNotEmpty
                  ? PdfEmbedView(url: encodedUrl)
                  : _buildErrorState(context),
            ),
          ),

          // 3. Bottom URL Info Strip (Shown only if PDF URL is available)
          if (report.resolvedPdfUrl.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.resolvedPdfUrl,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy PDF URL',
                    icon: const Icon(Icons.copy, size: 13, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
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
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final statusText = report.reportStatus.isNotEmpty ? report.reportStatus : report.status;
    final isPending = statusText.toLowerCase().contains('progress') ||
        statusText.toLowerCase().contains('pending') ||
        statusText.toLowerCase().contains('process') ||
        statusText.toLowerCase().contains('review');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECACA),
                ),
              ),
              child: Icon(
                isPending ? Icons.hourglass_top_rounded : Icons.picture_as_pdf_outlined,
                size: 38,
                color: isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'Report Generation In Progress' : 'PDF Report Not Available',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlateTitle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPending
                  ? 'This Certificate of Analysis is currently "$statusText". The document will be accessible once laboratory testing is completed.'
                  : 'No document URL or file path is available for LIMS ID ${node.limsId.isNotEmpty ? node.limsId : "this sample"}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
