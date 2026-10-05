import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revol_portal/features/home/data/models/client_portal_details_model.dart';
import '../../data/models/service_detail_model.dart';

/// Helper function to open the full-screen modal popup/dialog
Future<void> showServiceDetailsFullScreenDialog(BuildContext context, {required ServiceItemDetail service, required ClientPortalDetailsModel isSpace}) {
  return showDialog(
    context: context,
    useSafeArea: false,
    barrierDismissible: true,
    builder: (ctx) => ServiceDetailsFullScreenDialog(service: service, ispacw: isSpace),
  );
}

/// Full-screen modal popup/dialog for displaying:
/// - Clean header with close button ("X") and selected service title
/// - Service banner (image, title, description)
/// - Scrollable list of test cards showing only test name, code, and price
class ServiceDetailsFullScreenDialog extends StatelessWidget {
  final ServiceItemDetail service;
  final ClientPortalDetailsModel ispacw;
  ServiceDetailsFullScreenDialog({
    super.key,
    required this.service,
    required this.ispacw,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Clean Top Header with ("X") close button and selected service title
              _buildCleanHeader(context, isMobile),

              // 2. Main Scrollable Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 48,
                    vertical: isMobile ? 16 : 28,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Overview Banner Card (Image, Title, Description only)
                          _buildServiceHeroBanner(isMobile),

                          const SizedBox(height: 24),

                          // Test Cards: Only Test Name, Code, and Price
                          if (service.subServices.isEmpty) _buildEmptyState() else _buildSubServicesList(service.subServices, isMobile, ispacw),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Clean Header with Close button ("X") and Service Title
  Widget _buildCleanHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Service Icon Badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF2490EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Selected Service Title
          Expanded(
            child: Text(
              service.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Clean Close Button ("X")
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF334155),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Service Hero Banner with image and description only
  Widget _buildServiceHeroBanner(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBannerImage(height: 150),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildBannerTextContent(),
                ),
              ],
            )
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildBannerImage(height: 150),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: _buildBannerTextContent(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBannerImage({required double height}) {
    return SizedBox(
      height: height,
      child: service.imagePath.trim().isEmpty
          ? Container(
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Icon(Icons.biotech_rounded, size: 50, color: Colors.white54),
              ),
            )
          : service.imagePath.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: service.imagePath,
                  fit: BoxFit.contain,
                  errorWidget: (c, u, e) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: Icon(Icons.biotech_rounded, size: 50, color: Colors.white54),
                    ),
                  ),
                )
              : Image.asset(
                  service.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: Icon(Icons.biotech_rounded, size: 50, color: Colors.white54),
                    ),
                  ),
                ),
    );
  }

  Widget _buildBannerTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          service.title,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        if ((service.remarks ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            (service.remarks ?? ''),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  /// Clean List View displaying sub-services: only test name, code, and price
  Widget _buildSubServicesList(List<SubServiceItem> items, bool isMobile, ClientPortalDetailsModel ispacw) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final sub = items[index];
        return _buildSubServiceRowCard(sub, isMobile);
      },
    );
  }

  /// Individual item card: only Test name, Code, and Price without extra wordings
  Widget _buildSubServiceRowCard(SubServiceItem item, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Block: Test Code - Name
          Expanded(
            child: Text(
              item.code != null && item.code!.trim().isNotEmpty ? '${item.code} - ${item.name}' : item.name,
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 14 : 15.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),

          const SizedBox(width: 16),
          if (ispacw.isServiceWithPrice != null && ispacw.isServiceWithPrice == true)
            // Right Block: Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Text(
                item.price,
                style: GoogleFonts.montserrat(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF15803D),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          'No tests available at this time.',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
