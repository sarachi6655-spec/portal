import 'package:flutter/material.dart';
import 'package:revol_portal/features/home/data/models/client_portal_details_model.dart';
import '../../data/models/service_detail_model.dart';
import '../widgets/service_card.dart';
import '../widgets/service_details_dialog.dart';

/// Dedicated "Our Services" page view
/// Directly displays the responsive grid of ServiceCard widgets
/// with the full-screen modal popup for sub-services and prices
class OurServicesView extends StatelessWidget {
  final List<ServiceItemDetail> services;
  final bool isLoading;
  final VoidCallback? onBackToHome;
  final ClientPortalDetailsModel isSpace;

  const OurServicesView({super.key, required this.services, this.isLoading = false, this.onBackToHome, required this.isSpace});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: isMobile ? 24 : 44,
      ),
      child: isLoading && services.isEmpty
          ? _buildLoadingState()
          : services.isEmpty
              ? _buildEmptyResults()
              : _buildServiceCardsGrid(services, isMobile, isTablet),
    );
  }

  /// Responsive Grid of ServiceCard widgets (left-aligned)
  Widget _buildServiceCardsGrid(
    List<ServiceItemDetail> services,
    bool isMobile,
    bool isTablet,
  ) {
    // 1 column on mobile, 2 on tablet, 4 on desktop/wide screens
    final int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Enforce max container width of 1280 so cards maintain optimal proportions
        final double effectiveWidth = constraints.maxWidth > 1280 ? 1280 : constraints.maxWidth;
        const double spacing = 20.0;
        final double totalSpacing = spacing * (crossAxisCount - 1);
        final double itemWidth = isMobile ? constraints.maxWidth : (effectiveWidth - totalSpacing) / crossAxisCount;

        return Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: spacing,
            runSpacing: spacing,
            children: services.map((service) {
              return SizedBox(
                width: itemWidth,
                child: ServiceCard(
                  imagePath: service.imagePath,
                  title: service.title,
                  description: service.description ?? '',
                  startingPrice: service.startingPrice,
                  buttonText: 'Test List',
                  onReadMorePressed: () {
                    debugPrint('yguhcliuwe ${isSpace.isServiceWithPrice}');
                    showServiceDetailsFullScreenDialog(context, service: service, isSpace: isSpace);
                  },
                  remarks: service.remarks ?? '',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.medical_services_outlined, size: 54, color: Color(0xFF94A3B8)),
          SizedBox(height: 16),
          Text(
            'No services available at this time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF2490EB),
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Loading client services...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
