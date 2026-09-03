import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class SampleStatusBadge extends StatelessWidget {
  final String status;

  const SampleStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('complete') || lowerStatus.contains('success') || lowerStatus.contains('clear') || lowerStatus == 'released') {
      textColor = AppColors.statusSuccessText;
      bgColor = AppColors.statusSuccessBg;
    } else if (lowerStatus.contains('progress') || lowerStatus.contains('testing') || lowerStatus.contains('analyzing')) {
      textColor = AppColors.statusInProgressText;
      bgColor = AppColors.statusInProgressBg;
    } else if (lowerStatus.contains('hold') || lowerStatus.contains('pending') || lowerStatus.contains('queued')) {
      textColor = AppColors.statusPendingText;
      bgColor = AppColors.statusPendingBg;
    } else if (lowerStatus.contains('fail') || lowerStatus.contains('reject') || lowerStatus.contains('overdue')) {
      textColor = AppColors.statusFailedText;
      bgColor = AppColors.statusFailedBg;
    } else {
      textColor = AppColors.primary;
      bgColor = AppColors.activeBg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Pending' : status,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
