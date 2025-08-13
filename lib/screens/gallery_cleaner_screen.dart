import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../services/gallery_service.dart';
// Recently deleted manager kaldırıldı - sadece görüntüleme modu
import '../models/photo_item.dart';
import 'dart:typed_data';
import '../widgets/debounced_button.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart'; // compute için
import 'dart:io' show Directory;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart'; // Renk teması import'u

import 'dart:convert';
import 'dart:math'; // Random için eklendi

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
  // deletedPhotos listesi kaldırıldı - sadece görüntüleme modu
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
        loadedPhotos.shuffle(Random());
        if (mounted) {
          setState(() {
            photos = loadedPhotos;
            isLoading = false;
          });
        }
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
    loadedPhotos.shuffle(Random());
        if (mounted) {
          setState(() {
            photos = loadedPhotos;
            isLoading = false;
          });
        }
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
        content: Text(appLoc?.noAlbumsFoundDescription ?? 'Gallery access permission granted but no ${widget.isVideoMode ? 'video' : 'photo'} found.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLoc?.ok ?? 'Tamam'),
          ),
        ],
      ),
    );
  }

  // Fotoğraf dosya boyutunu al
  Future<int> _getPhotoFileSize(PhotoItem photo) async {
    try {
      if (photo.path != null && photo.path!.isNotEmpty) {
        final file = File(photo.path!);
        if (await file.exists()) {
          return await file.length();
        }
      }
    } catch (e) {
      print('Dosya boyutu alınamadı: $e');
    }
    return 0;
  }

  // Dosya boyutunu kısa formatlı string'e çevir (telefon ekranında sığsın)
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(0)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)}MB';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)}GB';
    }
  }

  // Toplam silinen dosya boyutunu hesapla (bu klasör için)
  int _getTotalDeletedSize() {
    // Bu klasördeki silinen fotoğrafların toplam boyutunu hesapla
    int totalSize = 0;
    for (final photoId in toDelete) {
      // ID'ye göre fotoğrafı bul
      final photo = photos.firstWhere((p) => p.id == photoId, orElse: () => PhotoItem(
        id: '', 
        thumb: Uint8List(0), 
        path: null, 
        date: DateTime.now(), 
        hash: '', 
        type: MediaType.image, 
        name: ''
      ));
      // Her fotoğrafın boyutunu al (asenkron olmadığı için yaklaşık hesaplama)
      if (photo.path != null && photo.path!.isNotEmpty) {
        try {
          final file = File(photo.path!);
          if (file.existsSync()) {
            totalSize += file.lengthSync();
          }
        } catch (e) {
          // Hata durumunda geç
        }
      }
    }
    return totalSize;
  }

  // Geliştirilmiş _onSwipe fonksiyonu
  void _onSwipe(Direction dir, int index) async {
    // Mevcut video controller'ı durdur
    if (_videoControllers.containsKey(index)) {
      final controller = _videoControllers[index]!;
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    }
    
    if (dir == Direction.left) {
      // Sola kaydırma - silinecekler listesine ekle
      // Aynı fotoğrafı tekrar ekleme
      if (!toDelete.contains(photos[index].id)) {
        toDelete.add(photos[index].id);
        print('DEBUG: Fotoğraf silinecekler listesine eklendi: ${photos[index].id}');
      } else {
        print('DEBUG: Fotoğraf zaten silinecekler listesinde: ${photos[index].id}');
      }
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
    print('DEBUG: currentIndex: $currentIndex, photos.length: ${photos.length}, toDelete.length: ${toDelete.length}, _batchDialogShown: $_batchDialogShown');
    if (currentIndex >= photos.length && toDelete.isNotEmpty && !_batchDialogShown) {
      _batchDialogShown = true;
      print('DEBUG: Dialog gösteriliyor - ${toDelete.length} fotoğraf silinecek');
      await Future.delayed(const Duration(milliseconds: 400)); // Animasyon için küçük gecikme
      _showBatchDeleteDialog();
    }
  }

  void _showBatchDeleteDialog() async {
    print('DEBUG: _showBatchDeleteDialog başladı');
    final appLoc = AppLocalizations.of(context);
    final totalSize = _getTotalDeletedSize();
    final formattedSize = _formatBytes(totalSize);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteConfirmation),
        content: Text(
          '${toDelete.length} ${widget.isVideoMode ? (appLoc?.videos ?? 'videos') : (appLoc?.photos ?? 'photos')} will be deleted.\n'
          'Total size: $formattedSize\n\n'
          'This action cannot be undone. Do you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Deny
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.darkAccent,
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Allow
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.darkAccent,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // Kullanıcı Allow dedi, dosyaları sil
      print('DEBUG: Kullanıcı Allow dedi, silme başlıyor');
      await _deleteBatch();
    } else {
      // Kullanıcı Deny dedi, sadece listeyi temizle
      print('DEBUG: Kullanıcı Deny dedi, liste temizleniyor');
      if (mounted) {
        setState(() { 
          toDelete.clear(); 
          _batchDialogShown = false;
        });
      }
    }
    
    // Dialog kapandıktan sonra flag'i sıfırla
    _batchDialogShown = false;
  }

  Future<void> _deleteBatch() async {
    print('DEBUG: _deleteBatch() başladı - toDelete.length: ${toDelete.length}');
    print('DEBUG: Stack trace: ${StackTrace.current}');
    if (toDelete.isEmpty) return;
    
    int deleted = 0;
    final filesToDelete = <String>[];
    final deletedFileInfos = <Map<String, dynamic>>[];
    
    try {
      // Önce tüm dosyaları hazırla ve orijinal bilgilerini sakla
      for (final photoId in toDelete) {
        final photo = photos.firstWhere((p) => p.id == photoId);
        if (photo.path != null && photo.path!.isNotEmpty) {
          try {
            // Orijinal dosya bilgilerini sakla
            final originalFile = File(photo.path!);
            if (await originalFile.exists()) {
              // Orijinal klasör bilgisini al
              final originalDir = Directory(path.dirname(photo.path!));
              final originalFolderName = path.basename(originalDir.path);
              
              // Kendi trash klasörümüzü oluştur
              final appDir = await getApplicationDocumentsDirectory();
              final swiftyTrashDir = Directory('${appDir.path}/swifty_trash');
              
              // Trash klasörü yoksa oluştur
              if (!await swiftyTrashDir.exists()) {
                await swiftyTrashDir.create(recursive: true);
              }
              
              final fileName = path.basename(photo.path!);
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final trashFileName = '${timestamp}_$fileName';
              final trashPath = '${swiftyTrashDir.path}/$trashFileName';
            
              // Dosyayı kopyala
              await originalFile.copy(trashPath);
              
              // Silinecek dosya bilgilerini sakla
              filesToDelete.add(photoId);
              deletedFileInfos.add({
                'originalPath': photo.path!,
                'trashPath': trashPath,
                'photoId': photo.id,
                'fileName': fileName,
                'originalFolderPath': originalDir.path,
                'originalFolderName': originalFolderName,
                'deletedAt': DateTime.now().millisecondsSinceEpoch,
                'expiresAt': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
              });
              
              print('Dosya hazırlandı: ${photo.path} -> $trashPath');
            }
          } catch (e) {
            print('Dosya hazırlama hatası: $e');
            // Hata durumunda sadece silme listesine ekle
            filesToDelete.add(photoId);
          }
        }
      }
      
      // Android'in kendi silme onayını bekle - MediaStore silme işlemi
      if (filesToDelete.isNotEmpty) {
        print('DEBUG: Android MediaStore silme işlemi başlıyor...');
        
        // PhotoManager ile silme işlemi (Android'in kendi onayını tetikler)
        final deleteResult = await PhotoManager.editor.deleteWithIds(filesToDelete);
        
        // Silme işleminin başarılı olup olmadığını kontrol et
        if (deleteResult != null && deleteResult.isNotEmpty) {
          deleted = deleteResult.length;
          print('DEBUG: Android silme işlemi başarılı - $deleted dosya silindi');
          
          // Sadece başarıyla silinen dosyaları "son silinenler" listesine ekle
          for (final fileInfo in deletedFileInfos) {
            final photoId = fileInfo['photoId'] as String;
            if (deleteResult.contains(photoId)) {
              await _saveDeletedFileInfo(
                fileInfo['originalPath'], 
                fileInfo['trashPath'], 
                fileInfo['photoId'], 
                fileInfo['fileName'],
                fileInfo['originalFolderPath'],
                fileInfo['originalFolderName'],
              );
              print('DEBUG: Dosya "son silinenler" listesine eklendi: ${fileInfo['fileName']}');
            } else {
              print('DEBUG: Dosya silinmedi, "son silinenler" listesine eklenmedi: ${fileInfo['fileName']}');
            }
          }
        } else {
          print('DEBUG: Android silme işlemi başarısız veya iptal edildi');
        }
      }
      
      // Debug: JSON dosyasını kontrol et
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final deletedFilesPath = '${appDir.path}/deleted_files.json';
        final deletedFilesFile = File(deletedFilesPath);
        if (await deletedFilesFile.exists()) {
          final content = await deletedFilesFile.readAsString();
          final files = json.decode(content) as List;
          print('DEBUG: JSON dosyasında toplam ${files.length} silinen dosya var');
        }
      } catch (e) {
        print('DEBUG: JSON kontrol hatası: $e');
      }
      
      print('$deleted dosya Swifty "Son Silinenler" klasörüne taşındı');
      
      // Kullanıcıya bilgi ver
      if (deleted > 0) {
        final appLoc = AppLocalizations.of(context)!;
        final appDir = await getApplicationDocumentsDirectory();
        final trashPath = '${appDir.path}/swifty_trash';
        
        // Yeşil mesaj kaldırıldı - kullanıcı karışıklığını önlemek için
        
        // Debug için klasör bilgisini yazdır
        final swiftyTrashDir = Directory('${appDir.path}/swifty_trash');
        print('Swifty Trash Klasörü: ${swiftyTrashDir.path}');
        if (await swiftyTrashDir.exists()) {
          final files = await swiftyTrashDir.list().toList();
          print('Swifty Trash klasöründe ${files.length} dosya var');
          for (final file in files) {
            print('  - ${file.path}');
          }
        }
      }
      
    } catch (e) {
      print('Toplu silme hatası: $e');
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
    
    if (mounted) {
      setState(() { 
        toDelete.clear(); 
      });
    }
  }

  // Silinen dosya bilgisini JSON dosyasında sakla
  Future<void> _saveDeletedFileInfo(String originalPath, String trashPath, String photoId, String fileName, String originalFolderPath, String originalFolderName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final deletedFilesPath = '${appDir.path}/deleted_files.json';
      final deletedFilesFile = File(deletedFilesPath);
      
      List<Map<String, dynamic>> deletedFiles = [];
      
      // Mevcut dosyayı oku
      if (await deletedFilesFile.exists()) {
        final content = await deletedFilesFile.readAsString();
        if (content.isNotEmpty) {
          deletedFiles = List<Map<String, dynamic>>.from(
            json.decode(content) as List
          );
        }
      }
      
      // Yeni dosya bilgisini ekle
      deletedFiles.add({
        'originalPath': originalPath,
        'trashPath': trashPath,
        'photoId': photoId,
        'fileName': fileName,
        'originalFolderPath': originalFolderPath,
        'originalFolderName': originalFolderName,
        'deletedAt': DateTime.now().millisecondsSinceEpoch,
        'expiresAt': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
      });
      
      // Dosyayı kaydet
      await deletedFilesFile.writeAsString(json.encode(deletedFiles));
      
      print('Silinen dosya bilgisi JSON dosyasına kaydedildi: $fileName');
    } catch (e) {
      print('Silinen dosya bilgisi kaydedilemedi: $e');
    }
  }

  // Geri alma dialog'u göster
  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son Silinenler'),
        content: const Text('Silinen dosyaları geri almak istiyor musunuz?'),
            actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
                onPressed: () {
              Navigator.pop(context);
              _restoreDeletedFiles();
            },
                          child: Text(AppLocalizations.of(context)!.restoreFile),
          ),
        ],
      ),
    );
  }

  // Silinen dosyaları geri al
  Future<void> _restoreDeletedFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final deletedFilesPath = '${appDir.path}/deleted_files.json';
      final deletedFilesFile = File(deletedFilesPath);
      
      if (!await deletedFilesFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recentlyDeletedFilesNotFound)),
        );
        return;
      }

      final content = await deletedFilesFile.readAsString();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recentlyDeletedFilesNotFound)),
        );
        return;
      }

      List<Map<String, dynamic>> deletedFiles = List<Map<String, dynamic>>.from(
        json.decode(content) as List
      );

      int restored = 0;
      final remainingFiles = <Map<String, dynamic>>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final fileInfo in deletedFiles) {
        final originalPath = fileInfo['originalPath'] as String;
        final trashPath = fileInfo['trashPath'] as String;
        final expiresAt = fileInfo['expiresAt'] as int;
        
        // Süresi dolmuş dosyaları atla
        if (now > expiresAt) {
          // Süresi dolmuş trash dosyasını sil
          try {
            final trashFile = File(trashPath);
            if (await trashFile.exists()) {
              await trashFile.delete();
            }
          } catch (e) {
            print('Süresi dolmuş dosya silme hatası: $e');
          }
          continue;
        }
        
        try {
          final trashFile = File(trashPath);
          if (await trashFile.exists()) {
            // Dosyayı orijinal konumuna geri kopyala
            await trashFile.copy(originalPath);
            await trashFile.delete(); // Trash dosyasını sil
            restored++;
            print('Dosya geri alındı: ${fileInfo['fileName']}');
          } else {
            // Trash dosyası yoksa bilgiyi kaldır
            print('Trash dosyası bulunamadı: $trashPath');
          }
        } catch (e) {
          print('Dosya geri alma hatası: $e');
          remainingFiles.add(fileInfo);
        }
      }

      // Kalan dosyaları kaydet
      await deletedFilesFile.writeAsString(json.encode(remainingFiles));

      if (restored > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$restored dosya başarıyla geri alındı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
          content: Text(AppLocalizations.of(context)!.recentlyDeletedFilesNotFound),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange[700]
              : Colors.orange,
        ),
        );
      }
    } catch (e) {
      print('Geri alma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.restoreError}: $e'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.red[700]
              : Colors.red,
        ),
      );
    }
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
                          "Loading videos...",
                          style: const TextStyle(color: Colors.white, fontSize: 10),
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBackgroundPrimary
            : Colors.white,
        body: Stack(
          children: [
            // Üst kısım gradient, alt kısım tema moduna göre
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkMainGradient
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE91E63), // Pembe
                                Color(0xFF9C27B0), // Mor
                              ],
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBackgroundSecondary
                        : Colors.white,
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: DebouncedButton(
                      onPressed: () async {
                        if (await _onWillPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: null, // DebouncedButton üstte olduğu için null
                                                      child: Container(
                            padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkButtonBackground
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
              ),
            ],
          ),
                            child: Icon(
                              Icons.arrow_back, 
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkAccent
                                  : const Color(0xFF0A183D), 
                              size: 24
                            ),
        ),
                  ),
              ),
            ),
          ),
                  // Çık ve Sil butonu (sadece seçili fotoğraf varsa göster)

            // Geri Al butonları kaldırıldı - sadece görüntüleme modu

            // Üst butonlar (sadece fotoğraf gösterimi sırasında)
            if (currentIndex < photos.length)
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                    // Sol buton - Kalan fotoğraf sayısı (biraz küçültülmüş)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkButtonBackground.withOpacity(0.8)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorderColor
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo, 
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkAccent
                                : Colors.white, 
                            size: 14
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${photos.length - currentIndex} ${appLoc?.remaining ?? 'REMAINING'}',
                            style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : Colors.white,
                              fontSize: 13,
                          fontWeight: FontWeight.bold,
                  ),
                ),
                ],
              ),
                    ),
                    // Sağ buton - Kazanılan alan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkButtonBackground.withOpacity(0.8)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorderColor
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        '${_formatBytes(_getTotalDeletedSize())} ${appLoc?.spaceSaved ?? 'SPACE SAVED'}',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ],
      ),
              ),
          Positioned(
                    top: 18,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        widget.albumName ?? '',
                    style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : Colors.white,
                          fontSize: 24,
                fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.5)
                                  : const Color(0xFF0A183D), 
                              blurRadius: 8
                            )
                          ],
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
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                                      const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
                                        appLoc?.completed ?? 'Completed!',
              style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
                                        widget.isVideoMode
                                          ? (appLoc?.allVideosReviewed ?? 'All videos reviewed')
                                          : appLoc?.allPhotosReviewed ?? 'All photos reviewed',
              style: const TextStyle(
                                          color: Colors.black87,
                fontSize: 18,
                                        ),
                                      ),
                                      if (toDelete.isNotEmpty) ...[
                                        const SizedBox(height: 30),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Silme onayı (geri dönüş mesajıyla aynı)
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Son Silinenler'),
                                                content: Text(appLoc?.filesMovedToRecentlyDeleted(toDelete.length) ?? '${toDelete.length} files will be moved to "Recently Deleted" folder. You can restore them within 30 days.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('İptal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

                                            if (confirmed == true) {
                                              try {
                                                print('DEBUG: Kalıcı silme onaylandı, ${toDelete.length} adet fotoğraf silinecek');
                                                final success = await GalleryService.moveToRecentlyDeleted(toDelete);
                                                print('DEBUG: Kalıcı silme işlemi sonucu: $success');
                                                
                                                if (success) {
                                                  final deletedCount = toDelete.length;
                                                  // Recently deleted manager kaldırıldı
                                                setState(() {
                                                    toDelete.clear();
                                                  });
                                                  widget.onPhotosDeleted?.call(deletedCount);
                                                  
                                                  // Başarı mesajı göster
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(appLoc?.filesSuccessfullyDeleted(deletedCount) ?? '$deletedCount files successfully deleted'),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  }
                                                  
                                                  // Ana sayfaya dön
                                                  Navigator.of(context).pop();
                                                  } else {
                                                  // Hata mesajı göster
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Silme işlemi başarısız oldu'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                print('DEBUG: Kalıcı silme işlemi hatası: $e');
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Silme hatası: $e'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                          ),
                                          child: Text('Kalıcı Sil (${toDelete.length})'),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxCardWidth = (constraints.maxWidth * 0.9).clamp(200.0, 450.0);
                                    final maxCardHeight = (constraints.maxHeight * 0.75).clamp(300.0, 650.0);
                                    return Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        Expanded(
                                          child: Center(
                                            child:
                                        // Kart
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: maxCardWidth,
                                            minWidth: 140,
                                            maxHeight: maxCardHeight,
                                            minHeight: 120,
                                          ),
                                                child: Container(
                                            margin: const EdgeInsets.all(16),
                                            padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                      color: Colors.white,
                                              borderRadius: BorderRadius.circular(24),
                                                    boxShadow: [
                                                      BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                    child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12), // 20'den 12'ye küçültüldü
                                            child: CardSwiper(
                                              key: ValueKey(currentIndex),
                                              controller: _swiperController,
                                              cardsCount: photos.length - currentIndex,
                                              numberOfCardsDisplayed: 1,
                                              isLoop: false,
                                              onSwipe: (int realIndex, int? previousIndex, CardSwiperDirection direction) async {
                                                // Mevcut videoyu durdur
                                                final currentPhotoIndex = currentIndex + realIndex;
                                                final currentController = _videoControllers[currentPhotoIndex];
                                                if (currentController != null && currentController.value.isPlaying) {
                                                  currentController.pause();
                                                }
                                                
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
        child: Center(
                                                            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 8),
              Text(
                appLoc?.videoLoading ?? 'Video loading...',
                style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
                                                          ),
                                                        ),
                                                        const Center(child: Icon(Icons.videocam, color: Colors.white, size: 64)),
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
                                                  
                                                    return GestureDetector(
                                                      onTap: () {
                                                        _showFullScreenImage(photo);
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          Image.memory(
                                                            photo.thumb,
                                                            fit: BoxFit.contain, // cover'dan contain'e değiştirildi (kırpmasın)
                                                            width: maxCardWidth - 10,  // 20'den 10'a (daha az margin)
                                                            height: maxCardHeight - 10, // 20'den 10'a (daha az margin)
                                                                                                             errorBuilder: (context, error, stackTrace) {
                                                   return Container(
                                                     width: maxCardWidth - 10,
                                                     height: maxCardHeight - 10,
                                                     decoration: BoxDecoration(
                                                       color: Colors.grey[200],
                                                       borderRadius: BorderRadius.circular(12),
                                                     ),
                                                     child: const Icon(
                                                       Icons.broken_image,
                                                       size: 64,
                                                       color: Colors.grey,
                                                     ),
                                                   );
                                                 },
                                                          ),
                                                                                                                // Dosya boyutu yazısı
                                                        Positioned(
                                                          top: 8,
                                                          right: 8,
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.7),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: FutureBuilder<int>(
                                                              future: _getPhotoFileSize(photo),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.hasData) {
                                                                  return Text(
                                                                    _formatBytes(snapshot.data!),
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  );
                                    } else {
                                                                  return const Text(
                                                                    "0 B",
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            ),
                                                          ),
                                                        ],
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                                                                      ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Alt butonlar
                                        if (!isLoading && currentIndex < photos.length)
                                              Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 30),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                // Silme butonu (kırmızı)
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (currentIndex < photos.length) {
                                                          _onSwipe(Direction.left, currentIndex);
                                                        }
                                                      },
                                                      child: Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFE53E3E),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                      size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                // Atla butonu (mor/pembe)
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (currentIndex < photos.length) {
                                                      setState(() {
                                                              currentIndex++;
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                          decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(context)!.skip,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                // Kalp butonu (yeşil)
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (currentIndex < photos.length) {
                                                          _onSwipe(Direction.right, currentIndex);
                                                        }
                                                      },
                                                      child: Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF38A169),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                            Icons.favorite,
                                                            color: Colors.white,
                                                      size: 28,
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                                    ),
                                          ),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  },
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
        title: Text(AppLocalizations.of(context)!.exitConfirmation),
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
                        appLoc?.markedForDeletion(selectedCount) ?? '$selectedCount ${widget.isVideoMode ? 'video' : 'photo'} marked for deletion!',
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
              child: Text(AppLocalizations.of(context)!.deleteAndExit),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('exit'),
                                                                child: Text(AppLocalizations.of(context)!.exitWithoutDeleting),
            ),
          ],
        ),
    );
    
    if (shouldLeave == 'delete') {
      // Seçili fotoğrafları sil ve çık
      if (toDelete.isNotEmpty) {
        print('DEBUG: Exit dialog - silme başlıyor');
        await _deleteBatch();
      }
      return true;
    } else if (shouldLeave == 'exit') {
      // Sadece çık, seçili fotoğrafları silme
      if (mounted) {
        setState(() { 
          toDelete.clear(); 
          _batchDialogShown = false;
        });
      }
      return true;
    }
    
    // İptal edildi
    return false;
  }

  // Geri alma dialog'u
  void _showUndoDialog() {
    final appLoc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLoc.undoTitle),
        content: Text(appLoc.undoMessage(toDelete.length)),
          actions: [
            TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLoc.undoCancel),
            ),
            ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _undoLastDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text(appLoc.undoConfirm, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
  }

  // Son silme işlemini geri al
  void _undoLastDeletion() async {
    if (toDelete.isNotEmpty) {
      final lastDeletedId = toDelete.last;
      final lastDeleted = photos.firstWhere((p) => p.id == lastDeletedId, orElse: () => PhotoItem(
        id: '', 
        thumb: Uint8List(0), 
        path: null, 
        date: DateTime.now(), 
        hash: '', 
        type: MediaType.image, 
        name: ''
      ));
      
      // Dosya gerçekten silinmiş mi kontrol et
      bool fileExists = false;
      if (lastDeleted.path != null && lastDeleted.path!.isNotEmpty) {
        final file = File(lastDeleted.path!);
        fileExists = await file.exists();
      }
      
      if (!fileExists) {
        // Dosya gerçekten silinmiş, geri alma mümkün değil
        final appLoc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(appLoc.filePermanentlyDeleted),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          toDelete.removeLast();
          toDelete.remove(lastDeleted.id);
        });
        return;
      }
      
      setState(() {
        // Son silinen fotoğrafı geri ekle
        photos.insert(currentIndex, lastDeleted);
        
        // Listelerden çıkar
        toDelete.removeLast();
        toDelete.remove(lastDeleted.id);
        
        // currentIndex'i güncelle
        currentIndex = (currentIndex - 1).clamp(0, photos.length - 1);
      });
      
      final appLoc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLoc.lastPhotoUndone),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Tam ekran fotoğraf görüntüleme
  void _showFullScreenImage(PhotoItem photo) async {
    // Tam çözünürlüklü fotoğrafı yükle
    Uint8List? fullImageData;
    try {
      if (photo.path != null && photo.path!.isNotEmpty) {
        final file = File(photo.path!);
        if (await file.exists()) {
          fullImageData = await file.readAsBytes();
        }
      }
    } catch (e) {
      print('Tam çözünürlüklü fotoğraf yükleme hatası: $e');
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              AppLocalizations.of(context)!.photoDetail,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: fullImageData != null
                  ? Image.memory(
                      fullImageData,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.memory(
                          photo.thumb,
                          fit: BoxFit.contain,
                        );
                      },
                    )
                  : Image.memory(
                      photo.thumb,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
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
 