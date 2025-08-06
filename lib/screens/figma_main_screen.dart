import 'package:flutter/material.dart';
import '../widgets/figma_design_widgets.dart';

class FigmaMainScreen extends StatefulWidget {
  const FigmaMainScreen({super.key});

  @override
  State<FigmaMainScreen> createState() => _FigmaMainScreenState();
}

class _FigmaMainScreenState extends State<FigmaMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaDesignWidgets.backgroundColor,
      appBar: FigmaWidgets.figmaTopAppBar(
        title: 'Swifty Gallery',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FigmaWidgets.figmaFAB(
        onPressed: () {
          // Clean gallery action
        },
        icon: Icons.cleaning_services,
        label: 'Temizle',
      ),
      bottomNavigationBar: FigmaWidgets.figmaBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services),
            label: 'Temizle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildGalleryScreen();
      case 2:
        return _buildCleanScreen();
      case 3:
        return _buildSettingsScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          FigmaWidgets.figmaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Galerinizi Temizleyin',
                  style: TextStyle(
                    fontSize: 24.0, // Headline Medium
                    fontWeight: FontWeight.w600,
                    color: FigmaDesignWidgets.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Duplikat fotoğrafları bulun ve silin',
                  style: TextStyle(
                    fontSize: 16.0, // Body Large
                    color: FigmaDesignWidgets.secondaryColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                FigmaWidgets.figmaButton(
                  onPressed: () {
                    // Start cleaning action
                  },
                  text: 'Temizlemeye Başla',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Gallery Preview
          Text(
            'Son Fotoğraflar',
            style: TextStyle(
              fontSize: 20.0, // Headline Small
              fontWeight: FontWeight.w600,
              color: FigmaDesignWidgets.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Gallery Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FigmaDesignWidgets.mediumRadius),
                  color: FigmaDesignWidgets.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FigmaDesignWidgets.mediumRadius),
                  child: Container(
                    color: FigmaDesignWidgets.secondaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.photo,
                      color: FigmaDesignWidgets.secondaryColor,
                      size: 32.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryScreen() {
    return const Center(
      child: Text('Galeri Ekranı'),
    );
  }

  Widget _buildCleanScreen() {
    return const Center(
      child: Text('Temizleme Ekranı'),
    );
  }

  Widget _buildSettingsScreen() {
    return const Center(
      child: Text('Ayarlar Ekranı'),
    );
  }
} 