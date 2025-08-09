import 'package:flutter/material.dart';
import 'gallery_album_list_screen.dart';
import 'recently_deleted_screen.dart';
import '../widgets/debounced_button.dart';
// import '../l10n/app_localizations.dart'; // kaldırıldı

import 'dart:io';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  final Locale? currentLocale;
  final bool isDarkTheme;
  final VoidCallback? onThemeChanged;
  const MainScreen({super.key, this.onLocaleChanged, this.currentLocale, this.isDarkTheme = false, this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Locale _currentLocale = const Locale('tr');

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.currentLocale ?? const Locale('tr');
    
    // Eğer widget.currentLocale null ise, varsayılan dil kullan
    if (widget.currentLocale == null) {
      _currentLocale = const Locale('tr');
    }
  }

  void _handleLocaleChange(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
    widget.onLocaleChanged?.call(newLocale);
    
    // Dil değişikliği sonrası daha güçlü yenileme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showSettingsDialog() async {
    final appLoc = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: widget.isDarkTheme 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                  ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: widget.isDarkTheme 
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF0F2F5), Color(0xFFE8ECF0)],
                        ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          '⚙️',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLoc.settings,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                letterSpacing: 0.5,
                                color: widget.isDarkTheme ? Colors.white : Colors.black87,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings options
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModernSettingsOption('language', '🌐', appLoc.language, ''),
                      const SizedBox(height: 12),
                      _buildModernSettingsOption('theme', '🎨', appLoc.theme, ''),
                      const SizedBox(height: 12),
                      _buildModernSettingsOption('about', 'ℹ️', appLoc.aboutTitle, ''),
                    ],
                  ),
                ),
                // Cancel button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: widget.isDarkTheme ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      appLoc.cancel,
                      style: TextStyle(
                        color: widget.isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (selected == 'language') {
      _showLanguageDialog();
    } else if (selected == 'theme') {
      widget.onThemeChanged?.call();
    } else if (selected == 'about') {
      _showAboutDialog();
    }
  }

  void _showAboutDialog() {
    final appLoc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.isDarkTheme 
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: widget.isDarkTheme 
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF0F2F5), Color(0xFFE8ECF0)],
                      ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'ℹ️',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLoc.aboutTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              letterSpacing: 0.5,
                              color: widget.isDarkTheme ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      appLoc.aboutDescription,
                      style: TextStyle(
                        color: widget.isDarkTheme ? Colors.white.withOpacity(0.8) : Colors.black87.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appLoc.aboutTakeTour,
                      style: TextStyle(
                        color: widget.isDarkTheme ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              // Tour button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // OnboardingScreen silindi, sadece dialog'u kapat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                  child: Text(
                    appLoc.aboutTakeTourButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Close button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: widget.isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    appLoc.close,
                    style: TextStyle(
                      color: widget.isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  void _showLanguageDialog() async {
    final appLoc = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: widget.isDarkTheme 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                  ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: widget.isDarkTheme 
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF0F2F5), Color(0xFFE8ECF0)],
                        ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: widget.isDarkTheme 
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                              )
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                              ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDarkTheme 
                                ? const Color(0xFF6B7280).withOpacity(0.4)
                                : const Color(0xFF9CA3AF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLoc.selectLanguage,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                letterSpacing: 0.5,
                                color: widget.isDarkTheme ? Colors.white : Colors.black87,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Language options
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModernLangOption('tr', '🇹🇷 Türkçe'),
                      const SizedBox(height: 12),
                      _buildModernLangOption('en', '🇬🇧 English'),
                      const SizedBox(height: 12),
                      _buildModernLangOption('es', '🇪🇸 Español'),
                      const SizedBox(height: 12),
                      _buildModernLangOption('ko', '🇰🇷 한국어'),
                    ],
                  ),
                ),
                // Cancel button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: widget.isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      appLoc.cancel,
                      style: TextStyle(
                        color: widget.isDarkTheme ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && selected != _currentLocale.languageCode) {
      _handleLocaleChange(Locale(selected));
    }
  }

  Widget _buildModernSettingsOption(String code, String icon, String label, String subtitle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, code),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.isDarkTheme ? Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDarkTheme ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDarkTheme ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Color(0xFF3D3D3D) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDarkTheme ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isDarkTheme ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: widget.isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.isDarkTheme ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: widget.isDarkTheme ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLangOption(String code, String label) {
    final isSelected = _currentLocale.languageCode == code;
    return GestureDetector(
      onTap: () => Navigator.pop(context, code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.isDarkTheme ? Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? (widget.isDarkTheme ? Colors.blue.withOpacity(0.5) : Colors.blue.withOpacity(0.3))
              : (widget.isDarkTheme ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? (widget.isDarkTheme ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2))
                : Colors.black.withOpacity(widget.isDarkTheme ? 0.3 : 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
                color: isSelected 
                  ? Colors.blue 
                  : (widget.isDarkTheme ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != null && widget.currentLocale != _currentLocale) {
      _handleLocaleChange(widget.currentLocale!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          widget.isDarkTheme
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A183D),
                        Color(0xFF1B2A4D),
                        Color(0xFF233A5E),
                        Color(0xFFFFFFFF),
                      ],
                    ),
                  ),
                )
              : const _WavyBackground(),
          // Sağ üst köşeye ayarlar ikonu
          Positioned(
            top: 32,
            right: 24,
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white, size: 32),
              onPressed: _showSettingsDialog,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Uygulama logosu (amblem)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logom.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    appLoc.gallerySlogan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    appLoc.mainScreenSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Başla butonu
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: DebouncedButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GalleryAlbumListScreen()),
                        );
                      },
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        icon: const Icon(Icons.photo, color: Colors.white, size: 24),
                        label: Text(appLoc.start, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: null, // DebouncedButton üstte olduğu için null
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Silinenler butonu - aynı boyutta
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: DebouncedButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RecentlyDeletedScreen()),
                        );
                      },
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D327A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                        label: Text(appLoc.recentlyDeleted, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: null, // DebouncedButton üstte olduğu için null
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dalgalı arka plan (gallery_cleaner_screen.dart ile aynı)
class _WavyBackground extends StatelessWidget {
  const _WavyBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB24592),
            Color(0xFFF15F79),
            Color(0xFF6D327A),
            Color(0xFF1E3C72),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _WavesPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF6D327A).withOpacity(0.18);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.15, size.width, size.height * 0.2);
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    paint.color = const Color(0xFFF15F79).withOpacity(0.12);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.75, size.width * 0.5, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 