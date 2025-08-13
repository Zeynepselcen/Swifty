import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  List<Map<String, dynamic>> deletedFiles = [];
  bool isLoading = true;
  static const MethodChannel _channel = MethodChannel('gallery_service');

  @override
  void initState() {
    super.initState();
    _loadDeletedFiles();
  }

  // MediaStore'u yenile - yeni dosyaları galeriye ekle
  Future<void> _refreshMediaStore(String filePath) async {
    try {
      await _channel.invokeMethod('refreshMediaStore', {
        'filePath': filePath,
      });
      print('MediaStore yenilendi: $filePath');
    } catch (e) {
      print('MediaStore yenileme hatası: $e');
    }
  }

  // Tüm silinen dosyaları temizle
  Future<void> _clearAllDeletedFiles() async {
    final appLoc = AppLocalizations.of(context)!;
    try {
      // Onay dialog'u göster
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appLoc.clearAll),
          content: Text('Are you sure you want to permanently delete all deleted files? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(appLoc.clearAll),
            ),
          ],
        ),
      );

      if (shouldClear == true) {
        // JSON dosyasını temizle
        final appDir = await getApplicationDocumentsDirectory();
        final deletedFilesPath = '${appDir.path}/deleted_files.json';
        final deletedFilesFile = File(deletedFilesPath);
        
        if (await deletedFilesFile.exists()) {
          await deletedFilesFile.delete();
        }

        // Trash klasörünü temizle
        final swiftyTrashDir = Directory('${appDir.path}/swifty_trash');
        if (await swiftyTrashDir.exists()) {
          await swiftyTrashDir.delete(recursive: true);
        }

        // UI'yi güncelle
        setState(() {
          deletedFiles.clear();
        });

        // Başarı mesajı göster
        if (mounted) {
          final appLoc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLoc.allDeletedFilesCleared),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkAccent
                  : Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Temizleme hatası: $e');
      if (mounted) {
        final appLoc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appLoc.clearError}: $e'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[700]
                : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDeletedFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final deletedFilesPath = '${appDir.path}/deleted_files.json';
      final deletedFilesFile = File(deletedFilesPath);

      if (await deletedFilesFile.exists()) {
        final content = await deletedFilesFile.readAsString();
        if (content.isNotEmpty) {
          final files = List<Map<String, dynamic>>.from(
            json.decode(content) as List
          );

          // Süresi dolmamış dosyaları filtrele
          final now = DateTime.now().millisecondsSinceEpoch;
          final validFiles = files.where((file) {
            final expiresAt = file['expiresAt'] as int;
            return now < expiresAt;
          }).toList();

          setState(() {
            deletedFiles = validFiles;
            isLoading = false;
          });
        } else {
          setState(() {
            deletedFiles = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          deletedFiles = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Silinen dosyalar yüklenirken hata: $e');
      setState(() {
        deletedFiles = [];
        isLoading = false;
      });
    }
  }

  Future<void> _restoreFile(Map<String, dynamic> fileInfo) async {
    try {
      final originalPath = fileInfo['originalPath'] as String;
      final trashPath = fileInfo['trashPath'] as String;
      final fileName = fileInfo['fileName'] as String;
      final originalFolderPath = fileInfo['originalFolderPath'] as String?;

      // Loading göster
      final appLoc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${fileName.length > 20 ? fileName.substring(0, 20) + '...' : fileName} ${appLoc.fileRestoring}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkAccent
              : AppColors.mainGradient.colors.first,
          duration: const Duration(seconds: 2),
        ),
      );

      final trashFile = File(trashPath);
      if (await trashFile.exists()) {
        // Orijinal klasöre geri kopyala
        String restoredPath;
        
        if (originalFolderPath != null && originalFolderPath.isNotEmpty) {
          // Orijinal klasör yolunu kullan
          final originalDir = Directory(originalFolderPath);
          
          // Orijinal klasör yoksa oluştur
          if (!await originalDir.exists()) {
            await originalDir.create(recursive: true);
          }
          
          // Orijinal dosya adını kullan
          restoredPath = originalPath;
        } else {
          // Fallback: DCIM klasörüne kopyala
          final dcimDir = Directory('/storage/emulated/0/DCIM');
          final restoredDir = Directory('${dcimDir.path}/Restored');
          
          // Restored klasörünü oluştur
          if (!await restoredDir.exists()) {
            await restoredDir.create(recursive: true);
          }

          // Benzersiz dosya adı oluştur
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final nameWithoutExt = path.basenameWithoutExtension(fileName);
          final ext = path.extension(fileName);
          final restoredFileName = '${nameWithoutExt}_restored_$timestamp$ext';
          restoredPath = '${restoredDir.path}/$restoredFileName';
        }

        // Dosyayı orijinal konumuna kopyala
        await trashFile.copy(restoredPath);
        await trashFile.delete(); // Trash dosyasını sil

        // MediaStore'u yenile - dosyayı galeriye ekle
        await _refreshMediaStore(restoredPath);

        // JSON dosyasından kaldır
        await _removeFromJson(fileInfo);

        // Başarı mesajı
        String message;
        if (originalFolderPath != null && originalFolderPath.isNotEmpty) {
          final folderName = path.basename(originalFolderPath);
          final shortFileName = fileName.length > 15 ? fileName.substring(0, 15) + '...' : fileName;
          message = '$shortFileName ${appLoc.fileRestoredToFolder}$folderName${appLoc.folderSuffix}';
        } else {
          final shortFileName = fileName.length > 15 ? fileName.substring(0, 15) + '...' : fileName;
          message = '$shortFileName ${appLoc.fileRestoredToDcim}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkAccent
                : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Listeyi yenile
        await _loadDeletedFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appLoc.fileNotFound}: $fileName'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[700]
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Dosya geri alma hatası: $e');
      final appLoc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLoc.restoreError}: $e'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.red[700]
              : Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFromJson(Map<String, dynamic> fileInfo) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final deletedFilesPath = '${appDir.path}/deleted_files.json';
      final deletedFilesFile = File(deletedFilesPath);

      if (await deletedFilesFile.exists()) {
        final content = await deletedFilesFile.readAsString();
        if (content.isNotEmpty) {
          List<Map<String, dynamic>> files = List<Map<String, dynamic>>.from(
            json.decode(content) as List
          );

          // Dosyayı listeden kaldır
          files.removeWhere((file) => 
            file['trashPath'] == fileInfo['trashPath']
          );

          // Güncellenmiş listeyi kaydet
          await deletedFilesFile.writeAsString(json.encode(files));
        }
      }
    } catch (e) {
      print('JSON güncelleme hatası: $e');
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _getTimeRemaining(int expiresAt) {
    final appLoc = AppLocalizations.of(context)!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expiresAt - now;
    final days = (remaining / (1000 * 60 * 60 * 24)).floor();
    final hours = ((remaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)).floor();
    
    if (days > 0) {
      return appLoc.daysRemaining(days, hours);
    } else if (hours > 0) {
      return appLoc.hoursRemaining(hours);
    } else {
      return appLoc.expiringSoon;
    }
  }

  Color _getRemainingColor(int expiresAt) {
    final appLoc = AppLocalizations.of(context)!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expiresAt - now;

    if (remaining < 0) {
      return Colors.red; // Süresi dolmuş
    } else if (remaining < (1000 * 60 * 60 * 24)) { // 24 saatten az kalan
      return Colors.orange;
    } else {
      return Colors.green; // 24 saatten fazla kalan
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackgroundPrimary
          : Colors.white,
      appBar: AppBar(
        title: Text(appLoc.recentlyDeletedTitle),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkBackgroundSecondary
            : const Color(0xFFB24592),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeletedFiles,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deletedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.recentlyDeletedFilesNotFound,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: deletedFiles.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                    final file = deletedFiles[index];
                    final fileName = file['fileName'] as String;
                    final deletedAt = file['deletedAt'] as int;
                    final expiresAt = file['expiresAt'] as int;
                    final trashPath = file['trashPath'] as String;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCardBackground
                          : Colors.white,
                      child: ListTile(
                        leading: FutureBuilder<File?>(
                          future: File(trashPath).exists().then((exists) => exists ? File(trashPath) : null),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  snapshot.data!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      backgroundColor: const Color(0xFF4DB6AC),
                                      child: Icon(
                                        fileName.toLowerCase().contains('.mp4') || 
                                        fileName.toLowerCase().contains('.mov')
                                            ? Icons.video_file
                                            : Icons.image,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                backgroundColor: const Color(0xFF4DB6AC),
                                child: Icon(
                                  fileName.toLowerCase().contains('.mp4') || 
                                  fileName.toLowerCase().contains('.mov')
                                      ? Icons.video_file
                                      : Icons.image,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                        title: Text(
                          fileName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextPrimary
                                : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.deletedAt}: ${_formatDate(deletedAt)}',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              _getTimeRemaining(expiresAt),
                              style: TextStyle(
                                color: _getRemainingColor(expiresAt),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restoreFile(file),
                              tooltip: AppLocalizations.of(context)!.restoreFile,
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.blue),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.fileDetails),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Dosya: $fileName'),
                                        Text('Orijinal: ${file['originalPath']}'),
                                        Text('Trash: $trashPath'),
                                        Text('${AppLocalizations.of(context)!.deletedAt}: ${_formatDate(deletedAt)}'),
                                        Text('${AppLocalizations.of(context)!.timeRemaining}: ${_getTimeRemaining(expiresAt)}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)!.close),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: 'Detaylar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                        ),
                      ),
                      // Temizleme butonu
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: Theme.of(context).brightness == Brightness.dark
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.darkAccent,
                                    AppColors.darkAccentLight,
                                  ],
                                )
                              : AppColors.mainGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.3)
                                  : AppColors.cardShadow,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: deletedFiles.isNotEmpty ? _clearAllDeletedFiles : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.delete_forever, size: 24),
                          label: Text(
                            appLoc.deleteAllButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
    );
  }
} 