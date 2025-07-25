import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../services/gallery_service.dart';
import '../models/photo_item.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class GalleryCleanerScreen extends StatefulWidget {
  final String? albumId;
  final String? albumName;
  final List<PhotoItem>? photos;
  final bool isVideoMode;
  const GalleryCleanerScreen({super.key, this.albumId, this.albumName, this.photos, this.isVideoMode = false});

  @override
  State<GalleryCleanerScreen> createState() => _GalleryCleanerScreenState();
}

class _GalleryCleanerScreenState extends State<GalleryCleanerScreen> {
  List<PhotoItem> photos = [];
  int currentIndex = 0;
  bool isLoading = true;
  final CardSwiperController _swiperController = CardSwiperController();
  bool _permissionDenied = false;
  bool _galleryPermissionGranted = false;
  List<String> toDelete = []; // Sola kaydırılan fotoğrafların id'leri
  bool _batchDialogShown = false;
  Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.photos != null) {
      photos = List<PhotoItem>.from(widget.photos!);
      isLoading = false;
    } else {
      _initGallery();
    }
  }

  @override
  void dispose() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _initGallery() async {
    // Toplu izin iste
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      setState(() {
        isLoading = false;
        _permissionDenied = true;
        _galleryPermissionGranted = false;
      });
      _showPermissionDeniedDialog();
      return;
    }
    setState(() {
      _galleryPermissionGranted = true;
      _permissionDenied = false;
    });
    List<PhotoItem> loadedPhotos;
    if (widget.albumId != null) {
      loadedPhotos = await GalleryService.loadPhotosFromAlbum(widget.albumId!);
    } else {
      loadedPhotos = await GalleryService.loadPhotos();
    }
    loadedPhotos.shuffle();
    setState(() {
      photos = loadedPhotos;
      isLoading = false;
    });
  }

  Future<bool> _ensureGalleryPermission() async {
    if (_galleryPermissionGranted) return true;
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      setState(() {
        _permissionDenied = true;
        _galleryPermissionGranted = false;
      });
      _showPermissionDeniedDialog();
      return false;
    }
    setState(() {
      _galleryPermissionGranted = true;
      _permissionDenied = false;
    });
    return true;
  }

  void _showPermissionDeniedDialog() {
    final appLoc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLoc.permissionRequiredTitle),
        content: Text(appLoc.permissionRequiredContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLoc.ok),
          ),
        ],
      ),
    );
  }

  void _onSwipe(Direction dir, int index) async {
    if (dir == Direction.left) {
      // Sadece silinecekler listesine ekle
      toDelete.add(photos[index].id);
    }
    setState(() {
      currentIndex++;
      // --- Video controller temizliği ---
      _videoControllers.removeWhere((i, controller) {
        if (i < currentIndex || i > currentIndex) {
          controller.pause();
          controller.dispose();
          return true;
        }
        return false;
      });
    });
    // Eğer son fotoğrafı geçtiysek, toplu silme onayı iste (sadece bir kez)
    if (currentIndex >= photos.length && toDelete.isNotEmpty && !_batchDialogShown) {
      _batchDialogShown = true;
      await Future.delayed(const Duration(milliseconds: 400)); // Animasyon için küçük gecikme
      _showBatchDeleteDialog();
    }
  }

  void _showBatchDeleteDialog() async {
    final appLoc = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(appLoc.deletePhotosDialogTitle),
        content: Text(appLoc.deletePhotosDialogContent(toDelete.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appLoc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appLoc.delete),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _deleteBatch();
    } else {
      // Kullanıcı vazgeçerse listeyi temizle
      setState(() { toDelete.clear(); });
    }
    // Onay veya iptal sonrası tekrar dialog açılmasın diye flag'i sıfırla
    setState(() { _batchDialogShown = false; });
  }

  Future<void> _deleteBatch() async {
    final appLoc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    int deleted = 0;
    if (toDelete.isNotEmpty) {
      try {
        await PhotoManager.editor.deleteWithIds(toDelete);
        deleted = toDelete.length;
      } catch (_) {}
    }
    Navigator.of(context).pop(); // Loading dialogu kapat
    setState(() { toDelete.clear(); });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLoc.deleteCompletedTitle),
        content: Text(appLoc.deleteCompleted(deleted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLoc.ok),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (currentIndex < photos.length) {
      final appLoc = AppLocalizations.of(context);
      final remaining = photos.length - currentIndex;
      final label = widget.isVideoMode ? 'videoları' : 'fotoğrafları';
      final label2 = widget.isVideoMode ? 'video' : 'fotoğraf';
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLoc.cancel),
          content: Text('Tüm $label incelemeden çıkmak üzeresin. Kalan: $remaining $label2. Geri dönersen baştan başlamak zorunda kalırsın. Çıkmak istiyor musun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLoc.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLoc.ok),
            ),
          ],
        ),
      );
      return shouldLeave == true;
    }
    return true;
  }

  Widget _buildMediaCard(PhotoItem item, int index, double maxCardWidth, double maxCardHeight) {
    if (item.type == MediaType.video) {
      final controller = _videoControllers[index];
      if (controller == null) {
        final future = GalleryService.getFilePath(item.id).then((path) async {
          final c = VideoPlayerController.file(File(path));
          await c.initialize();
          setState(() { _videoControllers[index] = c; });
        });
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                width: maxCardWidth - 20,
                height: maxCardHeight - 20,
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
            const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64)),
          ],
        );
      } else {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            if (!controller.value.isPlaying)
              GestureDetector(
                onTap: () => setState(() { controller.value.isPlaying ? controller.pause() : controller.play(); }),
                child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
          ],
        );
      }
    } else {
      return Image.memory(
        item.thumb,
        fit: BoxFit.cover,
        width: maxCardWidth - 20,
        height: maxCardHeight - 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // AppBar kaldırıldı, başlık ve geri butonu Stack ile eklenecek
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dalgalı arka plan
            const _WavyBackground(),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        widget.albumName ?? 'Photo Gallery',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Expanded(
                    child: Center(
                      child: (isLoading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : (currentIndex >= photos.length)
                              ? Text(
                                  widget.isVideoMode
                                    ? AppLocalizations.of(context).allVideosReviewed
                                    : AppLocalizations.of(context).allPhotosReviewed,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxCardWidth = (constraints.maxWidth * 0.8).clamp(180.0, 420.0);
                                    final maxCardHeight = (constraints.maxHeight * 0.6).clamp(220.0, 600.0);
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Sol ikon ve açıklama
                                        Flexible(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              CircleAvatar(
                                                backgroundColor: Color(0xFFE57373),
                                                radius: 22,
                                                child: Icon(Icons.delete, color: Colors.white, size: 24),
                                              ),
                                              // Sol açıklama yazısı kaldırıldı
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Kart
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: maxCardWidth,
                                            minWidth: 140,
                                            maxHeight: maxCardHeight,
                                            minHeight: 120,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(32),
                                            child: CardSwiper(
                                              key: ValueKey(currentIndex),
                                              controller: _swiperController,
                                              cardsCount: photos.length - currentIndex,
                                              numberOfCardsDisplayed: 1,
                                              isLoop: false,
                                              onSwipe: (int realIndex, int? previousIndex, CardSwiperDirection direction) async {
                                                if (direction == CardSwiperDirection.left) {
                                                  _onSwipe(Direction.left, currentIndex + realIndex);
                                                } else if (direction == CardSwiperDirection.right) {
                                                  _onSwipe(Direction.right, currentIndex + realIndex);
                                                }
                                                return true;
                                              },
                                              cardBuilder: (context, index, realIndex, previousIndex) {
                                                return _buildMediaCard(photos[currentIndex + index], currentIndex + index, maxCardWidth, maxCardHeight);
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Sağ ikon ve açıklama
                                        Flexible(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              CircleAvatar(
                                                backgroundColor: Color(0xFF4DB6AC),
                                                radius: 22,
                                                child: Icon(Icons.favorite, color: Colors.white, size: 24),
                                              ),
                                              // Sağ açıklama yazısı kaldırıldı
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kalan fotoğraf sayısı
                  if (!isLoading && currentIndex < photos.length)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        AppLocalizations.of(context).remainingPhotos(photos.length - currentIndex),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

enum Direction { left, right } 