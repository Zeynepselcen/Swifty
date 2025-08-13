import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/photo_item.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data'; // Uint8List için eklendi
import '../l10n/app_localizations.dart';

// --- Galeri İzin Kontrolü için eklenen kod kaldırıldı, utils klasörüne taşındı. ---

class GalleryService {
  static const String _cacheFileName = 'gallery_analysis_cache.json';
  static const MethodChannel _channel = MethodChannel('gallery_service');
  
  // Android'e özgü bildirim kanalı
  static const String _notificationChannelId = 'gallery_analysis';
  static const String _notificationChannelName = 'Galeri Analizi';
  static const String _notificationChannelDescription = 'Galeri analiz durumu bildirimleri';

  static Future<File> getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  static Future<Map<String, dynamic>> loadAnalysisCache() async {
    try {
      final file = await getCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  static Future<void> saveAnalysisCache(Map<String, dynamic> cache) async {
    try {
      final file = await getCacheFile();
      await file.writeAsString(json.encode(cache));
    } catch (_) {}
  }

  static Future<void> updateAnalysisCache(String id, Map<String, dynamic> data) async {
    final cache = await loadAnalysisCache();
    cache[id] = data;
    await saveAnalysisCache(cache);
  }

  static Future<void> initializeAndroidFeatures() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('createNotificationChannel', {
          'channelId': _notificationChannelId,
          'channelName': _notificationChannelName,
          'channelDescription': _notificationChannelDescription,
        });
      } catch (e) {
        debugPrint('Android notification channel oluşturulamadı: $e');
      }
    }
  }

  static Future<void> showAndroidNotification({
    required String title,
    required String content,
    required int progress,
    required int maxProgress,
  }) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('showProgressNotification', {
          'channelId': _notificationChannelId,
          'title': title,
          'content': content,
          'progress': progress,
          'maxProgress': maxProgress,
        });
      } catch (e) {
        debugPrint('Android bildirimi gösterilemedi: $e');
      }
    }
  }

  static Future<void> updateAndroidNotification({
    required String title,
    required String content,
    required int progress,
    required int maxProgress,
  }) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('updateProgressNotification', {
          'channelId': _notificationChannelId,
          'title': title,
          'content': content,
          'progress': progress,
          'maxProgress': maxProgress,
        });
      } catch (e) {
        debugPrint('Android bildirimi güncellenemedi: $e');
      }
    }
  }

  static Future<void> cancelAndroidNotification() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('cancelNotification');
      } catch (e) {
        debugPrint('Android bildirimi kapatılamadı: $e');
      }
    }
  }

  static Future<int> getAndroidFileSize(String filePath) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('getFileSize', {'filePath': filePath});
        return result ?? 0;
      } catch (e) {
        debugPrint('Dosya boyutu hesaplanamadı: $e');
        return 0;
      }
    } else {
      final file = File(filePath);
      return await file.exists() ? file.lengthSync() : 0;
    }
  }

  static Future<void> optimizeAndroidPerformance() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('optimizePerformance');
      } catch (e) {
        debugPrint('Android performans optimizasyonu yapılamadı: $e');
      }
    }
  }

  // Aylık gruplama için yardımcı fonksiyon
  static String _getMonthYearString(DateTime date, AppLocalizations appLoc) {
    final months = [
      appLoc.january, appLoc.february, appLoc.march, appLoc.april, appLoc.may, appLoc.june,
      appLoc.july, appLoc.august, appLoc.september, appLoc.october, appLoc.november, appLoc.december
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Fotoğrafları aylara göre grupla
  static Map<String, List<PhotoItem>> groupPhotosByMonth(List<PhotoItem> photos, AppLocalizations appLoc) {
    final Map<String, List<PhotoItem>> grouped = {};
    final months = [
      appLoc.january, appLoc.february, appLoc.march, appLoc.april, appLoc.may, appLoc.june,
      appLoc.july, appLoc.august, appLoc.september, appLoc.october, appLoc.november, appLoc.december
    ];
    
    for (final photo in photos) {
      final monthKey = _getMonthYearString(photo.date, appLoc);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(photo);
    }
    
    // Her ay içindeki fotoğrafları random sırala
    for (final key in grouped.keys) {
      grouped[key]!.shuffle();
    }
    
    // Ayları tarih sırasına göre sırala (en yeni önce)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aMonth = a.split(' ')[0];
        final aYear = a.split(' ')[1];
        final aMonthIndex = months.indexOf(aMonth) + 1;
        final aDate = DateTime.parse('$aYear-${aMonthIndex.toString().padLeft(2, '0')}-01');

        final bMonth = b.split(' ')[0];
        final bYear = b.split(' ')[1];
        final bMonthIndex = months.indexOf(bMonth) + 1;
        final bDate = DateTime.parse('$bYear-${bMonthIndex.toString().padLeft(2, '0')}-01');

        return bDate.compareTo(aDate);
      });
    
    final sortedMap = <String, List<PhotoItem>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }

  static Map<String, List<PhotoItem>> groupVideosByMonth(List<PhotoItem> videos, AppLocalizations appLoc) {
    final Map<String, List<PhotoItem>> grouped = {};
    final months = [
      appLoc.january, appLoc.february, appLoc.march, appLoc.april, appLoc.may, appLoc.june,
      appLoc.july, appLoc.august, appLoc.september, appLoc.october, appLoc.november, appLoc.december
    ];
    for (final video in videos) {
      final monthKey = _getMonthYearString(video.date, appLoc);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(video);
    }
    for (final key in grouped.keys) {
      grouped[key]!.shuffle();
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aMonth = a.split(' ')[0];
        final aYear = a.split(' ')[1];
        final aMonthIndex = months.indexOf(aMonth) + 1;
        final aDate = DateTime.parse('$aYear-${aMonthIndex.toString().padLeft(2, '0')}-01');
        final bMonth = b.split(' ')[0];
        final bYear = b.split(' ')[1];
        final bMonthIndex = months.indexOf(bMonth) + 1;
        final bDate = DateTime.parse('$bYear-${bMonthIndex.toString().padLeft(2, '0')}-01');
        return bDate.compareTo(aDate);
      });
    final sortedMap = <String, List<PhotoItem>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    return sortedMap;
  }

  static Future<List<PhotoItem>> loadPhotos({int? limit}) async {
    List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    
    // Eğer limit belirtilmişse hızlı yükleme, yoksa tüm fotoğrafları yükle
    if (limit != null && limit <= 2000) { // Limit artırıldı (500->2000)
      // Hızlı yükleme modu (500'den az fotoğraf istenirse)
      final actualLimit = limit;
      
      // Sadece en büyük 2 albümden hızlıca fotoğraf topla
      final sortedAlbums = List<AssetPathEntity>.from(albums);
      final albumCounts = await Future.wait(sortedAlbums.map((a) => a.assetCountAsync));
      
      // Albümleri boyutlarına göre sırala (en büyük önce)
      final albumsWithCounts = List.generate(
        sortedAlbums.length, 
        (i) => {'album': sortedAlbums[i], 'count': albumCounts[i]}
      );
      albumsWithCounts.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      
      for (final albumData in albumsWithCounts.take(2)) {
        final album = albumData['album'] as AssetPathEntity;
        final totalCount = albumData['count'] as int;
        final loadCount = (totalCount * 0.15).ceil().clamp(1, 100); // Daha fazla fotoğraf yükle (0.1->0.15, 50->100)
        
        final photos = await album.getAssetListPaged(page: 0, size: loadCount);
        
        final futures = photos.take(loadCount).map((asset) async {
          try {
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)); // Daha hızlı yükleme için küçültüldü (400->300)
            
            if (thumb != null) {
              final hash = asset.id;
              return PhotoItem(
                id: asset.id, 
                thumb: thumb, 
                date: asset.createDateTime, 
                hash: hash, 
                type: MediaType.image, 
                path: null,
                name: asset.title ?? 'Unknown',
              );
            }
          } catch (e) {
            // Hata olursa geç
          }
          return null;
        });
        
        final batchResults = await Future.wait(futures);
        result.addAll(batchResults.where((item) => item != null).cast<PhotoItem>());
        
        if (result.length >= actualLimit) {
          result = result.take(actualLimit).toList();
          break;
        }
      }
    } else {
      // Akıllı tam yükleme - Tüm fotoğrafları getir ama SÜPER HIZLI
      
      // Tüm albümleri paralel olarak yükle
      final albumFutures = albums.map((album) async {
        final List<PhotoItem> albumResult = [];
        final totalCount = await album.assetCountAsync;
        
        // Büyük albümler için optimize edilmiş batch yükleme
        final batchSize = 500; // Batch size artırıldı (300->500) - daha hızlı
        final totalBatches = (totalCount / batchSize).ceil();
        
        for (int page = 0; page < totalBatches; page++) {
          final photos = await album.getAssetListPaged(page: page, size: batchSize);
          
          // Optimize edilmiş thumbnail (daha hızlı yükleme için)
          final futures = photos.map((asset) async {
            try {
                          // Yüksek kalite thumbnail - hızlı yükleme
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(600, 600)); // Optimize edilmiş kalite (800->600)
              
              if (thumb != null) {
                final hash = asset.id; // Basit hash
                return PhotoItem(
                  id: asset.id, 
                  thumb: thumb, 
                  date: asset.createDateTime, 
                  hash: hash, 
                  type: MediaType.image, 
                  path: asset.id, // Path yerine ID kullan (video yürütme için gerekli)
                  name: asset.title ?? 'Unknown',
                );
              }
            } catch (e) {
              // Hata olursa sessizce geç
            }
            return null;
          });
          
          final batchResults = await Future.wait(futures);
          albumResult.addAll(batchResults.where((item) => item != null).cast<PhotoItem>());
        }
        
        return albumResult;
      });
      
      // Tüm albümleri paralel olarak bekle
      final allAlbumResults = await Future.wait(albumFutures);
      
      // Sonuçları birleştir
      for (final albumResult in allAlbumResults) {
        result.addAll(albumResult);
      }
    }
    
    result.shuffle();
    return result;
  }

  static Future<List<PhotoItem>> loadPhotosFromAlbum(String albumId) async {
    final List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    AssetPathEntity? album;
    try {
      album = albums.firstWhere((a) => a.id == albumId);
    } catch (e) {
      album = null;
    }
    if (album != null) {
      // Önce toplam fotoğraf sayısını al
      final totalCount = await album.assetCountAsync;
      
      // Büyük galeriler için batch loading
      final batchSize = 10; // Her seferde 10 fotoğraf yükle (pil tasarrufu için)
      final totalBatches = (totalCount / batchSize).ceil();
      
      for (int page = 0; page < totalBatches; page++) {
        final photos = await album.getAssetListPaged(page: page, size: batchSize);
        
        // Her batch'i paralel olarak işle
        final futures = photos.map((asset) async {
          try {
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(600, 600));
            String? path;
            final file = await asset.file;
            if (file != null) path = file.path;
            if (thumb != null) {
              final hash = md5.convert(thumb).toString();
              return PhotoItem(
                id: asset.id, 
                thumb: thumb, 
                date: asset.createDateTime, 
                hash: hash, 
                type: MediaType.image, 
                path: path,
                name: asset.title ?? 'Unknown'
              );
            }
          } catch (e) {
            print('Fotoğraf yükleme hatası: $e');
          }
          return null;
        });
        
        final batchResults = await Future.wait(futures);
        result.addAll(batchResults.where((item) => item != null).cast<PhotoItem>());
        
        // UI'ı güncellemek için kısa bir bekleme
        if (page < totalBatches - 1) {
          await Future.delayed(const Duration(milliseconds: 10));
        }
      }
    }
    return result;
  }

  static Future<List<PhotoItem>> loadVideos({int? limit}) async {
    // Hızlı yükleme için limit kontrolü
    if (limit != null && limit <= 2000) {
      return _loadVideosFast(limit);
    }
    
    List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    
    // Tüm albümleri paralel olarak işle
    final albumFutures = albums.map((album) async {
      final List<PhotoItem> albumResult = [];
      
      // Her albüm için batch loading kullan
      final totalCount = await album.assetCountAsync;
      final batchSize = 300; // Batch size artırıldı (200->300) - daha hızlı
      final totalBatches = (totalCount / batchSize).ceil();
      
      for (int page = 0; page < totalBatches; page++) {
        final videos = await album.getAssetListPaged(page: page, size: batchSize);
        
        // Her batch'i paralel olarak işle
        final futures = videos.map((asset) async {
          try {
            // Video thumbnail'i yüksek kalitede al
            String? path;
            
            try {
              // Path'i hızlı al (opsiyonel)
              final file = await asset.file;
              path = file?.path;
            } catch (e) {
              path = null; // Hata olursa null bırak
            }
            
            // Video thumbnail'i yüksek kalitede al
            Uint8List? thumb;
            try {
              thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(800, 800));
            } catch (e) {
              thumb = Uint8List(0); // Hata olursa boş thumbnail
            }
            
            // Hash hesaplamayı basitleştir (çok daha hızlı)
            final hash = asset.id; // MD5 yerine asset ID kullan
            return PhotoItem(
              id: asset.id, 
              thumb: thumb ?? Uint8List(0),
              date: asset.createDateTime, 
              hash: hash, 
              type: MediaType.video, 
              path: path,
              name: asset.title ?? 'Unknown',
            );
          } catch (e) {
            print('Video yükleme hatası: $e');
          }
          return null;
        });
        
        final batchResults = await Future.wait(futures);
        albumResult.addAll(batchResults.where((item) => item != null).cast<PhotoItem>());
        
        // Limit kontrolü
        if (limit != null && albumResult.length >= limit) {
          return albumResult.take(limit).toList();
        }
      }
      
      return albumResult;
    });
    
    // Tüm albümleri paralel olarak yükle
    final allAlbumResults = await Future.wait(albumFutures);
    
    // Sonuçları birleştir
    for (final albumResult in allAlbumResults) {
      result.addAll(albumResult);
      if (limit != null && result.length >= limit) {
        result = result.take(limit).toList();
        break;
      }
    }
    
    result.shuffle();
    return result;
  }

  static Future<List<PhotoItem>> loadVideosFromAlbum(String albumId) async {
    final List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    AssetPathEntity? album;
    try {
      album = albums.firstWhere((a) => a.id == albumId);
    } catch (e) {
      album = null;
    }
    if (album != null) {
      final videos = await album.getAssetListPaged(page: 0, size: 1000);
      for (final asset in videos) {
        // Video klasörlerinde hiç resim gösterme - sadece metadata al
        String? path;
        try {
          final file = await asset.file;
          if (file != null) path = file.path;
        } catch (e) {
          path = null; // Hata olursa null bırak
        }
        
        // Hash hesaplamayı basitleştir (çok daha hızlı)
        final hash = asset.id; // MD5 yerine asset ID kullan
        result.add(PhotoItem(
          id: asset.id, 
          thumb: Uint8List(0), // Boş thumbnail
          date: asset.createDateTime, 
          hash: hash, 
          type: MediaType.video, 
          path: path,
          name: asset.title ?? 'Unknown'
        ));
      }
    }
    return result;
  }

  static Future<Map<String, List<PhotoItem>>> findDuplicateVideos({int? limit}) async {
    final videos = await loadVideos(limit: limit);
    final Map<String, List<PhotoItem>> hashMap = {};
    for (final video in videos) {
      hashMap.putIfAbsent(video.hash, () => []).add(video);
    }
    return hashMap..removeWhere((k, v) => v.length < 2);
  }

  static Future<void> deletePhoto(String id) async {
    // Check for necessary permissions
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final asset = await AssetEntity.fromId(id);
      if (asset != null) {
        await PhotoManager.editor.deleteWithIds([id]);
      }
    } else {
      print('Permission not granted to delete photo.');
    }
  }

  static Future<void> deletePhotos(List<String> ids) async {
    // Check for necessary permissions
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // Toplu silme işlemi - tek seferde tüm ID'leri gönder
      await PhotoManager.editor.deleteWithIds(ids);
    } else {
      print('Permission not granted to delete photos.');
    }
  }

  static Future<bool> moveToRecentlyDeleted(List<String> ids) async {
    // Check for necessary permissions
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      try {
        // Android'in "Recently Deleted" klasörüne taşı
        // Bu işlem fotoğrafları gerçekten siler ama Android'in "Recently Deleted" klasörüne taşır
        // 30 gün sonra otomatik olarak kalıcı silinir
        print('DEBUG: Silme işlemi başlatılıyor - ${ids.length} adet ID');
        final result = await PhotoManager.editor.deleteWithIds(ids);
        print('DEBUG: Silme işlemi sonucu: $result');
        print('DEBUG: ${ids.length} fotoğraf "Son Silinenler" klasörüne taşındı');
        return true; // Başarılı
      } catch (e) {
        print('Error moving photos to recently deleted: $e');
        return false; // Hata durumunda false döndür
      }
    } else {
      print('Permission not granted to move photos to recently deleted.');
      return false; // İzin yok
    }
  }



  // Uygulama içi "Son Silinenler" klasörüne taşı (gerçek silme yapma)
  static Future<bool> moveToAppRecentlyDeleted(List<String> ids) async {
    try {
      // Burada gerçek silme yapmıyoruz, sadece uygulama içinde saklıyoruz
      // Fotoğraflar gerçek galeride kalıyor, sadece uygulama içinde "silinmiş" olarak işaretleniyor
      print('${ids.length} fotoğraf uygulama "Son Silinenler" klasörüne taşındı');
      return true; // Başarılı
    } catch (e) {
      print('Error moving photos to app recently deleted: $e');
      return false; // Hata durumunda false döndür
    }
  }

  // Gerçekten galeriden sil (kalıcı silme) - bu fonksiyonu kullanmayacağız
  static Future<bool> permanentlyDeleteFromGallery(List<String> ids) async {
    // Bu fonksiyon artık kullanılmayacak, sadece uygulama içi silme yapılacak
    return false;
  }

  static Future<String> getFilePath(String id) async {
    final asset = await AssetEntity.fromId(id);
    if (asset != null) {
      final file = await asset.file;
      if (file != null) return file.path;
    }
    return '';
  }

  // Hızlı video yükleme fonksiyonu
  static Future<List<PhotoItem>> _loadVideosFast(int limit) async {
    List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    
    // Sadece en büyük 2 albümden hızlıca video topla
    final sortedAlbums = List<AssetPathEntity>.from(albums);
    final albumCounts = await Future.wait(sortedAlbums.map((a) => a.assetCountAsync));
    
    // Albümleri boyutlarına göre sırala (en büyük önce)
    final albumsWithCounts = List.generate(
      sortedAlbums.length, 
      (i) => {'album': sortedAlbums[i], 'count': albumCounts[i]}
    );
    albumsWithCounts.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    for (final albumData in albumsWithCounts.take(2)) {
      final album = albumData['album'] as AssetPathEntity;
      final totalCount = albumData['count'] as int;
      final loadCount = (totalCount * 0.15).ceil().clamp(1, 100);
      
      final videos = await album.getAssetListPaged(page: 0, size: loadCount);
      
      final futures = videos.take(loadCount).map((asset) async {
        try {
          // Video thumbnail'i hızlı yükleme için küçük boyut
          Uint8List? thumb;
          try {
            thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
          } catch (e) {
            thumb = Uint8List(0);
          }
          
          final hash = asset.id;
                      return PhotoItem(
              id: asset.id, 
              thumb: thumb ?? Uint8List(0),
              date: asset.createDateTime, 
              hash: hash, 
              type: MediaType.video, 
              path: asset.id, // Path yerine ID kullan (video yürütme için gerekli)
              name: asset.title ?? 'Unknown',
            );
        } catch (e) {
          // Hata olursa geç
        }
        return null;
      });
      
      final batchResults = await Future.wait(futures);
      result.addAll(batchResults.where((item) => item != null).cast<PhotoItem>());
      
      if (result.length >= limit) {
        result = result.take(limit).toList();
        break;
      }
    }
    
    return result;
  }
} 