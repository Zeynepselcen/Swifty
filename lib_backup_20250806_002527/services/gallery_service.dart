import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/photo_item.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<List<PhotoItem>> loadPhotos({int? limit}) async {
    List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    
    // Tüm albümleri paralel olarak işle
    final albumFutures = albums.map((album) async {
      final List<PhotoItem> albumResult = [];
      
      // Her albüm için batch loading kullan
      final totalCount = await album.assetCountAsync;
      final batchSize = 200; // Optimal batch size - hızlı ve stabil
      final totalBatches = (totalCount / batchSize).ceil();
      
      for (int page = 0; page < totalBatches; page++) {
        final photos = await album.getAssetListPaged(page: page, size: batchSize);
        
        // Her batch'i paralel olarak işle
        final futures = photos.map((asset) async {
          try {
            // Thumbnail boyutunu küçült (daha hızlı yükleme)
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(150, 150));
            String? path;
            
            // Path'i paralel olarak al
            final pathFuture = asset.file.then((file) => file?.path);
            path = await pathFuture;
            
            if (thumb != null) {
              final hash = md5.convert(thumb).toString();
              return PhotoItem(
                id: asset.id, 
                thumb: thumb, 
                date: asset.createDateTime, 
                hash: hash, 
                type: MediaType.image, 
                path: path
              );
            }
          } catch (e) {
            print('Fotoğraf yükleme hatası: $e');
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
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
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
                path: path
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
    List<PhotoItem> result = [];
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    
    // Tüm albümleri paralel olarak işle
    final albumFutures = albums.map((album) async {
      final List<PhotoItem> albumResult = [];
      
      // Her albüm için batch loading kullan
      final totalCount = await album.assetCountAsync;
      final batchSize = 200; // Optimal batch size - hızlı ve stabil
      final totalBatches = (totalCount / batchSize).ceil();
      
      for (int page = 0; page < totalBatches; page++) {
        final videos = await album.getAssetListPaged(page: page, size: batchSize);
        
        // Her batch'i paralel olarak işle
        final futures = videos.map((asset) async {
          try {
            // Thumbnail boyutunu küçült (daha hızlı yükleme)
            final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(150, 150));
            String? path;
            
            // Path'i paralel olarak al
            final pathFuture = asset.file.then((file) => file?.path);
            path = await pathFuture;
            
            if (thumb != null) {
              final hash = md5.convert(thumb).toString();
              return PhotoItem(
                id: asset.id, 
                thumb: thumb, 
                date: asset.createDateTime, 
                hash: hash, 
                type: MediaType.video, 
                path: path
              );
            }
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
        final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
        String? path;
        final file = await asset.file;
        if (file != null) path = file.path;
        if (thumb != null) {
          final hash = md5.convert(thumb).toString();
          result.add(PhotoItem(id: asset.id, thumb: thumb, date: asset.createDateTime, hash: hash, type: MediaType.video, path: path));
        }
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
    final asset = await AssetEntity.fromId(id);
    if (asset != null) {
      await PhotoManager.editor.deleteWithIds([id]);
    }
  }

  static Future<String> getFilePath(String id) async {
    final asset = await AssetEntity.fromId(id);
    if (asset != null) {
      final file = await asset.file;
      if (file != null) return file.path;
    }
    return '';
  }
} 