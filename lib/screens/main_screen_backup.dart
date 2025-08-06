import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
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
  int _forceReloadCounter = 0; // Hot reload için zorlama sayacı
  Key _localizationsKey = UniqueKey(); // AppLocalizations için unique key

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.currentLocale ?? const Locale('tr');
  }

  void _showLanguageDialog() async {
    final appLoc = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLoc.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                _buildLangOption('tr', '🇹🇷 Türkçe'),
                const SizedBox(height: 8),
                _buildLangOption('en', '🇬🇧 English'),
                const SizedBox(height: 8),
                _buildLangOption('es', '🇪🇸 Español'),
                const SizedBox(height: 8),
                _buildLangOption('ko', '🇰🇷 한국어'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLoc.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && selected != _currentLocale.languageCode) {
      setState(() {
        _currentLocale = Locale(selected);
        _forceReloadCounter++; // Hot reload için zorlama
        _localizationsKey = UniqueKey(); // AppLocalizations'ı zorla yenile
      });
      widget.onLocaleChanged?.call(Locale(selected));
      
      // Dil değişikliği sonrası UI'ı zorla yenile
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _forceReloadCounter++; // Hot reload için zorlama
            _localizationsKey = UniqueKey(); // AppLocalizations'ı zorla yenile
          });
          
          // Daha güçlü yenileme - 3 kez setState çağır
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _forceReloadCounter++;
                _localizationsKey = UniqueKey();
              });
            }
          });
          
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _forceReloadCounter++;
                _localizationsKey = UniqueKey();
              });
            }
          });
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _forceReloadCounter++;
                _localizationsKey = UniqueKey();
              });
            }
          });
        }
      });
    }
  }



  void _showGalleryOptions() async {
    final appLoc = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLoc.galleryOptions, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                _buildGalleryOption('android', '📱 ${appLoc.androidGallery}', '${appLoc.androidGalleryDesc}'),
                const SizedBox(height: 8),
                _buildGalleryOption('trash', '🗑️ ${appLoc.recentlyDeleted}', '${appLoc.recentlyDeletedDesc}'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLoc.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (selected == 'android') {
      // Android galerisini aç
      try {
        final Uri uri = Uri.parse('content://media/external/images/media');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Alternatif olarak galeri uygulamasını aç
          final galleryUri = Uri.parse('content://media/external/file');
          if (await canLaunchUrl(galleryUri)) {
            await launchUrl(galleryUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Galeri uygulaması açılamadı. Manuel olarak galeri uygulamasını açabilirsiniz.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Galeri uygulaması açılamadı. Manuel olarak galeri uygulamasını açabilirsiniz.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else if (selected == 'trash') {
      // Android'in kendi çöp kutusunu aç
      try {
        final trashUri = Uri.parse('content://media/external/images/media/trash');
        if (await canLaunchUrl(trashUri)) {
          await launchUrl(trashUri);
        } else {
          // Alternatif olarak dosya yöneticisini aç
          final fileUri = Uri.parse('file:///storage/emulated/0/DCIM/.trash');
          if (await canLaunchUrl(fileUri)) {
            await launchUrl(fileUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Çöp kutusu açılamadı. Manuel olarak dosya yöneticisinden DCIM/.trash klasörüne gidebilirsiniz.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çöp kutusu açılamadı. Manuel olarak dosya yöneticisinden DCIM/.trash klasörüne gidebilirsiniz.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget _buildGalleryOption(String code, String label, String subtitle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB24592), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFB24592), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(String code, String label) {
    final isSelected = _currentLocale.languageCode == code;
    return GestureDetector(
      onTap: () => Navigator.pop(context, code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB24592).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: const Color(0xFFB24592), width: 2) : null,
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, color: Color(0xFFB24592)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != null && widget.currentLocale != _currentLocale) {
      setState(() {
        _currentLocale = widget.currentLocale!;
      });
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
          // Tema değiştirme switch'i sağ üstte
          Positioned(
            top: 32,
            left: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isLargeScreen = screenWidth > 400;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isDarkTheme ? appLoc.darkTheme : appLoc.lightTheme,
                      style: TextStyle(
                        color: widget.isDarkTheme ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 16 : 15,
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 12 : 8),
                    Switch(
                      value: widget.isDarkTheme,
                      onChanged: (val) {
                        widget.onThemeChanged?.call();
                      },
                      activeColor: const Color(0xFF0A183D),
                      inactiveThumbColor: const Color(0xFF1B2A4D),
                      inactiveTrackColor: Colors.white70,
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 32,
            right: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ekran genişliğine göre buton pozisyonunu ayarla
                final screenWidth = MediaQuery.of(context).size.width;
                final isLargeScreen = screenWidth > 400;
                
                return GestureDetector(
                  onTap: _showLanguageDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 16 : 14, 
                      vertical: isLargeScreen ? 10 : 8
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: Colors.white, size: isLargeScreen ? 24 : 22),
                        SizedBox(width: isLargeScreen ? 8 : 6),
                        Text(
                          _currentLocale.languageCode == 'tr' ? 'TR' : _currentLocale.languageCode == 'es' ? 'ES' : _currentLocale.languageCode == 'ko' ? 'KO' : 'EN',
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: isLargeScreen ? 18 : 16
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                  DebouncedButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DB6AC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                      label: Text(appLoc.welcome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      onPressed: null, // DebouncedButton üstte olduğu için null
                    ),
                  ),
                  const SizedBox(height: 18),
                  DebouncedButton(
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
                  const SizedBox(height: 18),
                  DebouncedButton(
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



                ],
              ),
            ),
          ),

        ],
      ),
    );
          },
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