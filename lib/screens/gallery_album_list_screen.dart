import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_cleaner_screen.dart';
import 'dart:math';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../services/gallery_service.dart';
import '../models/photo_item.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'video_player_screen.dart';

// Albüm sıralama türleri için enum
enum AlbumSortType {
  size,
  date,
  name,
  filesize,
}

class GalleryAlbumListScreen extends StatefulWidget {
  final Locale? currentLocale;
  final void Function(Locale)? onLocaleChanged;

  const GalleryAlbumListScreen({Key? key, this.currentLocale, this.onLocaleChanged}) : super(key: key);

  @override
  _GalleryAlbumListScreenState createState() => _GalleryAlbumListScreenState();
}

class _GalleryAlbumListScreenState extends State<GalleryAlbumListScreen> {
  // Albüm ve fotoğraf listeleri
  List<_AlbumWithCount> _albums = [];
  bool _loading = true;
  AlbumSortType _sortType = AlbumSortType.size;
  late String _selectedLanguage;
  List<PhotoItem> _allPhotos = [];
  Map<String, List<PhotoItem>> _photosByMonth = {};
  bool _loadingPhotos = true;

  // Analiz state değişkenleri
  bool _analysisStarted = false;
  bool _analysisCompleted = false;

  // Arama ile ilgili
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  List<PhotoItem> _searchResults = [];
  String _lastSearch = '';
  List<String> _lastMatchedLabels = [];
  List<String> _topLabels = [];

  // Etiket ve etiketleme durumu
  Map<String, List<String>> _photoLabels = {};
  bool _labelingInProgress = true;
  List<String> _suggestedKeywords = [];
  bool _isVideoMode = false;

  // Analiz ilerlemesi ve etiketi
  double _analysisProgress = 0.0;
  String _analysisLabel = '';

  // Anahtar kelime haritası (Türkçe anahtarlar ve İngilizce benzerleri)
  final Map<String, List<String>> _keywordMap = {
    'araba': ['car', 'automobile'],
    'kedi': ['cat'],
    'köpek': ['dog'],
    'yemek': ['food', 'meal', 'dish'],
    'selfie': ['selfie'],
    'manzara': ['landscape', 'scenery'],
    'gökyüzü': ['sky'],
    'güneş': ['sun'],
    'gece': ['night'],
    'arkadaş': ['friend', 'friends'],
    'aile': ['family'],
    'çocuk': ['child', 'kid', 'children'],
    'doğa': ['nature'],
    'şehir': ['city', 'urban'],
    'yazı': ['text', 'writing', 'note'],
    'belge': ['document', 'paper'],
    'evrak': ['document', 'paper'],
    'makine': ['machine'],
    'uçak': ['plane', 'airplane'],
    'tren': ['train'],
    'bisiklet': ['bicycle', 'bike'],
    'çiçek': ['flower', 'plant'],
    'ağaç': ['tree', 'plant'],
    'deniz': ['sea', 'ocean', 'beach', 'water'],
    'göl': ['lake'],
    'dağ': ['mountain'],
    'gözlük': ['glasses'],
    'telefon': ['phone', 'cellphone', 'mobile'],
    'bilgisayar': ['computer', 'laptop', 'pc'],
    'masa': ['table', 'desk'],
    'kitap': ['book'],
    'defter': ['notebook'],
    'kalem': ['pen', 'pencil'],
    'tatlı': ['dessert', 'sweet'],
    'kahve': ['coffee'],
    'çay': ['tea'],
    'su': ['water'],
    'spor': ['sport', 'sports'],
    'futbol': ['football', 'soccer'],
    'basketbol': ['basketball'],
    'voleybol': ['volleyball'],
    'tenis': ['tennis'],
    'koşu': ['run', 'running'],
    'yüzme': ['swimming', 'swim'],
    'müzik': ['music'],
    'gitar': ['guitar'],
    'piyano': ['piano'],
    'davul': ['drum', 'drums'],
    'konser': ['concert'],
    'sahne': ['stage'],
    'dans': ['dance', 'dancing'],
    'düğün': ['wedding'],
    'doğum günü': ['birthday'],
    'parti': ['party'],
    'tatil': ['holiday', 'vacation', 'trip'],
    'seyahat': ['travel', 'trip', 'journey'],
    'otobüs': ['bus'],
    'motosiklet': ['motorcycle', 'bike'],
    'alışveriş': ['shopping'],
    'market': ['market', 'grocery'],
    'alışveriş merkezi': ['mall', 'shopping mall'],
    'restoran': ['restaurant'],
    'kafe': ['cafe', 'coffee shop'],
    'bar': ['bar'],
    'otel': ['hotel'],
    'plaj': ['beach'],
    'havuz': ['pool', 'swimming pool'],
    'park': ['park'],
    'bahçe': ['garden'],
    'hayvan': ['animal', 'animals'],
    'kuş': ['bird'],
    'balık': ['fish'],
    'at': ['horse'],
    'inek': ['cow'],
    'koyun': ['sheep'],
    'keçi': ['goat'],
    'tavuk': ['chicken', 'hen'],
    'ördek': ['duck'],
    'aslan': ['lion'],
    'kaplan': ['tiger'],
    'fil': ['elephant'],
    'zebra': ['zebra'],
    'maymun': ['monkey'],
    'ayı': ['bear'],
    'tilki': ['fox'],
    'tavşan': ['rabbit'],
    'sinema': ['cinema', 'movie', 'film'],
    'film': ['movie', 'film'],
    'dizi': ['series', 'tv series'],
    'televizyon': ['television', 'tv'],
    'oyun': ['game', 'play', 'video game'],
    'bilgisayar oyunu': ['video game', 'computer game'],
    'konsol': ['console'],
    'tablet': ['tablet'],
    'kamera': ['camera'],
    'fotoğraf makinesi': ['camera'],
    'video': ['video'],
    'ışık': ['light'],
    'mikrofon': ['microphone'],
    'hoparlör': ['speaker'],
    'kulaklık': ['headphone', 'earphone'],
    'radyo': ['radio'],
    'gazete': ['newspaper'],
    'dergi': ['magazine'],
    'silgi': ['eraser'],
    'cetvel': ['ruler'],
    'makas': ['scissors'],
    'yapıştırıcı': ['glue'],
    'boya': ['paint'],
    'fırça': ['brush'],
    'tuval': ['canvas'],
    'resim': ['picture', 'painting', 'image'],
    'heykel': ['sculpture'],
    'sergi': ['exhibition'],
    'müze': ['museum'],
    'galeri': ['gallery'],
    'tiyatro': ['theatre', 'theater'],
    'opera': ['opera'],
    'bale': ['ballet'],
    'festival': ['festival'],
    'yarışma': ['competition', 'contest'],
    'turnuva': ['tournament'],
    'maç': ['match', 'game'],
    'antrenman': ['training', 'practice'],
    'egzersiz': ['exercise'],
    'spor salonu': ['gym', 'fitness'],
    'fitness': ['fitness'],
    'yoga': ['yoga'],
    'pilates': ['pilates'],
    'yürüyüş': ['walk', 'walking'],
    'dalış': ['diving'],
    'sörf': ['surf', 'surfing'],
    'kayak': ['ski', 'skiing'],
    'snowboard': ['snowboard'],
    'dağcılık': ['mountaineering', 'climbing'],
    'kamp': ['camp', 'camping'],
    'doğa yürüyüşü': ['hiking', 'trekking'],
    'piknik': ['picnic'],
    'balık tutma': ['fishing'],
    'avcılık': ['hunting'],
    'golf': ['golf'],
    'masa tenisi': ['table tennis', 'ping pong'],
    'badminton': ['badminton'],
    'hentbol': ['handball'],
    'rugby': ['rugby'],
    'beyzbol': ['baseball'],
    'kriket': ['cricket'],
    'hokey': ['hockey'],
    'amerikan futbolu': ['american football'],
    'boks': ['boxing'],
    'güreş': ['wrestling'],
    'judo': ['judo'],
    'karate': ['karate'],
    'taekwondo': ['taekwondo'],
    'kung fu': ['kung fu'],
    'aikido': ['aikido'],
    'kendo': ['kendo'],
    'eskrim': ['fencing'],
    'okçuluk': ['archery'],
    'binicilik': ['equestrian', 'horse riding'],
    'at yarışı': ['horse race', 'horse racing'],
    'motor sporları': ['motor sports', 'motorsport'],
    'araba yarışı': ['car race', 'car racing'],
    'motosiklet yarışı': ['motorcycle race', 'motorcycle racing'],
    'bisiklet yarışı': ['bicycle race', 'cycling'],
    'yelkencilik': ['sailing'],
    'kürek': ['rowing'],
    'kanoculuk': ['canoeing'],
    'rafting': ['rafting'],
    'yamaç paraşütü': ['paragliding'],
    'uçurtma': ['kite'],
    'balon': ['balloon'],
    'helikopter': ['helicopter'],
    'roket': ['rocket'],
    'uzay': ['space'],
    'astronomi': ['astronomy'],
    'ay': ['moon'],
    'yıldız': ['star'],
    'gezegen': ['planet'],
    'galaksi': ['galaxy'],
    'evren': ['universe']
  };

  // Desteklenen diller
  final Map<String, String> _languages = {
    'tr': 'Türkçe',
    'en': 'English',
    'es': 'Español',
  };

  // Dillerin bayrakları
  final Map<String, String> _flags = {
    'tr': '🇹🇷',
    'en': '🇬🇧',
    'es': '🇪🇸',
  };

  Locale _currentLocale = const Locale('tr');
  bool _isDarkTheme = false;

  // Dil değiştirme dialogu
  void _showLanguageDialog() async {
    final appLoc = AppLocalizations.of(context)!;
    final entries = _languages.entries.toList();
    entries.sort((a, b) => a.key == _currentLocale.languageCode ? -1 : b.key == _currentLocale.languageCode ? 1 : 0);

    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.13);
        final textColor = isDark ? Colors.white : Colors.black87;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Stack(
            children: [
              const _WavyBackground(),
              Center(
                child: Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 340,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appLoc.languageSelect,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: textColor),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: appLoc.cancel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appLoc.pleaseSelectLanguage,
                          style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15),
                        ),
                        const SizedBox(height: 18),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: entries.map((e) {
                              final isSelected = _currentLocale.languageCode == e.key;
                              return AnimatedScale(
                                scale: isSelected ? 1.04 : 1.0,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                child: AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.85,
                                  duration: const Duration(milliseconds: 180),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(e.key),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08))
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18),
                                        border: isSelected ? Border.all(color: textColor, width: 2) : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(_flags[e.key] ?? '', style: const TextStyle(fontSize: 32)),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              e.value,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: textColor,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected) Icon(Icons.check, color: textColor, size: 26),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _currentLocale.languageCode) {
      setState(() {
        _currentLocale = Locale(selected);
      });
      widget.onLocaleChanged?.call(Locale(selected));
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${appLoc.languageChangedTo} ${_languages[selected]}')),
      );
    }
  }

  // RewardedAd ile ilgili kodları yorum satırına al
  /*
  RewardedAd? _rewardedAd;
  bool _rewardedAdLoaded = false;
  bool _adWatched = false;
  bool _analysisStarted = false;
  bool _analysisCompleted = false;

  void _onStartAnalysis() {
    setState(() {
      _analysisStarted = true;
      _analysisCompleted = false;
    });
    _labelAllPhotos().then((_) {
      setState(() {
        _analysisCompleted = true;
      });
    });
  }
  */
  // Analizi başlat butonunda doğrudan _startAnalysis çağrılacak
  void _startAnalysis() {
    setState(() {
      _analysisStarted = true;
      _analysisCompleted = false;
    });
    _labelAllPhotos().then((_) {
      setState(() {
        _analysisCompleted = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLocale?.languageCode ?? 'tr';
    _currentLocale = widget.currentLocale ?? const Locale('tr');
    _initializeApp();
    _fetchAlbums();
    _fetchAllPhotos();
    // _loadRewardedAd(); // Reklam yükleme kaldırıldı
  }

  // RewardedAd ile ilgili kodları yorum satırına al
  /*
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3310704693183811/5492119308', // Gerçek ödüllü reklam birimi ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _rewardedAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _rewardedAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showRewardedAdAndStartAnalysis() {
    if (_rewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
          if (!_analysisStarted) {
            _startAnalysis();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
          if (!_analysisStarted) {
            _startAnalysis();
          }
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          setState(() {
            _adWatched = true;
          });
          if (!_analysisStarted) {
            _startAnalysis();
          }
        },
      );
    } else {
      // Reklam yüklenmediyse analiz yine de başlasın
      _startAnalysis();
    }
  }
  */

  Future<void> _initializeApp() async {
    // Android özelliklerini başlat
    await GalleryService.initializeAndroidFeatures();
    // Albüm ve fotoğraf listelerini hemen yükle
    _fetchAlbums();
    _fetchAllPhotos();
    // Analiz işlemini arka planda başlat
    Future.microtask(() => _labelAllPhotos());
  }

  Map<String, int> _albumSizes = {};
  Future<void> _fetchAlbums() async {
    setState(() { _loading = true; });
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      setState(() { _loading = false; });
      _showPermissionDeniedDialog();
      return;
    }
    final albums = await PhotoManager.getAssetPathList(type: _isVideoMode ? RequestType.video : RequestType.image);
    final List<_AlbumWithCount> albumList = [];
    final Map<String, int> albumSizes = {};
    bool needSizes = _sortType == AlbumSortType.filesize;
    Map<String, dynamic> cache = needSizes ? await GalleryService.loadAnalysisCache() : {};
    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count == 0) continue; // Skip empty albums
      final latestDate = await _getLatestAssetDate(album);
      num totalSize = 0;
      if (needSizes && count > 0) {
        final assets = await album.getAssetListPaged(page: 0, size: count);
        for (final asset in assets) {
          final cached = cache[asset.id];
          if (cached != null && cached['size'] != null) {
            totalSize += cached['size'];
          }
        }
        albumSizes[album.id] = totalSize.toInt();
      }
      albumList.add(_AlbumWithCount(album: album, count: count, latestDate: latestDate));
    }
    setState(() {
      _albums = albumList;
      _albumSizes = albumSizes;
      _loading = false;
    });
  }

  Future<DateTime?> _getLatestAssetDate(AssetPathEntity album) async {
    final assets = await album.getAssetListPaged(page: 0, size: 1);
    if (assets.isNotEmpty) {
      return assets.first.createDateTime;
    }
    return null;
  }

  List<_AlbumWithCount> get _sortedAlbums {
    final list = List<_AlbumWithCount>.from(_albums);
    switch (_sortType) {
      case AlbumSortType.size:
        list.sort((a, b) => b.count.compareTo(a.count));
        break;
      case AlbumSortType.date:
        list.sort((a, b) => (b.latestDate ?? DateTime(1970)).compareTo(a.latestDate ?? DateTime(1970)));
        break;
      case AlbumSortType.name:
        list.sort((a, b) => a.album.name.toLowerCase().compareTo(b.album.name.toLowerCase()));
        break;
      case AlbumSortType.filesize:
        list.sort((a, b) => (_albumSizes[b.album.id] ?? 0).compareTo(_albumSizes[a.album.id] ?? 0));
        break;
    }
    return list;
  }

  Future<void> _fetchAllPhotos() async {
    setState(() { _loadingPhotos = true; });
    if (_isVideoMode) {
      final videos = await GalleryService.loadVideos();
      _allPhotos = videos;
      _photosByMonth = {};
      for (final video in videos) {
        final key = DateFormat('yyyy-MM').format(video.date);
        _photosByMonth.putIfAbsent(key, () => []).add(video);
      }
    } else {
    final photos = await GalleryService.loadPhotos();
    _allPhotos = photos;
    _photosByMonth = {};
    for (final photo in photos) {
      final key = DateFormat('yyyy-MM').format(photo.date);
      _photosByMonth.putIfAbsent(key, () => []).add(photo);
      }
    }
    setState(() { _loadingPhotos = false; });
  }

  Future<Map<String, dynamic>> _analyzePhotosIsolate(Map<String, dynamic> params) async {
    final List<PhotoItem> photos = params['photos'];
    final Map<String, dynamic> cache = params['cache'];
    final double confidenceThreshold = params['confidenceThreshold'] ?? 0.4;
    final Map<String, dynamic> result = {};
    final imageLabeler = GoogleMlKit.vision.imageLabeler(ImageLabelerOptions(confidenceThreshold: confidenceThreshold));
    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final cached = cache[photo.id];
      String hash = photo.hash;
      List<String> labels = [];
      int fileSize = 0;
      bool needsAnalysis = true;
      if (cached != null && cached['hash'] == hash && cached['labels'] != null && cached['size'] != null) {
        labels = List<String>.from(cached['labels']);
        fileSize = cached['size'];
        needsAnalysis = false;
      }
      if (needsAnalysis) {
        try {
          final filePath = photo.path;
          if (filePath == null || filePath.isEmpty) continue;
          final inputImage = InputImage.fromFilePath(filePath);
          final detectedLabels = await imageLabeler.processImage(inputImage);
          labels = detectedLabels.map((l) => l.label.toLowerCase()).toList();
          print('Photo ${photo.id} labels: $labels');
          fileSize = await GalleryService.getAndroidFileSize(filePath);
        } catch (e) {
          // Hata durumunda boş bırak
        }
      }
      result[photo.id] = {
        'labels': labels,
        'hash': hash,
        'size': fileSize,
      };
      // Her 10 fotoğrafta bir kısa bekleme ekle (performans için)
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Analiz ilerlemesini ve kalan fotoğraf sayısını güncelle
      final progress = (i + 1) / photos.length;
      params['progressCallback']?.call(progress, photos.length - (i + 1));
    }
    await imageLabeler.close();
    return result;
  }

  Future<void> _labelAllPhotos({bool forceRefresh = false}) async {
    print('ANALİZ BAŞLIYOR');
    try {
      setState(() { _labelingInProgress = true; _analysisProgress = 0.0; _analysisLabel = 'Gallery analysis starting...'; });
    
    // Android bildirimi başlat
    await GalleryService.showAndroidNotification(
        title: 'Gallery Analysis Starting',
        content: 'Gallery analysis is starting. This might take a while.',
      progress: 0,
      maxProgress: 100,
    );
    
    final photos = await GalleryService.loadPhotos();
      print('Total photos to analyze: ${photos.length}');
    Map<String, dynamic> cache = {};
    if (!forceRefresh) {
      cache = await GalleryService.loadAnalysisCache();
    }
    // --- Sadece yeni/eklenen fotoğrafları bul ---
    List<PhotoItem> toAnalyze = [];
    for (final photo in photos) {
      final cached = cache[photo.id];
      if (cached == null || cached['hash'] != photo.hash || cached['labels'] == null || cached['size'] == null) {
          print('Analyzing: photo.id=${photo.id}, path=${photo.path}');
        toAnalyze.add(photo);
      }
    }
      print('Photos to be analyzed (new or changed): ${toAnalyze.length}');
    // Analiz edilen fotoğraf sayısını sınırla (ilk 500)
    if (toAnalyze.length > 500) {
      toAnalyze = toAnalyze.sublist(0, 500);
    }
    // --- compute ile analiz ---
    final Map<String, dynamic> params = {
      'photos': toAnalyze,
      'cache': cache,
        'confidenceThreshold': 0.8, // Daha yüksek güven skoru
        'progressCallback': (double progress, int remaining) {
          setState(() {
            _analysisProgress = progress;
            _analysisLabel = 'Analyzing... Remaining: $remaining';
          });
        },
    };
      final result = await _analyzePhotosIsolate(params);
    // --- Sonuçları eski cache ile birleştir ---
    Map<String, List<String>> labelsMap = {};
    // Önce eski cache'den etiketleri al
    for (final photo in photos) {
      final cached = cache[photo.id];
      if (cached != null && cached['labels'] != null) {
        labelsMap[photo.id] = List<String>.from(cached['labels']);
      }
    }
    // compute sonucunu ekle ve cache'i güncelle
    for (final entry in result.entries) {
      labelsMap[entry.key] = List<String>.from(entry.value['labels'] ?? []);
      await GalleryService.updateAnalysisCache(entry.key, entry.value);
    }
      // En çok geçen 3 etiketi bul
    if (labelsMap.isNotEmpty) {
        final Map<String, int> labelCounts = {};
        for (final photoLabels in labelsMap.values) {
          for (final label in photoLabels) {
            labelCounts[label] = (labelCounts[label] ?? 0) + 1;
        }
        }
        final sortedLabels = labelCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        _topLabels = sortedLabels.take(3).map((e) => e.key).toList();
        print('Top 3 labels: $_topLabels');
    }
    // Android bildirimini kapat
    await GalleryService.cancelAndroidNotification();
    // Android performans optimizasyonu
    await GalleryService.optimizeAndroidPerformance();
    setState(() {
      _photoLabels = labelsMap;
      _analysisProgress = 1.0;
        _analysisLabel = 'Gallery analysis completed';
      _labelingInProgress = false;
    });
    } catch (e, s) {
      print('ANALİZDE FATAL HATA: $e\n$s');
    }
  }

  void _openAlbum(_AlbumWithCount album) async {
    if (_isVideoMode && _albums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noVideosFound)),
      );
      return;
    }
    // Albüme tıklanınca önce duplicate kontrolü yap
    await _checkAndShowDuplicates(context, album.album);
    // DuplicatePreviewScreen açıldıysa, oradan dönülünce devam et
    // Duplicate yoksa, doğrudan temizleme ekranına geç
    final photos = await album.album.getAssetListPaged(page: 0, size: album.count);
    final photoItems = <PhotoItem>[];
    for (final asset in photos) {
      final file = await asset.file;
      if (file != null) {
        photoItems.add(PhotoItem(
          id: asset.id,
          thumb: await asset.thumbnailDataWithSize(const ThumbnailSize(400, 400)) ?? Uint8List(0),
          date: asset.createDateTime,
          hash: '',
          type: _isVideoMode ? MediaType.video : MediaType.image,
          path: file.path,
        ));
      }
    }
    if (photoItems.isNotEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GalleryCleanerScreen(
            albumId: album.album.id,
            albumName: album.album.name,
            photos: photoItems,
            isVideoMode: _isVideoMode,
        ),
      ),
    );
    }
  }

  Future<void> _checkAndShowDuplicates(BuildContext context, AssetPathEntity album) async {
    final photos = await album.getAssetListPaged(page: 0, size: 1000);
    final thumbs = <String, List<AssetEntity>>{};
    for (final asset in photos) {
      final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(400, 400));
      if (thumb != null) {
        final hash = md5.convert(thumb).toString();
        thumbs.putIfAbsent(hash, () => []).add(asset);
      }
    }
    final duplicates = thumbs.values.where((list) => list.length > 1).toList();
    if (duplicates.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DuplicatePreviewScreen(
            duplicateGroups: duplicates,
            onDeleted: _fetchAlbums,
          ),
        ),
      );
    }
  }

  Future<void> _openRandom15Albums(BuildContext context) async {
    final random = Random();
    final albums = List<_AlbumWithCount>.from(_sortedAlbums);
    albums.shuffle(random);
    final selected = albums.take(15).toList();
    // 15 albümden tüm fotoğrafları topla
    List<PhotoItem> allPhotos = [];
    for (final album in selected) {
      final assets = await album.album.getAssetListPaged(page: 0, size: album.count);
      for (final asset in assets) {
        final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(400, 400));
        if (thumb != null) {
          allPhotos.add(PhotoItem(id: asset.id, thumb: thumb, date: asset.createDateTime, hash: '', type: MediaType.image));
        }
      }
    }
    if (allPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No photos found in selected folders.')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GalleryCleanerScreen(
          albumId: null,
          albumName: 'Random 15 Folders',
          photos: allPhotos,
        ),
      ),
    );
    // NOT: GalleryCleanerScreen'de özel bir foto listesi desteği eklenmeli.
  }

  Future<void> _searchPhotos(String keyword) async {
    if (_labelingInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis in progress, please wait.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _searching = true; _searchResults = []; });
    final lowerKeyword = keyword.toLowerCase().trim();
    final photos = await GalleryService.loadPhotos();
    List<PhotoItem> matches = [];
    List<String> matchedLabels = [];
    for (final photo in photos) {
      final photoLabels = _photoLabels[photo.id] ?? [];
      if (photoLabels.any((l) => l == lowerKeyword)) {
        matches.add(photo);
        matchedLabels.addAll(photoLabels.where((l) => l == lowerKeyword));
      }
    }
    setState(() {
      _searchResults = matches;
      _searching = false;
      _lastSearch = lowerKeyword;
      _lastMatchedLabels = matchedLabels.toSet().toList();
    });
    if (matches.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GalleryCleanerScreen(
            albumId: null,
            albumName: 'Search Results',
            photos: matches,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching photo found.'), backgroundColor: const Color(0xFFB24592)),
      );
    }
  }

  @override
  void dispose() {
    // _rewardedAd?.dispose(); // Reklam dispose kaldırıldı
    super.dispose();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('Permission is required to access your photos. Please enable it in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Albüm adı çeviri haritası
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

  // ML Kit etiket çeviri haritası (örnek, daha fazlası eklenebilir)
  String _localizedLabel(String label, AppLocalizations appLoc) {
    final Map<String, Map<String, String>> map = {
      'paper': {
        'tr': 'kağıt', 'es': 'papel', 'ko': '종이', 'en': 'paper'
      },
      'sky': {
        'tr': 'gökyüzü', 'es': 'cielo', 'ko': '하늘', 'en': 'sky'
      },
      // ... diğer etiketler ...
    };
    final lang = Localizations.localeOf(context).languageCode;
    return map[label]?[lang] ?? label;
  }

  // --- ETİKET WIDGET ---
  Widget _buildTag(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1B2A4D) : Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                        Color(0xFF233A5E),
                      ],
                    ),
                  ),
                )
              : const _WavyBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analiz tamamlandı mesajı
                if (_analysisCompleted && !_isVideoMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF7CF29C)
                              : const Color(0xFF0A183D),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appLoc.galleryAnalysisCompleted,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF7CF29C)
                                  : const Color(0xFF0A183D),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Analiz başlatma butonu (sadece fotoğraf modunda ve analiz tamamlanmadıysa)
                if (!_isVideoMode && (!_analysisStarted || !_analysisCompleted))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 0),
                    child: Center(
                      child: GestureDetector(
                        onTap: _startAnalysis,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: Theme.of(context).brightness == Brightness.dark
                                ? const LinearGradient(colors: [Color(0xFF1B2A4D), Color(0xFF0A183D)])
                                : null,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? null
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.08),
                              width: 2.2,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.analyzeGallery,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1B2A4D),
                              fontSize: 17,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Photos/Videos toggle
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 0, right: 0, bottom: 0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleButton(true, appLoc.photos),
                          _buildToggleButton(false, appLoc.videos),
                        ],
                      ),
                    ),
                  ),
                ),
                // Arama çubuğu (sadece analiz tamamlandıysa)
                if (_analysisCompleted && !_isVideoMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              decoration: InputDecoration(
                                hintText: appLoc.searchPhotos,
                                hintStyle: const TextStyle(color: Colors.white70, fontSize: 18),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              ),
                              onSubmitted: (v) => _searchPhotos(v),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white70),
                            onPressed: () => _searchPhotos(_searchController.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Etiket chips (sadece analiz tamamlandıysa)
                if (_analysisCompleted && _topLabels.isNotEmpty && !_isVideoMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _topLabels.map((label) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final appLoc = AppLocalizations.of(context)!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => _searchPhotos(label),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1B2A4D) : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _localizedLabel(label, appLoc),
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1B2A4D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Sıralama kutusu ve yenile butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: Theme.of(context).brightness == Brightness.dark
                              ? const LinearGradient(
                                  colors: [Color(0xFF1B2A4D), Color(0xFF233A5E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? null
                              : Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.18)
                                  : Colors.grey.withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.10)
                                : Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AlbumSortType>(
                            value: _sortType,
                            dropdownColor: _isDarkTheme ? Color(0xFF1B2A4D) : Colors.white.withOpacity(0.85),
                            icon: Icon(Icons.arrow_drop_down, color: _isDarkTheme ? Colors.white : Colors.white70),
                            style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black87, fontSize: 17, fontWeight: FontWeight.bold),
                            onChanged: (AlbumSortType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _sortType = newValue;
                                });
                                _fetchAlbums();
                              }
                            },
                            items: <DropdownMenuItem<AlbumSortType>>[
                              DropdownMenuItem(
                                value: AlbumSortType.size,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(appLoc.size),
                                ),
                              ),
                              DropdownMenuItem(
                                value: AlbumSortType.date,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(appLoc.date),
                                ),
                              ),
                              DropdownMenuItem(
                                value: AlbumSortType.name,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(appLoc.name),
                                ),
                              ),
                              DropdownMenuItem(
                                value: AlbumSortType.filesize,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(appLoc.largestSize),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                        onPressed: _fetchAlbums,
                        tooltip: appLoc.refresh,
                      ),
                    ],
                  ),
                ),
                // Albüm listesi (klasör kartları)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      physics: const FastScrollPhysics(),
                      itemCount: _albums.length,
                      itemBuilder: (context, idx) {
                        final album = _albums[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: FutureBuilder<Uint8List?>(
                               future: album.album.getAssetListPaged(page: 0, size: 1).then((assets) => assets.isNotEmpty ? assets.first.thumbnailDataWithSize(const ThumbnailSize(80, 80)) : null),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(width: 44, height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                                }
                                if (snap.hasData && snap.data != null && snap.data!.isNotEmpty) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      snap.data!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                                return const Icon(Icons.folder, color: Colors.white, size: 36);
                              },
                            ),
                            title: Text(
                              album.album.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              '${album.count} ${appLoc.photos}',
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            onTap: () => _openAlbum(album),
                          ),
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
    );
  }

  // Photos/Videos toggle butonları
  Widget _buildToggleButton(bool isPhoto, String text) {
    final selected = _isVideoMode != isPhoto;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isVideoMode = !isPhoto;
        });
        _fetchAlbums();
        _fetchAllPhotos();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF1B2A4D) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
} // _GalleryAlbumListScreenState'in kapanışı

// --- ALT SINIFLAR VE WIDGET'LAR DOSYANIN EN ALTINA TAŞINDI ---

class _AlbumWithCount {
  final AssetPathEntity album;
  final int count;
  final DateTime? latestDate;
  _AlbumWithCount({required this.album, required this.count, this.latestDate});
}

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

class DuplicatePreviewScreen extends StatelessWidget {
  final List<List<AssetEntity>> duplicateGroups;
  final VoidCallback onDeleted;
  final bool showSkip;
  const DuplicatePreviewScreen({super.key, required this.duplicateGroups, required this.onDeleted, this.showSkip = false});

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          isDark
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A183D),
                        Color(0xFF1B2A4D),
                        Color(0xFF233A5E),
                        Color(0xFF233A5E),
                      ],
                    ),
                  ),
                )
              : const _WavyBackground(),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      appLoc.duplicatePhotos,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLoc.previewOfDuplicatePhotos,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLoc.duplicatePreviewInfo,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: duplicateGroups.length,
                      itemBuilder: (context, groupIdx) {
                        final group = duplicateGroups[groupIdx];
                        return Card(
                          color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                for (int i = 0; i < group.length; i++)
                                  FutureBuilder<Uint8List?>(
                                    future: group[i].thumbnailDataWithSize(const ThumbnailSize(80, 80)),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox(width: 84, height: 84, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                                      }
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: i == 0 ? Colors.green : Colors.red, width: 2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.memory(snapshot.data!, width: 80, height: 80, fit: BoxFit.cover),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE57373),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: Colors.black26,
                            ),
                            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
                            label: Text(appLoc.deleteAllDuplicates, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: Text(appLoc.confirmDeletion),
                                  content: Text(appLoc.confirmDeleteAllDuplicates),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(appLoc.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(appLoc.deleteAll),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldDelete == true) {
                                final idsToDelete = <String>[];
                                for (final group in duplicateGroups) {
                                  idsToDelete.addAll(group.skip(1).map((asset) => asset.id));
                                }
                                if (idsToDelete.isNotEmpty) {
                                  await PhotoManager.editor.deleteWithIds(idsToDelete);
                                }
                                onDeleted();
                                if (showSkip) {
                                  Navigator.of(context).pop(false);
                                } else {
                                  Navigator.of(context).pop();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(appLoc.allDuplicatesDeleted)),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (showSkip)
                        TextButton(
                          onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              appLoc.skipThisStep,
                              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (!showSkip)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                          },
                          child: Text(
                              appLoc.skip,
                            style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 

// Kaydırma hızını artırmak için özel scroll physics
class FastScrollPhysics extends ClampingScrollPhysics {
  const FastScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;
  @override
  double get minFlingVelocity => 100.0;
  @override
  double get maxFlingVelocity => 8000.0;
  @override
  double carriedMomentum(double existingVelocity) => existingVelocity * 0.9;
} 

// Modern arka plan, grid ve _AlbumCard ile ilgili eklemeleri kaldırıyorum.
// Eski klasik liste, arama çubuğu, toggle ve dalgalı arka planı geri getiriyorum.
// ... eski kodu uygula ...


