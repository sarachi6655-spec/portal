import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PortalSidebar extends StatelessWidget {
  final bool isCollapsed;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const PortalSidebar({
    super.key,
    required this.isCollapsed,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        border: const Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Header / Logo
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 16 : 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.biotech, color: Colors.white, size: 20),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al Jawhara Centre',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Scrollable Menu List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Section - MAIN
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                      child: Text(
                        'MAIN',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'My Page',
                    index: 0,
                  ),

                  // Menu Section - GENERAL
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                      child: Text(
                        'GENERAL',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    activeIcon: Icons.contact_support,
                    title: 'Enquiry',
                    index: 1,
                  ),

                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    title: 'Orders',
                    index: 2,
                  ),

                  _buildMenuItem(
                    icon: Icons.app_registration_outlined,
                    activeIcon: Icons.app_registration,
                    title: 'Sample Registration',
                    index: 3,
                  ),

                  _buildMenuItem(
                    icon: Icons.track_changes_outlined,
                    activeIcon: Icons.track_changes,
                    title: 'Sample Tracking',
                    index: 4,
                  ),

                  _buildMenuItem(
                    icon: Icons.verified_outlined,
                    activeIcon: Icons.verified,
                    title: 'Certificate of Analysis',
                    index: 5,
                  ),
                ],
              ),
            ),
          ),

          // Version / Footer
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Revol LIMS v1.5\nAI Driven Platform',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    String? badge,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 16 : 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeBg : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusSuccessText,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
