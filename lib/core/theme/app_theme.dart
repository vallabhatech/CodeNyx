import 'package:flutter/material.dart';

/// CodeNyx Hackathon Theme
/// Bold, vibrant design with rainbow gradients and black background
/// Inspired by the official CodeNyx website aesthetic
class AppTheme {
  // ============ Color Palette ============
  // Pure black background like the website
  static const Color primaryBackground = Color(0xFF000000); // Pure black
  static const Color secondaryBackground = Color(
    0xFF0A0A0A,
  ); // Slightly lighter black
  static const Color surfaceLight = Color(0xFF1A1A1A); // Dark surface

  // Rainbow/Vibrant Colors - TONED DOWN for balance
  static const Color colorRed = Color(0xFFCC5555); // Muted red
  static const Color colorOrange = Color(0xFFDD7744); // Softer orange
  static const Color colorYellow = Color(0xFFCCBB33); // Muted yellow
  static const Color colorGreen = Color(0xFF44BB66); // Softer green
  static const Color colorBlue = Color(0xFF4488DD); // Softer blue
  static const Color colorPurple = Color(0xFFAA66CC); // Softer purple
  static const Color colorPink = Color(0xFFCC6688); // Softer pink

  // Accent colors - REFINED
  static const Color accentPrimary = Color(0xFFDD6655); // Warm muted red/coral
  static const Color accentSecondary = Color(0xFF55BB88); // Soft teal green
  static const Color accentTertiary = Color(0xFF9966DD); // Soft purple

  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFC0C0C0); // Light gray
  static const Color textTertiary = Color(0xFF808080); // Medium gray
  static const Color borderColor = Color(0xFF333333); // Dark borders
  static const Color dividerColor = Color(0xFF1A1A1A); // Dark dividers

  // ============ Gradients ============
  // Bold rainbow gradient matching website
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      colorRed,
      colorOrange,
      colorYellow,
      colorGreen,
      colorBlue,
      colorPurple,
    ],
  );

  // Softer background gradient (mostly black)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBackground, secondaryBackground, primaryBackground],
  );

  // Card gradient - dark with subtle light overlay
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x20FFFFFF), // 12% white overlay
      Color(0x10FFFFFF), // 6% white overlay
    ],
  );

  // Rainbow accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      colorRed,
      colorOrange,
      colorYellow,
      colorGreen,
      colorBlue,
      colorPurple,
    ],
  );

  // ============ Text Styles ============
  /// Hackathon name display - with rainbow colors
  static const TextStyle hackathonTitle = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: colorRed,
    letterSpacing: 0.5,
  );

  /// Page titles
  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Section headers - softer color
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: accentPrimary,
    letterSpacing: 0.5,
  );

  /// Card titles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.2,
  );

  /// Card body text
  static const TextStyle cardBody = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  /// Meta information (small text)
  static const TextStyle metaText = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.2,
  );

  /// Navigation labels
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ============ Border Radius ============
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;

  // ============ Spacing ============
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  // ============ Helper Methods ============
  static BoxDecoration cardDecoration({
    bool elevated = false,
    double borderRadius = radiusMedium,
  }) {
    return BoxDecoration(
      color: surfaceLight.withOpacity(0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 0.8),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration accentCardDecoration({
    double borderRadius = radiusMedium,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accentPrimary.withOpacity(0.08),
          accentSecondary.withOpacity(0.06),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: accentPrimary.withOpacity(0.25), width: 1),
    );
  }

  static BoxDecoration navBarDecoration() {
    return BoxDecoration(color: primaryBackground.withOpacity(0.95));
  }

  static BoxDecoration bannerDecoration({bool isTimer = false}) {
    return BoxDecoration(
      color: isTimer
          ? accentPrimary.withOpacity(0.12)
          : surfaceLight.withOpacity(0.6),
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: isTimer ? accentPrimary.withOpacity(0.4) : borderColor,
        width: isTimer ? 1.5 : 0.8,
      ),
    );
  }
}
