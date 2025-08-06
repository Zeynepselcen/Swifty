import 'package:flutter/material.dart';
import '../widgets/figma_design_widgets.dart';

class FigmaOnboardingScreen extends StatefulWidget {
  const FigmaOnboardingScreen({super.key});

  @override
  State<FigmaOnboardingScreen> createState() => _FigmaOnboardingScreenState();
}

class _FigmaOnboardingScreenState extends State<FigmaOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Figma'dan alınan sayfa verileri
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Swifty Gallery\'e Hoş Geldiniz',
      subtitle: 'Galerinizi akıllıca yönetin ve temizleyin',
      image: 'assets/figma_designs/onboarding_1.png',
      description: 'Fotoğraf ve videolarınızı kolayca organize edin',
    ),
    OnboardingPage(
      title: 'Duplikat Fotoğrafları Bulun',
      subtitle: 'Akıllı algoritma ile tekrarlanan dosyaları tespit edin',
      image: 'assets/figma_designs/onboarding_2.png',
      description: 'Aynı fotoğrafları otomatik olarak bulun',
    ),
    OnboardingPage(
      title: 'Güvenli Temizlik',
      subtitle: 'Önemli dosyalarınızı koruyarak temizlik yapın',
      image: 'assets/figma_designs/onboarding_3.png',
      description: 'Güvenli silme işlemi ile alan kazanın',
    ),
    OnboardingPage(
      title: 'Hızlı ve Kolay',
      subtitle: 'Tek dokunuşla galerinizi temizleyin',
      image: 'assets/figma_designs/onboarding_4.png',
      description: 'Basit arayüz ile hızlı temizlik',
    ),
    OnboardingPage(
      title: 'Başlayalım!',
      subtitle: 'Galerinizi temizlemeye hazır mısınız?',
      image: 'assets/figma_designs/onboarding_5.png',
      description: 'Hemen başlayın ve alan kazanın',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaDesignWidgets.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FigmaDesignWidgets.largeRadius),
                color: FigmaDesignWidgets.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FigmaDesignWidgets.largeRadius),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: FigmaDesignWidgets.secondaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.photo_library,
                        size: 80.0,
                        color: FigmaDesignWidgets.secondaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32.0),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28.0, // Headline Medium
              fontWeight: FontWeight.w600,
              color: FigmaDesignWidgets.onSurfaceColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16.0),
          
          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18.0, // Title Large
              fontWeight: FontWeight.w500,
              color: FigmaDesignWidgets.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8.0),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16.0, // Body Large
              color: FigmaDesignWidgets.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? FigmaDesignWidgets.primaryColor
                      : FigmaDesignWidgets.secondaryColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Navigation Buttons
          Row(
            children: [
              // Skip Button
              if (_currentPage < _pages.length - 1)
                Expanded(
                  child: FigmaWidgets.figmaButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    text: 'Atla',
                    isPrimary: false,
                  ),
                ),
              
              if (_currentPage < _pages.length - 1) const SizedBox(width: 16.0),
              
              // Next/Get Started Button
              Expanded(
                child: FigmaWidgets.figmaButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to main screen
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                  },
                  text: _currentPage < _pages.length - 1 ? 'İleri' : 'Başla',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String image;
  final String description;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
  });
} 