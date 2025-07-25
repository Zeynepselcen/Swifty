// HATIRLATMA: Galeri izni durumu SharedPreferences ile tutuluyor. Sorun çıkarsa bu dosyayı silebilirsin.
import 'package:shared_preferences/shared_preferences.dart';

class GalleryPermissionHelper {
  static const String _galleryPermissionKey = 'gallery_permission_granted';

  static Future<bool> isPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_galleryPermissionKey) ?? false;
  }

  static Future<void> setPermissionGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_galleryPermissionKey, granted);
  }
} 