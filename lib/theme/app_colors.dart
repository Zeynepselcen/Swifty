import 'package:flutter/material.dart';

/// Uygulamanın tüm renklerini tek bir yerden kontrol eden tema sınıfı
class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF1B2A4D);
  static const Color secondary = Color(0xFF0A183D);
  static const Color accent = Color(0xFF4DB6AC);
  
  // Gradient renkleri - Daha güzel pembe-mor tonları
  static const Color gradientStart = Color(0xFFFF6B9D); // Canlı pembe
  static const Color gradientMiddle1 = Color.fromARGB(255, 215, 92, 133); // Orta pembe
  static const Color gradientMiddle2 = Color.fromARGB(255, 187, 109, 201); // Orta mor
  static const Color gradientEnd = Color.fromARGB(255, 167, 136, 221); // Koyu mor
  
  // Arka plan renkleri
  static const Color backgroundPrimary = Color(0xFF0A183D);
  static const Color backgroundSecondary = Color(0xFF1B2A4D);
  static const Color backgroundTertiary = Color(0xFF233A5E);
  
  // Metin renkleri
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textTertiary = Color(0xFF78909C);
  
  // Buton renkleri
  static const Color buttonPrimary = Colors.white;
  static const Color buttonSecondary = Color(0xFF4DB6AC);
  static const Color buttonDanger = Color(0xFFE57373);
  static const Color buttonSuccess = Color(0xFF81C784);
  static const Color buttonWarning = Color(0xFFFFB74D);
  
  // Kart renkleri
  static const Color cardBackground = Color(0x1AFFFFFF); // %10 opacity white
  static const Color cardBorder = Color(0x4DFFFFFF); // %30 opacity white
  static const Color cardShadow = Color(0x1A000000); // %10 opacity black
  
  // Overlay renkleri
  static const Color overlayLight = Color(0x1AFFFFFF); // %10 opacity white
  static const Color overlayMedium = Color(0x4DFFFFFF); // %30 opacity white
  static const Color overlayDark = Color(0x80FFFFFF); // %50 opacity white
  
  // Durum renkleri
  static const Color success = Color(0xFF7CF29C);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);
  static const Color info = Color(0xFF4FC3F7);
  
  // Özel renkler
  static const Color waveColor1 = Color(0xFF6D327A);
  static const Color waveColor2 = Color(0xFFF15F79);
  
  // Opacity değerleri
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.3;
  static const double opacityHigh = 0.5;
  static const double opacityFull = 1.0;
  
  /// Ana gradient - Resimdeki güzel pembe-mor geçişi
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientStart,    // Parlak pembe
      gradientMiddle1,  // Orta pembe
      gradientMiddle2,  // Orta mor
      gradientEnd,      // Parlak mor
    ],
  );
  
  /// Arka plan gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundPrimary,
      backgroundSecondary,
      backgroundTertiary,
      backgroundTertiary,
    ],
  );
  
  /// Buton gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundSecondary,
      backgroundPrimary,
    ],
  );
  
  /// Progress bar gradient
  static const LinearGradient progressGradient = LinearGradient(
    colors: [
      accent,
      gradientStart,
    ],
  );
  
  /// Opacity ile renk oluşturma yardımcı metodları
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static Color textWithOpacity(double opacity) {
    return textPrimary.withOpacity(opacity);
  }
  
  static Color backgroundWithOpacity(double opacity) {
    return backgroundPrimary.withOpacity(opacity);
  }
  
  static Color cardWithOpacity(double opacity) {
    return cardBackground.withOpacity(opacity);
  }
  
  /// Tema moduna göre renk döndürme
  static Color getAdaptiveColor(BuildContext context, {Color? light, Color? dark}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? (dark ?? textPrimary) : (light ?? primary);
  }
  
  /// Buton renklerini tema moduna göre döndürme
  static Color getButtonColor(BuildContext context, {bool isSelected = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isSelected) {
      return isDark ? buttonPrimary : primary;
    } else {
      return isDark ? textPrimary : primary;
    }
  }
  
  /// Kart arka plan rengini tema moduna göre döndürme
  static Color getCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cardBackground : Colors.white.withOpacity(0.9);
  }
  
  /// Metin rengini tema moduna göre döndürme
  static Color getTextColor(BuildContext context, {bool isPrimary = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isPrimary) {
      return isDark ? textPrimary : primary;
    } else {
      return isDark ? textSecondary : textSecondary;
    }
  }
}
