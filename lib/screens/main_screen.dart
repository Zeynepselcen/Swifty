import 'package:flutter/material.dart';
import 'gallery_album_list_screen.dart';
import 'recently_deleted_screen.dart';
import 'onboarding_screen.dart';
import '../widgets/debounced_button.dart';
import '../theme/app_colors.dart'; // Renk teması import'u

import 'dart:io';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MainScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  final Locale? currentLocale;
  final bool isDarkTheme;
  final VoidCallback? onThemeChanged;
  const MainScreen({super.key, this.onLocaleChanged, this.currentLocale, this.isDarkTheme = false, this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  Locale _currentLocale = const Locale('tr');
  int _deletedFilesCount = 0;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentLocale = widget.currentLocale ?? const Locale('tr');
    
    // Eğer widget.currentLocale null ise, varsayılan dil kullan
    if (widget.currentLocale == null) {
      _currentLocale = const Locale('tr');
    }
    
    _loadDeletedFilesCount();
    _checkFirstTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldiğinde sayacı yenile
      _loadDeletedFilesCount();
    }
  }

  Future<void> _loadDeletedFilesCount() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final deletedFilesPath = '${appDir.path}/deleted_files.json';
      final deletedFilesFile = File(deletedFilesPath);

      if (await deletedFilesFile.exists()) {
        final content = await deletedFilesFile.readAsString();
        if (content.isNotEmpty) {
          final files = List<Map<String, dynamic>>.from(
            json.decode(content) as List
          );

          // Süresi dolmamış dosyaları filtrele
          final now = DateTime.now().millisecondsSinceEpoch;
          final validFiles = files.where((file) {
            final expiresAt = file['expiresAt'] as int;
            return now < expiresAt;
          }).toList();

          setState(() {
            _deletedFilesCount = validFiles.length;
          });
        } else {
          // JSON dosyası boşsa sayacı sıfırla
          setState(() {
            _deletedFilesCount = 0;
          });
        }
      } else {
        // JSON dosyası yoksa sayacı sıfırla
        setState(() {
          _deletedFilesCount = 0;
        });
      }
    } catch (e) {
      print('Silinen dosya sayısı yüklenirken hata: $e');
      // Hata durumunda da sayacı sıfırla
      setState(() {
        _deletedFilesCount = 0;
      });
    }
  }

    Future<void> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final lastVersion = prefs.getString('lastAppVersion');

      // Sadece yeni versiyon yüklendiyse turu başlat
      if (lastVersion == null || lastVersion != currentVersion) {
        // Yeni versiyon kaydet
        await prefs.setString('lastAppVersion', currentVersion);

        // Kısa bir gecikme ile turu başlat
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        });
      }
    } catch (e) {
      print('İlk defa kontrolü sırasında hata: $e');
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
                  decoration: BoxDecoration(
                    gradient: widget.isDarkTheme
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.darkAccent,
                              AppColors.darkAccentLight,
                            ],
                          )
                        : AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDarkTheme
                            ? Colors.black.withOpacity(0.3)
                            : AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      appLoc.cancel,
                      style: TextStyle(
                        color: AppColors.textPrimary,
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
      // Direkt turu başlat
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    );
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
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Arka plan - Tema moduna göre değişir
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMainGradient
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFF8FA), // Çok açık soft pembe
                        const Color(0xFFFFF0F5), // Açık soft pembe
                        const Color(0xFFF8F0FF), // Açık soft mor
                      ],
                    ),
            ),
          ),

          // Sağ üst köşeye ayarlar ikonu
          Positioned(
            top: 32,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.settings, 
                  color: widget.isDarkTheme ? AppColors.darkAccent : AppColors.primary, 
                  size: 24
                ),
                onPressed: _showSettingsDialog,
              ),
            ),
          ),
          // Ana içerik
          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCardBackground
                      : AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : AppColors.cardShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Uygulama logosu
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.mainGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/logom.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Ana başlık - dil desteği ile
                    Text(
                      appLoc.appTitle,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    
                    // Alt başlık - dil desteği ile
                    Text(
                      appLoc.mainScreenSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Başla butonu - beyaz arka planlı, yuvarlatılmış köşeli
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: DebouncedButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => GalleryAlbumListScreen()),
                          );
                        },
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkButtonBackground
                                : AppColors.textPrimary,
                            foregroundColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkAccent
                                : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkAccent.withOpacity(0.2)
                                    : AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 2,
                            shadowColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : AppColors.cardShadow,
                          ),
                          icon: Icon(
                            Icons.photo, 
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.primary, 
                            size: 20
                          ),
                          label: Text(
                            appLoc.start,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                          onPressed: null, // DebouncedButton üstte olduğu için null
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Son Silinenler butonu - tema moduna göre arka plan
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: Theme.of(context).brightness == Brightness.dark
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.darkAccent,
                                  AppColors.darkAccentLight,
                                ],
                              )
                            : AppColors.mainGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : AppColors.cardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DebouncedButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RecentlyDeletedScreen()),
                          );
                          // Geri dönünce her zaman sayacı yenile
                          _loadDeletedFilesCount();
                          
                          // Eğer galeri yenilendi ise, ana ekranı da yenile
                          if (result == true) {
                            print('DEBUG: Galeri yenilendi, ana ekran yenileniyor...');
                            setState(() {
                              // UI'yi yenile
                            });
                          }
                        },
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.delete_outline, color: AppColors.textPrimary, size: 20),
                          label: Text(
                            _deletedFilesCount > 0 
                              ? '${appLoc.recentlyDeleted} ($_deletedFilesCount)' 
                              : appLoc.recentlyDeleted, 
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          onPressed: null, // DebouncedButton üstte olduğu için null
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 
 
 