import '../models/photo_item.dart';

class RecentlyDeletedManager {
  static final RecentlyDeletedManager _instance = RecentlyDeletedManager._internal();
  factory RecentlyDeletedManager() => _instance;
  RecentlyDeletedManager._internal();

  final List<Map<String, dynamic>> _deletedPhotos = [];

  List<Map<String, dynamic>> get deletedPhotos => List.unmodifiable(_deletedPhotos);

  void addDeletedPhoto(PhotoItem photo, int index, int fileSize) {
    _deletedPhotos.add({
      'photo': photo,
      'index': index,
      'fileSize': fileSize,
      'deletedAt': DateTime.now(),
    });
  }

  void restoreLastDeletedPhoto() {
    if (_deletedPhotos.isNotEmpty) {
      _deletedPhotos.removeLast();
    }
  }

  void restorePhotoAt(int index) {
    if (index >= 0 && index < _deletedPhotos.length) {
      _deletedPhotos.removeAt(index);
    }
  }

  void clear() {
    _deletedPhotos.clear();
  }

  int get totalDeletedCount => _deletedPhotos.length;

  int get totalFreedSpace {
    return _deletedPhotos.fold(0, (sum, item) => sum + (item['fileSize'] as int));
  }

  List<PhotoItem> get deletedPhotoItems {
    return _deletedPhotos.map((item) => item['photo'] as PhotoItem).toList();
  }
}
