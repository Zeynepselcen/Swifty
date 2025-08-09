import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import '../models/photo_item.dart';
import '../services/gallery_service.dart';
import '../widgets/debounced_button.dart';

enum Direction { left, right }

class GalleryCleanerScreen extends StatefulWidget {
  final bool isVideoMode;
  final String albumName;
  final String? albumId;
  final List<PhotoItem>? photos;
  final Function(int)? onPhotosDeleted;

  const GalleryCleanerScreen({
    Key? key,
    required this.isVideoMode,
    required this.albumName,
    this.albumId, 
    this.photos, 
    this.onPhotosDeleted,
  }) : super(key: key);

  @override
  State<GalleryCleanerScreen> createState() => _GalleryCleanerScreenState();
}

class _GalleryCleanerScreenState extends State<GalleryCleanerScreen> with WidgetsBindingObserver {
  List<String> toDelete = []; // Sola kaydırılan fotoğrafların id'leri
  List<Map<String, dynamic>> deletedPhotos = []; // Silinen fotoğrafların listesi (photo ve index ile)
  bool _batchDialogShown = false;
  Map<int, VideoPlayerController> _videoControllers = {};
  bool isLoading = true;
  int currentIndex = 0;
  List<PhotoItem> photos = [];
  int totalSize = 0; // Toplam dosya boyutu
  int freedSpace = 0; // Açılan yer
  Direction? _swipeDirection;
  
  // Swipe gesture için değişkenler
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;
  double _dragOffset = 0.0;
  double _cardRotation = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPhotos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllVideoControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _disposeAllVideoControllers();
    }
  }

  Future<void> _loadPhotos() async {
    try {
      if (widget.photos != null) {
        setState(() {
          photos = widget.photos!;
          isLoading = false;
        });
        } else {
        final assets = await GalleryService.loadPhotosFromAlbum(widget.albumName);
        
        setState(() {
          photos = assets;
          isLoading = false;
        });
      }
      
      // Toplam dosya boyutunu hesapla
      _calculateTotalSize();
    } catch (e) {
      print('Fotoğraflar yüklenirken hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Toplam dosya boyutunu hesapla
  Future<void> _calculateTotalSize() async {
    int total = 0;
    for (final photo in photos) {
      if (photo.path != null) {
        final file = File(photo.path!);
        if (await file.exists()) {
          total += await file.length();
        }
      }
    }
    setState(() {
      totalSize = total;
    });
  }

  // Açılan yer miktarını hesapla
  void _updateFreedSpace() {
    int freed = 0;
    for (final deletedPhoto in deletedPhotos) {
      final photo = deletedPhoto['photo'] as PhotoItem;
      if (photo.path != null) {
        final file = File(photo.path!);
        if (file.existsSync()) {
          freed += file.lengthSync();
        }
      }
    }
    setState(() {
      freedSpace = freed;
    });
  }

  void _onSwipe(Direction dir, int index) {
    if (index >= photos.length) return;

    // Video controller'ı durdur
    final currentController = _videoControllers[index];
    if (currentController != null && currentController.value.isPlaying) {
      currentController.pause();
    }

    setState(() {
      if (dir == Direction.left) {
        toDelete.add(photos[index].id);
        // Silinen fotoğrafı listeye ekle
        deletedPhotos.add({
          'photo': photos[index],
          'index': index,
        });
        print('DEBUG: Fotoğraf silinecekler listesine eklendi: ${photos[index].id}');
        
        // Açılan yer miktarını güncelle
        _updateFreedSpace();
      } else if (dir == Direction.right) {
        // Sağa kaydırma - beğeni
        print('DEBUG: Fotoğraf beğenildi: ${photos[index].id}');
      }
      currentIndex++;
    });

    // Görünmeyen video controller'ları temizle
    _disposeInvisibleVideoControllers();

    // Eğer son fotoğrafa geldiyse ana ekrana dön
    if (currentIndex >= photos.length) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _disposeInvisibleVideoControllers() {
    final visibleControllers = <int>{};
    for (int i = currentIndex; i < currentIndex + 3 && i < photos.length; i++) {
      visibleControllers.add(i);
    }

    _videoControllers.forEach((index, controller) {
      if (!visibleControllers.contains(index)) {
        controller.dispose();
        _videoControllers.remove(index);
      }
    });
  }

  void _disposeAllVideoControllers() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  Future<int> getFileSize(String? path) async {
    if (path == null) return 0;
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Dosya boyutu alınırken hata: $e');
    }
    return 0;
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(1)} ${sizes[i]}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        if (deletedPhotos.isNotEmpty) {
          final shouldPop = await showDialog<bool>(
      context: context,
            builder: (context) => AlertDialog(
              title: const Text('Uyarı'),
              content: const Text('Silinen fotoğraflar var. Çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Çık'),
          ),
        ],
      ),
    );
          
          if (shouldPop == true) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
          } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
                          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  Color(0xFF0A0A2E), // Koyu lacivert (dark mode)
                  Color(0xFF1A1A4E), // Orta lacivert (dark mode)
                  Color(0xFF2A2A6E), // Açık lacivert (dark mode)
                ]
              : [
                  Color(0xFFF8F9FA), // Çok açık gri (light mode)
                  Color(0xFFE9ECEF), // Açık gri (light mode)
                  Color(0xFFDEE2E6), // Orta gri (light mode)
                ],
            ),
          ),
          child: Column(
            children: [
              // Üst bar
              _buildPreviewBar(),
              
              // Ana içerik
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Üst butonlar (Geri al ve Çöp kutusu)
                      if (deletedPhotos.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Geri al butonu
                              GestureDetector(
                                onTap: () => _restoreLastDeletedPhoto(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.undo, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Geri Al',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Çöp kutusu butonu
                              GestureDetector(
                                onTap: () => _showDeleteConfirmation(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Sil (${deletedPhotos.length})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Fotoğraf gösterim alanı
                      Expanded(
                        child: _buildPhotoDisplay(),
                      ),
                      
                      // Alt butonlar
                      _buildBottomButtons(),
                      
                      // Progress bar kaldırıldı - yeni tasarımda yok
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
                        ),
    );
  }

  Widget _buildPreviewBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = photos.isNotEmpty ? (currentIndex / photos.length) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
                      gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark 
            ? [
                Color(0xFF1A1A4E), // Koyu lacivert (dark mode)
                Color(0xFF2A2A6E), // Orta lacivert (dark mode)
                Color(0xFF3A3A8E), // Açık lacivert (dark mode)
              ]
            : [
                Color(0xFFE91E63), // Pembe (light mode)
                Color(0xFF9C27B0), // Mor (light mode)
                Color(0xFF673AB7), // Koyu mor (light mode)
                        ],
                      ),
                    ),
              child: Column(
                children: [
          // Üst satır - Başlık ve kalan sayı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Fotoğraf Ayıklama",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Kalan fotoğraf sayısı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                      child: Text(
                  "${photos.length - currentIndex} KALAN",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                                      ),
                                    ],
                                  ),
          
          const SizedBox(height: 12),
          
          // Alt satır - İlerleme barı ve yer açma bilgisi
          Row(
            children: [
              // İlerleme barı
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                            ? [Colors.white, Colors.white.withOpacity(0.8)]
                            : [Colors.white, Colors.white.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Açılan yer bilgisi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_formatBytes(freedSpace)} AÇILDI",
                        style: const TextStyle(
                          color: Colors.white,
                    fontSize: 12,
                          fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDisplay() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.grey),
      );
    }

    if (currentIndex >= photos.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Bitti!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${_formatBytes(freedSpace)} yer açıldı",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
                                  builder: (context, constraints) {
        final maxCardWidth = (constraints.maxWidth * 0.92).clamp(280.0, 480.0);
        final maxCardHeight = (constraints.maxHeight * 0.75).clamp(350.0, 650.0);
        
        return Stack(
                                      children: [
            // Ana fotoğraf kartı
            Center(
                                          child: Container(
                width: maxCardWidth,
                height: maxCardHeight,
                                            decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                                          ),
                                          child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (currentIndex < photos.length) {
                                                  _showFullScreenImageWithActions(photos[currentIndex], currentIndex);
                                                }
                                              },
                                              onLongPress: () {
                                                print('DEBUG: Uzun basma algılandı');
                                                // Uzun basma ile silme
                                                _onSwipe(Direction.left, currentIndex);
                                              },
                                              onPanStart: (details) {
                                                print('DEBUG: Pan başladı');
                                                setState(() {
                                                  _startPosition = details.globalPosition;
                                                  _currentPosition = details.globalPosition;
                                                  _isDragging = true;
                                                  _dragOffset = 0.0;
                                                  _cardRotation = 0.0;
                                                });
                                              },
                                              onPanUpdate: (details) {
                                                setState(() {
                                                  _currentPosition = details.globalPosition;
                                                  _dragOffset = details.globalPosition.dx - _startPosition.dx;
                                                  _cardRotation = _dragOffset * 0.015; // Daha belirgin rotasyon
                                                });
                                              },
                                              onPanEnd: (details) {
                                                print('DEBUG: Pan bitti');
                                                setState(() {
                                                  _isDragging = false;
                                                  _dragOffset = 0.0;
                                                  _cardRotation = 0.0;
                                                });
                                                
                                                final deltaX = _currentPosition.dx - _startPosition.dx;
                                                final deltaY = _currentPosition.dy - _startPosition.dy;
                                                
                                                print('DEBUG: Kaydırma mesafesi - X: $deltaX, Y: $deltaY');
                                                
                                                // Yatay kaydırma için minimum mesafe - daha da düşük
                                                if (deltaX.abs() > 20 && deltaX.abs() > deltaY.abs()) {
                                                  if (deltaX > 0) {
                                                    // Sağa kaydırma - beğeni
                                                    print('DEBUG: Sağa kaydırma algılandı');
                                                    _onSwipe(Direction.right, currentIndex);
                                                  } else {
                                                    // Sola kaydırma - silme
                                                    print('DEBUG: Sola kaydırma algılandı');
                                                    _onSwipe(Direction.left, currentIndex);
                                                  }
                                                }
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                transform: Matrix4.translationValues(_dragOffset * 0.3, 0, 0)
                                                  ..rotateZ(_cardRotation),
                                                child: Container(
                                                  width: maxCardWidth,
                                                  height: maxCardHeight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(25),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 5),
                                                      ),
                                                    ],
                                                  ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(25),
                                                      child: Stack(
                                                        children: [
                                                          // Ana fotoğraf
                                                          _buildCurrentPhoto(maxCardWidth, maxCardHeight),
                                                          
                                                          // Üst köşe - büyüteç butonu
                                                          Positioned(
                                                            top: 12,
                                                            right: 12,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                if (currentIndex < photos.length) {
                                                                  _showFullScreenImageWithActions(photos[currentIndex], currentIndex);
                                                                }
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.all(8),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.9),
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.2),
                                                                      blurRadius: 4,
                                                                      offset: const Offset(0, 2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: const Icon(
                                                                  Icons.search,
                                                                  color: Colors.black87,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          
                                                          // Alt köşe - dosya boyutu
                                                          Positioned(
                                                            bottom: 12,
                                                            left: 12,
                                                            child: FutureBuilder<int>(
                                                              future: getFileSize(photos[currentIndex].path),
                                                              builder: (context, snapshot) {
                                                                final fileSize = snapshot.data ?? 0;
                                                                final readableSize = _formatBytes(fileSize);
                                                                return Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.8),
                                                                    borderRadius: BorderRadius.circular(15),
                                                                  ),
                                                                  child: Text(
                                                                    readableSize,
                                                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          
                                                          // Kaydırma ipucu
                                                          Positioned(
                                                            bottom: 12,
                                                            right: 12,
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: Colors.black.withOpacity(0.6),
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(Icons.arrow_back, color: Colors.red, size: 16),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    'Sil',
                                                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Icon(Icons.arrow_forward, color: Colors.green, size: 16),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    'Beğen',
                                                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                ),
              ),
            ),
            

                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }

  Widget _buildCurrentPhoto(double width, double height) {
    final photo = photos[currentIndex];
    
    if (photo.type == MediaType.video) {
      return _buildVideoPlayer(photo, width, height);
    } else {
      return Container(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: GestureDetector(
            onTap: () {
              if (currentIndex < photos.length) {
                _showFullScreenImageWithActions(photos[currentIndex], currentIndex);
              }
            },
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.memory(
                photo.thumb,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: width,
                    height: height,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.grey, size: 64),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildVideoPlayer(PhotoItem photo, double width, double height) {
    final controller = _videoControllers[currentIndex];
    
    if (controller == null) {
      _loadVideoController(photo.id, currentIndex);
      return Container(
        width: width,
        height: height,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 8),
              Text(
                'Video yükleniyor...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: FittedBox(
                                                                  fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Video progress bar (sadece video için göster)
          if (currentIndex < photos.length && photos[currentIndex].type == MediaType.video)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Video progress bar
                  GestureDetector(
                    onTapDown: (details) {
                      final controller = _videoControllers[currentIndex];
                      if (controller != null && controller.value.isInitialized) {
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final localPosition = renderBox.globalToLocal(details.globalPosition);
                        final progress = localPosition.dx / renderBox.size.width;
                        final newPosition = Duration(milliseconds: (progress * controller.value.duration.inMilliseconds).round());
                        controller.seekTo(newPosition);
                        setState(() {});
                      }
                    },
                                                                  child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                                                    decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Builder(
                        builder: (context) {
                          final controller = _videoControllers[currentIndex];
                          if (controller != null && controller.value.isInitialized) {
                            final progress = controller.value.position.inMilliseconds / 
                                          controller.value.duration.inMilliseconds;
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                      ? [
                                          Color(0xFF8B5CF6), // Mor (dark mode)
                                          Color(0xFFA78BFA), // Açık mor (dark mode)
                                        ]
                                      : [
                                          Color(0xFFE91E63), // Pembe (light mode)
                                          Color(0xFF9C27B0), // Mor (light mode)
                                        ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }
                          return Container(
                                                                    decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                                                                    ),
                                                                  ),
                                                                ),
                  const SizedBox(height: 8),
                  // Video kontrol butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          final controller = _videoControllers[currentIndex];
                          if (controller != null && controller.value.isInitialized) {
                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (controller.value.isPlaying) {
                                      controller.pause();
                                    } else {
                                      controller.play();
                                    }
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: isDark ? Colors.purple.shade400 : Colors.purple.shade500,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
                                                                                            // Butonlar satırı
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    // Çöp kutusu butonu
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (currentIndex < photos.length) {
                                                          _onSwipe(Direction.left, currentIndex);
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.shade500,
                                                          borderRadius: BorderRadius.circular(30),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.3),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    
                                                    // Atla butonu
                                                    Container(
                                                      width: 120,
                                                      height: 60,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            if (currentIndex < photos.length) {
                                                              currentIndex++;
                                                            }
                                                          });
                                                          if (currentIndex >= photos.length) {
                                                            Future.delayed(const Duration(milliseconds: 500), () {
                                                              if (mounted) {
                                                                Navigator.of(context).pop();
                                                              }
                                                            });
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          foregroundColor: Colors.white,
                                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(35),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Color(0xFFE91E63), // Pembe
                                                                Color(0xFF9C27B0), // Mor
                                                              ],
                                                            ),
                                                            borderRadius: BorderRadius.circular(35),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.3),
                                                                blurRadius: 8,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              '> Atla',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    
                                                    // Kalp butonu
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (currentIndex < photos.length) {
                                                          _onSwipe(Direction.right, currentIndex);
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.shade500,
                                                          borderRadius: BorderRadius.circular(30),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.3),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
        ],
      ),
    );
  }

  // Video controller yükleme
  void _loadVideoController(String photoId, int index) async {
    try {
      // Önce mevcut controller'ı temizle
      final existingController = _videoControllers[index];
      if (existingController != null) {
        await existingController.dispose();
        _videoControllers.remove(index);
      }

      final photo = photos.firstWhere((p) => p.id == photoId);
      if (photo.path != null && photo.path!.isNotEmpty) {
        final file = File(photo.path!);
        if (await file.exists()) {
          final videoController = VideoPlayerController.file(file);
          
          // Initialize işlemini try-catch ile sar
          await videoController.initialize().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Video yükleme zaman aşımı');
            },
          );
          
          if (mounted) {
            setState(() {
              _videoControllers[index] = videoController;
            });
            
            // Video yüklendikten sonra otomatik oynat
            if (index == currentIndex) {
              await videoController.play();
            }
          } else {
            // Widget dispose edilmişse controller'ı temizle
            await videoController.dispose();
          }
        } else {
          print('Video dosyası bulunamadı: ${photo.path}');
        }
      }
    } catch (e) {
      print('Video yükleme hatası (ID: $photoId, Index: $index): $e');
      // Hata durumunda controller'ı temizle
      final existingController = _videoControllers[index];
      if (existingController != null) {
        await existingController.dispose();
        _videoControllers.remove(index);
      }
    }
  }

  // Full screen image gösterimi
  void _showFullScreenImageWithActions(PhotoItem photo, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
                  children: [
                // Tam ekran fotoğraf - zoom yapılabilir
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      photo.thumb,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Üst bar - geri butonu
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                // Alt bar - dosya bilgileri
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Text(
                          photo.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<int>(
                          future: getFileSize(photo.path),
                          builder: (context, snapshot) {
                            final fileSize = snapshot.data ?? 0;
                            final readableSize = _formatBytes(fileSize);
                            return Text(
                              'Boyut: $readableSize',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
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
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // Son silinen fotoğrafı geri al
  void _restoreLastDeletedPhoto() {
    if (deletedPhotos.isNotEmpty) {
      final lastDeleted = deletedPhotos.removeLast();
      final photo = lastDeleted['photo'] as PhotoItem;
      final index = lastDeleted['index'] as int;
      setState(() {
        // Silinen fotoğrafı geri ekle
        photos.insert(index, photo);
        currentIndex = index;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Son silinen fotoğraf geri alındı')),
      );
    }
  }

  // Kalıcı silme onayı
  void _showDeleteConfirmation() {
    if (deletedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silinecek fotoğraf bulunmuyor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
        builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Kalıcı Silme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deletedPhotos.length} fotoğraf kalıcı olarak silinecek:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: deletedPhotos.length,
                itemBuilder: (context, index) {
                  final deletedItem = deletedPhotos[index];
                  final photo = deletedItem['photo'] as PhotoItem;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        photo.thumb,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
          actions: [
            TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
            ),
            ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _permanentlyDeletePhotos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kalıcı Olarak Sil'),
            ),
          ],
        ),
      );
  }

  // Fotoğrafları kalıcı olarak sil
  void _permanentlyDeletePhotos() {
    final deletedCount = deletedPhotos.length;
    setState(() {
      deletedPhotos.clear();
    });
    
    // Callback'i çağır
    widget.onPhotosDeleted?.call(deletedCount);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm fotoğraflar kalıcı olarak silindi')),
    );
  }

  // Placeholder for _onWillPop
  Future<bool> _onWillPop() async {
    if (currentIndex < photos.length) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Emin misiniz?'),
          content: const Text("Silmek için kaydırın"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hayır'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet'),
          ),
        ],
      ),
    );
      return false;
    }
    return true;
  }
}

// Dalgalı arka plan için custom painter
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

 
 
 