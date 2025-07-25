import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'gallery_album_list_screen.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatelessWidget {
  final void Function(Locale)? onLocaleChanged;
  final Locale? currentLocale;
  const MainScreen({super.key, this.onLocaleChanged, this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _WavyBackground(),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo kaldırıldı
                  // const SizedBox(height: 36),
                  Text(
                    appLoc.mainScreenTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: Text(appLoc.onboardingTitle1, style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: const Icon(Icons.photo),
                    label: Text(appLoc.start, style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => GalleryAlbumListScreen()),
                      );
                    },
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