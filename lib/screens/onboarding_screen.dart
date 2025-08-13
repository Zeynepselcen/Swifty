import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'gallery_album_list_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Galerinizi Keşfedin',
      description: 'Fotoğraflarınızı klasörler halinde görüntüleyin ve organize edin. Her klasördeki fotoğraf sayısını kolayca görebilirsiniz.',
      icon: Icons.folder,
      color: null, // Tema rengini kullan
    ),
    OnboardingPage(
      title: 'Tarih Görünümü',
      description: 'Fotoğraflarınızı aylara göre gruplandırın. Hangi ayda kaç fotoğraf çektiğinizi kolayca takip edin.',
      icon: Icons.calendar_today,
      color: null, // Tema rengini kullan
    ),
    OnboardingPage(
      title: 'Kaydırarak Silin',
      description: 'Fotoğrafları sola kaydırarak silin. Silinen fotoğraflar 30 gün boyunca "Son Silinenler" klasöründe saklanır.',
      icon: Icons.swipe_left,
      color: null, // Tema rengini kullan
    ),
    OnboardingPage(
      title: 'Beğendiklerinizi Saklayın',
      description: 'Fotoğrafları sağa kaydırarak beğenin. Beğendiğiniz fotoğraflar güvende kalır.',
      icon: Icons.favorite,
      color: null, // Tema rengini kullan
    ),
    OnboardingPage(
      title: 'Son Silinenler',
      description: 'Yanlışlıkla sildiğiniz fotoğrafları "Son Silinenler" klasöründen geri alabilirsiniz. 30 gün süreniz var!',
      icon: Icons.restore,
      color: null, // Tema rengini kullan
    ),
    OnboardingPage(
      title: 'Hazırsınız!',
      description: 'Artık galerinizi profesyonelce yönetebilirsiniz. Başlamak için "Başla" butonuna tıklayın.',
      icon: Icons.check_circle,
      color: null, // Tema rengini kullan
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Tur bittiğinde galeri ekranına git
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GalleryAlbumListScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundPrimary : AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
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
                  final page = _pages[index];
                  return _buildPage(page, isDark);
                },
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: _previousPage,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? AppColors.darkAccent : AppColors.accent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Geri',
                          style: TextStyle(
                            color: isDark ? AppColors.darkAccent : AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: 12),
                  
                  // Next/Finish button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: (isDark ? AppColors.darkAccent : AppColors.accent).withOpacity(0.3),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Başla' : 'İleri',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark) {
    // Tema rengini kullan
    final themeColor = isDark ? AppColors.darkAccent : AppColors.accent;
    final pageColor = page.color ?? themeColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: pageColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: pageColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: pageColor,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color? color; // Nullable yap

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.color, // Optional yap
  });
} 