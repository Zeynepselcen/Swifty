import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Hoş Geldin!',
      description: 'Galeri Temizleyici ile fotoğraflarını kolayca yönet, gereksizleri sil ve galerini ferahlat.',
      icon: Icons.waving_hand,
      color: Color(0xFFB24592),
    ),
    _OnboardingPageData(
      title: 'Kolay Kullanım',
      description: 'Fotoğrafları sağa kaydırarak sakla, sola kaydırarak silmek için işaretle. Hepsi bu kadar!',
      icon: Icons.swipe,
      color: Color(0xFF4DB6AC),
    ),
    _OnboardingPageData(
      title: 'Detaylı İnceleme',
      description: 'Fotoğraflara tıklayarak yakınlaştır ve detayları incele. Zoom ikonu ile kolay erişim!',
      icon: Icons.zoom_in,
      color: Color(0xFF6D327A),
    ),
    _OnboardingPageData(
      title: 'Gizliliğin Önceliğimiz',
      description: 'Uygulama sadece senin izninle galeriye erişir ve hiçbir verini paylaşmaz.',
      icon: Icons.privacy_tip,
      color: Color(0xFFF15F79),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      // Onboarding bittiğinde ana ekrana geç
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  String title = '';
                  String desc = '';
                  Color color = _pages[index].color;
                  IconData icon = _pages[index].icon;
                  if (index == 0) {
                    title = appLoc.onboardingTitle1;
                    desc = appLoc.onboardingDesc1;
                  } else if (index == 1) {
                    title = appLoc.onboardingTitle2;
                    desc = appLoc.onboardingDesc2;
                  } else if (index == 2) {
                    title = 'Detaylı İnceleme';
                    desc = 'Fotoğraflara tıklayarak yakınlaştır ve detayları incele. Zoom ikonu ile kolay erişim!';
                  } else if (index == 3) {
                    title = appLoc.onboardingTitle3;
                    desc = appLoc.onboardingDesc3;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(icon, color: color, size: 64),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? _pages[i].color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _nextPage,
                  child: Text(_currentPage == _pages.length - 1 ? appLoc.start : appLoc.next, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 