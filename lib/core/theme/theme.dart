import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enterprise Design System for Revol LIMS Client Portal
/// 
/// Built with:
/// - 2-accent system (Deep Indigo #2D3E8C + Muted Teal #0F766E)
/// - 10-step Neutral Gray Scale (#FAFAFA to #1A1A1A)
/// - Desaturated 70%-max status pill color palette
/// - Google Fonts "Plus Jakarta Sans" TextTheme with deliberate weight scale
/// - Multi-layer subtle box shadows for elevation without hard colored borders
/// - 8pt spacing grid & 16px standardized card corner radiuses
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PRIMARY & SECONDARY ACCENT SYSTEM
  // ===========================================================================
  
  /// Primary Accent: Deep Indigo / Navy
  static const Color primary = Color(0xFF2D3E8C);
  static const Color primaryHover = Color(0xFF233271);
  static const Color primaryActive = Color(0xFF1B2758);
  static const Color primaryTint = Color(0xFFEEF2FF); // Subtle tint for active items
  static const Color primaryBorder = Color(0xFFC7D2FE);

  /// Secondary Accent: Muted Teal
  static const Color secondary = Color(0xFF0F766E);
  static const Color secondaryHover = Color(0xFF0D655E);
  static const Color secondaryTint = Color(0xFFF0FDFA);
  static const Color secondaryBorder = Color(0xFF99F6E4);

  // Backward-compatible brand aliases
  static const Color navyBrand = primary;
  static const Color accentBlue = secondary;
  static const Color darkBlue = neutral900;
  static const Color borderBlue = primaryBorder;
  static const Color darkSlateTitle = neutral900;

  // ===========================================================================
  // 2. NEUTRAL GRAY SCALE (10 Steps: #FAFAFA to #1A1A1A)
  // ===========================================================================
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF1A1A1A);

  // Surface & Layout Backgrounds
  static const Color bgBody = Color(0xFFFAFAFA);
  static const Color bgSidebar = Color(0xFFFFFFFF);
  static const Color bgHeader = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSection = neutral100;
  static const Color hoverBg = Color(0xFFF8FAFC);
  static const Color activeBg = Color(0xFFEEF2FF); // Soft indigo tint
  static const Color listActiveBg = Color(0xFFEEF2FF);
  static const Color inputBg = neutral50;

  // Text Typography Colors
  static const Color textPrimary = neutral900;     // #1A1A1A
  static const Color textSecondary = neutral700;   // #404040
  static const Color textMuted = neutral500;       // #737373
  static const Color textPlaceholder = neutral400; // #A3A3A3
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textBody = neutral700;

  // Borders & Dividers
  static const Color border = Color(0xFFEFEFEF);
  static const Color borderDefault = Color(0xFFE5E5E5);
  static const Color borderSubtle = Color(0xFFF0F0F0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color formBorder = Color(0xFFE0E0E0);
  static const Color dashBorder = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x0A000000);

  // ===========================================================================
  // 3. DESATURATED STATUS PALETTE (~70% Saturation Max)
  // ===========================================================================
  
  // Completed / Success -> Sage Green
  static const Color statusSuccessText = Color(0xFF1E6B47);
  static const Color statusSuccessBg = Color(0xFFEAF5EF);
  static const Color statusSuccessDot = Color(0xFF2D8A5E);

  // In Progress / Info -> Slate Blue
  static const Color statusInProgressText = Color(0xFF2A4365);
  static const Color statusInProgressBg = Color(0xFFEDF2F7);
  static const Color statusInProgressDot = Color(0xFF3182CE);

  // Pending / Warning -> Dusty Amber
  static const Color statusPendingText = Color(0xFF92400E);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingDot = Color(0xFFD97706);

  // Approved / Delivered -> Muted Teal
  static const Color statusApprovedText = Color(0xFF0F766E);
  static const Color statusApprovedBg = Color(0xFFCCFBF1);
  static const Color statusApprovedDot = Color(0xFF14B8A6);

  // Overdue / Failed / Danger -> Terracotta
  static const Color statusFailedText = Color(0xFF991B1B);
  static const Color statusFailedBg = Color(0xFFFEE2E2);
  static const Color statusFailedDot = Color(0xFFDC2626);
  static const Color error = Color(0xFFDC2626);

  // Hold / Partial -> Muted Bronze / Ochre
  static const Color statusHoldText = Color(0xFF78350F);
  static const Color statusHoldBg = Color(0xFFFEF3C7);
  static const Color statusHoldDot = Color(0xFFB45309);

  // Chart Flat Gradient Colors (Vertical 5-8% Lightness shift)
  static const Color chartIndigoTop = Color(0xFF33469D);
  static const Color chartIndigoBottom = Color(0xFF28377E);

  static const Color chartTealTop = Color(0xFF148D84);
  static const Color chartTealBottom = Color(0xFF0E6E67);

  static const Color chartSlateTop = Color(0xFF475569);
  static const Color chartSlateBottom = Color(0xFF334155);

  static const Color chartAmberTop = Color(0xFFD97706);
  static const Color chartAmberBottom = Color(0xFFB45309);

  static const Color chartGrid = Color(0xFFF0F0F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D3E8C), Color(0xFF3B50B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2D3E8C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBlueGradient = LinearGradient(
    colors: [Color(0xFF2D3E8C), Color(0xFF3B50B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOrangeGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardPurpleGradient = LinearGradient(
    colors: [Color(0xFF4338CA), Color(0xFF3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Elevation and Shadow Design Tokens
class AppElevation {
  AppElevation._();

  /// Soft Multi-layer BoxShadow for Enterprise Cards
  /// Replaces harsh colored borders with high-end optical depth
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000), // ~3% opacity
      blurRadius: 40,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  /// Hover elevation state
  static const List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0D000000), // ~5% opacity
      blurRadius: 48,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  /// Subtle header / navigation bar shadow
  static const List<BoxShadow> headerShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Subtle dropdown / popup shadow
  static const List<BoxShadow> dropdownShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
}

/// Spacing Grid & Corner Radius Tokens (8pt Grid)
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0; // Standardized internal card padding
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusCard = 16.0; // Standardized card corner radius
  static const double radiusPill = 24.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(radiusCard);
  static final BorderRadius pillBorderRadius = BorderRadius.circular(radiusPill);
  static final BorderRadius inputBorderRadius = BorderRadius.circular(radiusSmall);
}

/// The AppTheme configuration using Google Fonts "Plus Jakarta Sans"
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseFont = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgBody,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      
      // Deliberate weight scale:
      // 700 for headings, 600 for subheadings/metrics, 500 for labels, 400 for body
      textTheme: baseFont.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.1,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral500,
          letterSpacing: 1.2, // Refined letter spacing for uppercase section headers
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        error: AppColors.statusFailedText,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),

      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgHeader,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.neutral600),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputBorderRadius,
          borderSide: const BorderSide(color: AppColors.statusFailedText, width: 1),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPlaceholder,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
