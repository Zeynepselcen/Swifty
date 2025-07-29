import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../services/gallery_service.dart';
import '../models/photo_item.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart'; // compute için

import 'package:permission_handler/permission_handler.dart'; // HATIRLATMA: Tüm dosya yönetimi izni için eklendi, sorun olursa kaldırabilirsin.
import 'package:flutter/services.dart'; // Tüm dosya yönetimi izni için eklendi

enum Direction { left, right }

class GalleryCleanerScreen extends StatefulWidget {
  final String? albumId;
  final String? albumName;
  final List<PhotoItem>? photos;
  final bool isVideoMode;
  final Function(int)? onPhotosDeleted; // Silme callback'i
  const GalleryCleanerScreen({
    super.key, 
    this.albumId, 
    this.albumName, 
    this.photos, 
    this.isVideoMode = false,
    this.onPhotosDeleted,
  });

  @override
  State<GalleryCleanerScreen> createState() => _GalleryCleanerScreenState();
}

class _GalleryCleanerScreenState extends State<GalleryCleanerScreen> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    if (widget.photos != null) {
      photos = List<PhotoItem>.from(widget.photos!);
      isLoading = false;
    } else {
      _initGallery();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllVideoControllers();
    super.dispose();
  }

  // Tüm video controller'ları dispose et
  void _disposeAllVideoControllers() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();
  }

  // Görünmeyen video controller'ları dispose et (memory optimizasyonu)
  void _disposeInvisibleVideoControllers() {
    final visibleRange = 3; // Görünür video sayısı
    final startIndex = (currentIndex - visibleRange).clamp(0, photos.length);
    final endIndex = (currentIndex + visibleRange).clamp(0, photos.length);
    
    final controllersToDispose = <int>[];
    
    for (final entry in _videoControllers.entries) {
      final index = entry.key;
      if (index < startIndex || index > endIndex) {
        controllersToDispose.add(index);
      }
    }
    
    for (final index in controllersToDispose) {
      final controller = _videoControllers[index];
      if (controller != null) {
        controller.dispose();
        _videoControllers.remove(index);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAndReloadGallery();
    }
  }

  Future<void> _checkAndReloadGallery() async {
    // Eğer izin verilmişse ve fotoğraflar boşsa veya izin yeni verilmişse tekrar yükle
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      if (!_galleryPermissionGranted || photos.isEmpty) {
        // GalleryPermissionHelper kaldırıldı
        setState(() {
          _galleryPermissionGranted = true;
          _permissionDenied = false;
          isLoading = true;
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
    }
  }

  Future<void> _initGallery() async {
    // 1. Önce izin durumunu kontrol et
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
      isLoading = true;
    });
    // GalleryPermissionHelper kaldırıldı
    // 2. Galeri içeriğini yükle
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
    // 3. Eğer galeri boşsa özel mesaj göster
    if (loadedPhotos.isEmpty) {
      _showEmptyGalleryDialog();
    }
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
        title: const Text('Permission Required'),
        content: const Text('Permission is required to access your gallery. Please enable it in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmptyGalleryDialog() {
    final appLoc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLoc?.noAlbumsFound ?? 'Galeri Boş'),
        content: Text(appLoc?.noAlbumsFound ?? 'Galeriye erişim izni verildi ancak hiç fotoğraf veya video bulunamadı.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLoc?.ok ?? 'Tamam'),
          ),
        ],
      ),
    );
  }

  // Geliştirilmiş _onSwipe fonksiyonu
  void _onSwipe(Direction dir, int index) async {
    if (dir == Direction.left) {
      // Sola kaydırma - silinecekler listesine ekle
      toDelete.add(photos[index].id);
      print('DEBUG: Fotoğraf silinecekler listesine eklendi: ${photos[index].id}');
    } else if (dir == Direction.right) {
      // Sağa kaydırma - beğenilen (silinmeyecek)
      print('DEBUG: Fotoğraf beğenildi: ${photos[index].id}');
    }
    
    setState(() {
      currentIndex++;
      
      // Video controller temizliği
      _disposeInvisibleVideoControllers();
    });
    
    // Eğer son fotoğrafı geçtiysek, toplu silme onayı iste (sadece bir kez)
    if (currentIndex >= photos.length && toDelete.isNotEmpty && !_batchDialogShown) {
      _batchDialogShown = true;
      await Future.delayed(const Duration(milliseconds: 400)); // Animasyon için küçük gecikme
      _showBatchDeleteDialog();
    }
  }

  void _showBatchDeleteDialog() async {
    await _deleteBatch();
    setState(() { _batchDialogShown = false; });
  }

  Future<void> _deleteBatch() async {
    if (toDelete.isEmpty) return;
    
    int deleted = 0;
    try {
      await PhotoManager.editor.deleteWithIds(toDelete);
      deleted = toDelete.length;
    } catch (e) {
      print('Silme hatası: $e');
    }
    
    // Silinen fotoğrafları listeden çıkar
    if (deleted > 0) {
      final deletedIds = toDelete.toSet();
      photos.removeWhere((photo) => deletedIds.contains(photo.id));
      
      // currentIndex'i güncelle
      if (currentIndex >= photos.length) {
        currentIndex = photos.length;
      }
      
      // Callback ile ana ekrana bildir
      widget.onPhotosDeleted?.call(deleted);
    }
    
    setState(() { toDelete.clear(); });
  }

  String _localizedAlbumName(String name, AppLocalizations appLoc) {
    switch (name.toLowerCase()) {
      case 'recent':
        return appLoc.recent;
      case 'download':
        return appLoc.download;
      default:
        return name;
    }
  }

  Widget _buildMediaCard(PhotoItem item, int index, double maxCardWidth, double maxCardHeight) {
    if (item.type == MediaType.video) {
      final controller = _videoControllers[index];
      if (controller == null) {
        // Hızlı video yükleme - arka planda başlat
        _loadVideoController(item.id, index);
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                width: maxCardWidth - 40,
                height: maxCardHeight - 40,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Video yükleniyor...',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48)),
          ],
        );
      } else {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                width: maxCardWidth - 40,
                height: maxCardHeight - 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: VideoPlayer(
                            controller,
                            // Video kalitesi ayarları
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                              onPressed: () {
                                final newPosition = controller.value.position - const Duration(seconds: 10);
                                controller.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
                              },
                            ),
                            IconButton(
                              icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 48),
                              onPressed: () {
                                setState(() {
                                  controller.value.isPlaying ? controller.pause() : controller.play();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                              onPressed: () {
                                final max = controller.value.duration;
                                final newPosition = controller.value.position + const Duration(seconds: 10);
                                controller.seekTo(newPosition < max ? newPosition : max);
                              },
                            ),
                          ],
                        ),
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Color(0xFF4DB6AC),
                            bufferedColor: Color(0xFF4DB6AC).withOpacity(0.5),
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    } else {
      return Container(
        width: maxCardWidth - 40, // Amblemler için daha fazla boşluk
        height: maxCardHeight - 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.path != null && item.path!.isNotEmpty
              ? Image.file(
                  File(item.path!),
                  fit: BoxFit.contain, // Tam boyut göster, kırpma yapma
                  width: maxCardWidth - 40,
                  height: maxCardHeight - 40,
                  errorBuilder: (context, error, stackTrace) {
                    // Eğer dosya yüklenemezse thumbnail kullan
                    return Image.memory(
                      item.thumb,
                      fit: BoxFit.contain,
                      width: maxCardWidth - 40,
                      height: maxCardHeight - 40,
                    );
                  },
                )
              : Image.memory(
                  item.thumb,
                  fit: BoxFit.contain, // Tam boyut göster, kırpma yapma
                  width: maxCardWidth - 40,
                  height: maxCardHeight - 40,
                ),
        ),
      );
    }
  }

  // Video controller'ı basit yükleme
  Future<void> _loadVideoController(String videoId, int index) async {
    // Eğer zaten yükleniyorsa veya yüklenmişse çık
    if (_videoControllers.containsKey(index)) return;
    
    try {
      // PhotoItem'dan path'i al
      final photo = photos.firstWhere((p) => p.id == videoId);
      
      if (mounted && photo.path != null && photo.path!.isNotEmpty) {
        final controller = VideoPlayerController.file(File(photo.path!));
        await controller.initialize();
        
        if (mounted) {
          setState(() {
            _videoControllers[index] = controller;
          });
        }
      }
    } catch (e) {
      print('Video yükleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // AppBar kaldırıldı, başlık ve geri butonu Stack ile eklenecek
        backgroundColor: const Color(0xFF0A183D),
        body: Stack(
          children: [
            Theme.of(context).brightness == Brightness.dark
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
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF0A183D), size: 28),
                        ),
                      ),
                    ),
                  ),
                  // Çık ve Sil butonu (sadece seçili fotoğraf varsa göster)
                  if (toDelete.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            await _deleteBatch();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_forever, color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${toDelete.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                        widget.albumName != null ? _localizedAlbumName(widget.albumName!, appLoc) : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: Color(0xFF0A183D), blurRadius: 8)],
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
                                    ? appLoc.allVideosReviewed
                                    : appLoc.allPhotosReviewed,
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
                                        // Sol ikon
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
                                                
                                                // Video memory optimizasyonu
                                                _disposeInvisibleVideoControllers();
                                                
                                                return true;
                                              },
                                              cardBuilder: (context, index, realIndex, previousIndex) {
                                                final photoIndex = currentIndex + index;
                                                final photo = photos[photoIndex];
                                                if (photo.type == MediaType.video) {
                                                  final controller = _videoControllers[photoIndex];
                                                  if (controller == null) {
                                                    // Lazy loading - sadece görünür videoları yükle
                                                    _loadVideoController(photo.id, photoIndex);
                                                    return Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: maxCardWidth - 20,
                                                            height: maxCardHeight - 20,
                                                            decoration: BoxDecoration(
                                                              color: Colors.black12,
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
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
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Expanded(child: VideoPlayer(controller)),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8, bottom: 8),
                                                                  child: VideoProgressIndicator(
                                                                    controller,
                                                                    allowScrubbing: true,
                                                                    colors: VideoProgressColors(playedColor: Color(0xFF4DB6AC)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
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
                                                    photo.thumb,
                                                    fit: BoxFit.cover,
                                                    width: maxCardWidth - 20,
                                                    height: maxCardHeight - 20,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Sağ ikon
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
                        appLoc.remainingPhotos(photos.length - currentIndex),
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

  Future<bool> _onWillPop() async {
    // Eğer tüm fotoğrafları gözden geçirdiyse direkt çık
    if (currentIndex >= photos.length) {
      return true;
    }
    
    // AppLocalizations al
    final appLoc = AppLocalizations.of(context);
    
    // Kalan fotoğraf sayısını hesapla
    final remaining = photos.length - currentIndex;
    final selectedCount = toDelete.length;
    
    // Çıkış dialog'u göster
    final shouldLeave = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLoc?.exitReviewDialog(
              widget.isVideoMode ? (appLoc?.videos ?? 'videolar') : (appLoc?.photos ?? 'fotoğraflar'),
              remaining
            ) ?? 'Henüz $remaining ${widget.isVideoMode ? 'video' : 'fotoğraf'} gözden geçirmediniz.'),
            if (selectedCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$selectedCount ${widget.isVideoMode ? 'video' : 'fotoğraf'} silmek için işaretlendi!',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(appLoc?.cancel ?? 'İptal'),
          ),
          if (selectedCount > 0)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil ve Çık'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('exit'),
            child: const Text('Silmeden Çık'),
          ),
        ],
      ),
    );
    
    if (shouldLeave == 'delete') {
      // Seçili fotoğrafları sil ve çık
      await _deleteBatch();
      return true;
    } else if (shouldLeave == 'exit') {
      // Sadece çık, seçili fotoğrafları silme
      setState(() { 
        toDelete.clear(); 
        _batchDialogShown = false;
      });
      return true;
    }
    
    // İptal edildi
    return false;
  }

  // --- Tüm Dosya Yönetimi İzni için eklenen kod başlangıcı ---
  void _showManageAllFilesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Dosyaları Yönetme İzni Gerekli'),
        content: const Text('Uygulamanın tüm dosyalarınıza erişebilmesi için ayarlardan "Tüm dosyaları yönetme" izni vermelisiniz.'),
        actions: [
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }
  // --- Tüm Dosya Yönetimi İzni için eklenen kod sonu ---
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

// --- Tüm Dosya Yönetimi İzni için eklenen kod başlangıcı ---
Future<int> _getAndroidSdkInt() async {
  try {
    final methodChannel = const MethodChannel('com.swifty.gallerycleaner/device_info');
    final int sdkInt = await methodChannel.invokeMethod('getSdkInt');
    return sdkInt;
  } catch (_) {
    return 0;
  }
}
// --- Tüm Dosya Yönetimi İzni için eklenen kod sonu --- 
 