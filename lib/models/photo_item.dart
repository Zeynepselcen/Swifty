import 'dart:typed_data';

enum MediaType { image, video }

class PhotoItem {
  final String id;
  final Uint8List thumb;
  final DateTime date;
  final String hash;
  final MediaType type;
  final String? path;
  final String name;

  PhotoItem({required this.id, required this.thumb, required this.date, required this.hash, required this.type, this.path, required this.name});
} 