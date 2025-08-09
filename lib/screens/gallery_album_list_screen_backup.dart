import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_cleaner_screen.dart';
import 'dart:math';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../services/gallery_service.dart';
import '../models/photo_item.dart';
import 'package:intl/intl.dart';
import '../widgets/debounced_button.dart'; // DebouncedButton import


import 'package:flutter/foundation.dart';

import 'video_player_screen.dart';

// Albüm sıralama türleri için enum
enum AlbumSortType {
  size,
  date,
  name,
  filesize,
}

// Görünüm türleri için enum
enum ViewType {
  folder, // Klasör görünümü
  date,   // Tarih görünümü
}

class GalleryAlbumListScreen extends StatefulWidget {
  final Locale? currentLocale;
  final void Function(Locale)? onLocaleChanged;

  const GalleryAlbumListScreen({Key? key, this.currentLocale, this.onLocaleChanged}) : super(key: key);

  @override
  _GalleryAlbumListScreenState createState() => _GalleryAlbumListScreenState();
}

class _GalleryAlbumListScreenState extends State<GalleryAlbumListScreen> with WidgetsBindingObserver {
  // Albüm ve fotoğraf listeleri
  List<_AlbumWithCount> _albums = [];
  bool _loading = false;
  // Yükleme durumu kontrolü için flag'ler
  bool _isLoadingAlbums = false;
  bool _hasInitialized = false;
  bool _isPhotoDataLoaded = false;
  bool _isVideoDataLoaded = false;
  AlbumSortType _sortType = AlbumSortType.size;
  ViewType _viewType = ViewType.folder; // Varsayılan olarak klasör görünümü
  late String _selectedLanguage;
  List<PhotoItem> _allPhotos = [];
  Map<String, List<PhotoItem>> _photosByMonth = {};
  bool _loadingPhotos = true;
  
  // Güncelleme kontrolü için
  DateTime _lastUpdateTime = DateTime.now();
  bool _isRefreshing = false;
  int _forceReloadCounter = 0; // Hot reload için zorlama sayacı

  // Analiz state değişkenleri
  bool _analysisStarted = false;
  bool _analysisCompleted = false;

  // Arama ile ilgili - TAMAMEN KALDIRILDI
  // final TextEditingController _searchController = TextEditingController();
  // bool _searching = false;
  // List<PhotoItem> _searchResults = [];
  // String _lastSearch = '';
  // List<String> _lastMatchedLabels = [];
  // List<String> _topLabels = [];

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
    WidgetsBinding.instance.addObserver(this);
    _selectedLanguage = widget.currentLocale?.languageCode ?? 'tr';
    _initializeApp();
    // Hot reload için zorlama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _forceReloadCounter++;
        });
        // TEST: Popup mesaj kaldırıldı
      }
    });
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Sadece eğer hiç yükleme yapılmamışsa yükle
      if (!_hasInitialized && !_isLoadingAlbums) {
        print('DEBUG: App resumed, ilk yükleme başlatılıyor');
        _initializeApp();
      } else {
        print('DEBUG: App resumed, zaten yüklü veya yükleme devam ediyor, atlanıyor');
      }
    }
  }

  Future<void> _checkAndReloadAlbums() async {
    // Eğer zaten yükleme yapılıyorsa bekle
    if (_isLoadingAlbums) {
      print('DEBUG: Zaten yükleme yapılıyor, bekle...');
      return;
    }
    
    // Eğer veriler zaten yüklüyse tekrar yükleme
    bool isCurrentDataLoaded = _isVideoMode ? _isVideoDataLoaded : _isPhotoDataLoaded;
    if (isCurrentDataLoaded && _albums.isNotEmpty) {
      print('DEBUG: ${_isVideoMode ? "Video" : "Fotoğraf"} verileri zaten yüklü, yükleme atlanıyor');
      return;
    }
    
    print('DEBUG: _checkAndReloadAlbums başladı');
    // İzin kontrolü yap ve albümleri yükle
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      await _loadAllData();
    }
    print('DEBUG: _checkAndReloadAlbums bitti');
  }

  Future<void> _loadAllData() async {
    if (_isLoadingAlbums) {
      print('DEBUG: _loadAllData - Zaten yükleme yapılıyor, çık');
      return;
    }
    
    print('DEBUG: _loadAllData başladı');
    setState(() { 
      _loading = true; 
      _isLoadingAlbums = true; 
    });
    
    try {
      // Sadece albümleri yükle, fotoğrafları sonra yükle
      await _fetchAlbumsInternal();
      
      // Yükleme tamamlandı olarak işaretle
      if (_isVideoMode) {
        _isVideoDataLoaded = true;
      } else {
        _isPhotoDataLoaded = true;
      }
      _hasInitialized = true;
      
    } finally {
      setState(() { 
        _loading = false; 
        _isLoadingAlbums = false; 
      });
    }
    print('DEBUG: _loadAllData bitti');
  }

  // Güncelleme kontrolü fonksiyonu
  Future<bool> _shouldRefreshData() async {
    try {
      final albums = await PhotoManager.getAssetPathList(type: _isVideoMode ? RequestType.video : RequestType.image);
      if (albums.length != _albums.length) {
        return true; // Albüm sayısı değişmiş
      }
      
      // Albüm içeriklerini kontrol et
      for (final album in albums) {
        final count = await album.assetCountAsync;
        final existingAlbum = _albums.firstWhere(
          (a) => a.album.id == album.id,
          orElse: () => _AlbumWithCount(album: album, count: 0, latestDate: DateTime.now()),
        );
        
        if (count != existingAlbum.count) {
          return true; // İçerik değişmiş
        }
      }
      
      return false;
    } catch (e) {
      print('DEBUG: Güncelleme kontrolü hatası: $e');
      return true; // Hata durumunda yenile
    }
  }

  // Veri yenileme fonksiyonu


  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      // Zorla yenileme - her zaman yenile
      print('DEBUG: Zorla yenileme başlatılıyor...');
      _forceReloadCounter++; // Hot reload için zorlama
      await _loadAllData();
      
      // Aylık görünümde fotoğrafları da yenile
      if (_viewType == ViewType.date) {
        _photosByMonth.clear();
        if (mounted) {
          setState(() {});
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Galeri yenilendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Yenileme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yenileme hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
              if (mounted) {
          setState(() {
            _isRefreshing = false;
            _lastUpdateTime = DateTime.now();
            _forceReloadCounter++; // Hot reload için zorlama
          });
        }
    }
  }

  Future<void> _fetchAlbumsInternal() async {
    print('DEBUG: _fetchAlbumsInternal başladı - Video modu: $_isVideoMode');
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      _showPermissionDeniedDialog();
      return;
    }
    
    final requestType = _isVideoMode ? RequestType.video : RequestType.image;
    print('DEBUG: Albüm türü isteniyor: $requestType');
    final albums = await PhotoManager.getAssetPathList(type: requestType);
    print('DEBUG: ${albums.length} albüm bulundu');
    
    final List<_AlbumWithCount> albumList = [];
    
    // Performans optimizasyonu: Sadece sayıları al, thumbnail'leri sonra yükle
    final futures = <Future<_AlbumWithCount?>>[];
    
    for (final album in albums) {
      futures.add(() async {
        try {
        final count = await album.assetCountAsync;
          print('DEBUG: Albüm ${album.name} - ${count} ${_isVideoMode ? "video" : "fotoğraf"}');
          if (count == 0) return null; // Skip empty albums
        
          // Sadece tarih bilgisini al, thumbnail'i sonra yükle
        final latestDate = await _getLatestAssetDate(album);
          return _AlbumWithCount(album: album, count: count, latestDate: latestDate);
        } catch (e) {
          print('DEBUG: Albüm ${album.name} işleme hatası: $e');
          return null;
        }
      }());
    }
    
    // Tüm albümleri paralel olarak işle
    final results = await Future.wait(futures);
    albumList.addAll(results.where((album) => album != null).cast<_AlbumWithCount>());
    
    setState(() {
      _albums = albumList;
      _lastUpdateTime = DateTime.now();
    });
    print('DEBUG: _fetchAlbumsInternal bitti - ${albumList.length} albüm yüklendi');
  }

  Future<void> _fetchAllPhotosInternal() async {
    print('DEBUG: _fetchAllPhotosInternal başladı - Video modu: $_isVideoMode');
    setState(() { _loadingPhotos = true; });
    
    // Performans optimizasyonu: Sadece albüm listesi için gerekli değil
    // Bu fonksiyonu kaldır veya sadece gerektiğinde çağır
    _allPhotos = [];
      _photosByMonth = {};
    
    setState(() { _loadingPhotos = false; });
    print('DEBUG: _fetchAllPhotosInternal bitti - Performans için kaldırıldı');
  }



  Future<void> _labelAllPhotos({bool forceRefresh = false}) async {
    // Analiz kısmı geçici olarak devre dışı bırakıldı - performans sorunu nedeniyle
    print('ANALİZ DEVRE DIŞI - Performans optimizasyonu için kaldırıldı');
    
    // Basit bir progress bar göster
    setState(() { 
      _labelingInProgress = true; 
      _analysisProgress = 0.0; 
      _analysisLabel = 'Galeri yükleniyor...'; 
    });
    
    // Simüle edilmiş progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _analysisProgress = i / 100;
        _analysisLabel = 'Galeri yükleniyor... ${i}%';
      });
    }
    
    setState(() {
      _labelingInProgress = false;
      _analysisProgress = 1.0;
      _analysisLabel = 'Galeri hazır';
      _analysisCompleted = true;
    });
    
    /* 
    // ESKİ ANALİZ KODU - YORUM SATIRINA ALINDI
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
    */
  }

    void _openAlbum(_AlbumWithCount album) async {
    print('DEBUG: _openAlbum çağrıldı - Video modu: $_isVideoMode, Albüm: ${album.album.name}');
    
    // Video modunda albüm kontrolü kaldırıldı - her durumda açmaya çalış
    await _openAlbumDirectly(album.album);
  }

  Future<void> _openAlbumDirectly(AssetPathEntity album) async {
    print('DEBUG: _openAlbumDirectly başladı - Video modu: $_isVideoMode, Albüm: ${album.name}');
    
    try {
      // Tüm fotoğrafları al (sınırsız)
      final totalCount = await album.assetCountAsync;
      print('DEBUG: Toplam ${totalCount} asset bulundu');
      
      // Ana thread'de işle (isolate sorunu nedeniyle)
      final photoItems = await _loadAssetsDirectly(album, totalCount);
      
      print('DEBUG: ${photoItems.length} PhotoItem oluşturuldu');
    
      if (photoItems.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GalleryCleanerScreen(
              albumId: album.id,
              albumName: album.name,
              photos: photoItems,
              isVideoMode: _isVideoMode,
              onPhotosDeleted: (deletedCount) {
                // Albüm listesini güncelle
                _refreshAlbumList();
              },
            ),
          ),
        );
      } else {
        print('DEBUG: PhotoItem listesi boş');
        final appLoc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLoc?.noAlbumsFound ?? 'Bu klasörde ${_isVideoMode ? "video" : "fotoğraf"} bulunamadı')),
        );
      }
    } catch (e) {
      print('DEBUG: _openAlbumDirectly hatası: $e');
      final appLoc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLoc?.noAlbumsFound ?? 'Klasör açılırken hata oluştu: $e')),
      );
    }
  }

  // Ultra optimize edilmiş asset yükleme
  Future<List<PhotoItem>> _loadAssetsDirectly(AssetPathEntity album, int totalCount) async {
    final photoItems = <PhotoItem>[];
    
    // Daha hızlı yükleme için küçük sayfa boyutu
    const int pageSize = 10; // 20'den 10'a düşürüldü - daha hızlı açılım
    int currentPage = 0;
    
    // Daha hızlı yükleme için sınırlı fotoğraf sayısı
    const int maxPhotos = 200; // 500'den 200'e düşürüldü - daha hızlı açılım
    
    while (photoItems.length < totalCount && photoItems.length < maxPhotos) {
      final assets = await album.getAssetListPaged(page: currentPage, size: pageSize);
      if (assets.isEmpty) break;
      
      // Batch işleme - daha küçük gruplar halinde (daha hızlı)
      final batchSize = 10; // 25'ten 10'a düşürüldü - daha hızlı işlem
      final batches = <List<AssetEntity>>[];
      
      for (int i = 0; i < assets.length; i += batchSize) {
        final end = (i + batchSize < assets.length) ? i + batchSize : assets.length;
        batches.add(assets.sublist(i, end));
      }
      
      // Her batch'i paralel olarak işle
      for (final batch in batches) {
        final futures = <Future<PhotoItem?>>[];
        
        for (final asset in batch) {
          futures.add(_processAssetOptimized(asset));
        }
        
        // Batch'i paralel olarak işle
        final results = await Future.wait(futures);
        
        // Null olmayan sonuçları ekle
        for (final result in results) {
          if (result != null) {
            photoItems.add(result);
          }
        }
        
        // Her batch sonrası çok kısa bekleme (daha hızlı yükleme için)
        await Future.delayed(const Duration(milliseconds: 2));
      }
      
      currentPage++;
      
      // Güvenlik kontrolü - daha yüksek limit
      if (currentPage > 100) break; // 50'den 100'e çıkarıldı
    }
    
    print('DEBUG: Toplam ${photoItems.length} fotoğraf yüklendi');
    return photoItems;
  }

  // Ultra optimize edilmiş asset işleme
  Future<PhotoItem?> _processAssetOptimized(AssetEntity asset) async {
    try {
      // Daha yüksek kalite thumbnail - kalite için
      final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
      if (thumb != null) {
        // Path'i al
        String path = '';
        try {
          final file = await asset.file;
          if (file != null) {
            path = file.path;
          }
        } catch (e) {
          print('Path alma hatası: $e');
        }
        
        return PhotoItem(
          id: asset.id,
          thumb: thumb,
          date: asset.createDateTime,
          hash: '',
          type: _isVideoMode ? MediaType.video : MediaType.image,
          path: path,
        );
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
    return null;
  }

  // Eski fonksiyon (geriye uyumluluk için)
  Future<PhotoItem?> _processAsset(AssetEntity asset) async {
    return _processAssetOptimized(asset);
  }

  // Albüm listesini yenile
  Future<void> _refreshAlbumList() async {
    setState(() {
      _isLoadingAlbums = true;
    });
    
    try {
      await _fetchAlbumsInternal();
    } catch (e) {
      print('Albüm listesi yenileme hatası: $e');
    } finally {
      setState(() {
        _isLoadingAlbums = false;
      });
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

  // Arama fonksiyonu - TAMAMEN KALDIRILDI
  // Future<void> _searchPhotos(String keyword) async { ... }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    
    if (_loading) {
      return Scaffold(
        body: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'Albümler yükleniyor...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lütfen bekleyin',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
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
                // Üst bar - Geri butonu ve ayarlar
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Geri butonu
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      // Ayarlar butonu
                      GestureDetector(
                        onTap: () {
                          _showSettingsDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Analiz tamamlandı mesajı - DEVRE DIŞI
                // if (_analysisCompleted && !_isVideoMode)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 0),
                //     child: Row(
                //       children: [
                //         Icon(
                //           Icons.check_circle,
                //           color: Theme.of(context).brightness == Brightness.dark
                //               ? const Color(0xFF7CF29C)
                //               : const Color(0xFF0A183D),
                //           size: 22,
                //         ),
                //         const SizedBox(width: 8),
                //         Expanded(
                //           child: Text(
                //             appLoc.galleryAnalysisCompleted,
                //             style: TextStyle(
                //               color: Theme.of(context).brightness == Brightness.dark
                //                   ? const Color(0xFF7CF29C)
                //                   : const Color(0xFF0A183D),
                //               fontWeight: FontWeight.bold,
                //               fontSize: 17,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // Analiz başlatma butonu - DEVRE DIŞI
                // if (!_isVideoMode && (!_analysisStarted || !_analysisCompleted))
                //   Padding(
                //     padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 0),
                //     child: Center(
                //       child: GestureDetector(
                //         onTap: _startAnalysis,
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                //           decoration: BoxDecoration(
                //             gradient: Theme.of(context).brightness == Brightness.dark
                //                 ? const LinearGradient(colors: [Color(0xFF1B2A4D), Color(0xFF0A183D)])
                //                 : null,
                //             color: Theme.of(context).brightness == Brightness.dark
                //                 ? null
                //                 : Colors.white,
                //             borderRadius: BorderRadius.circular(22),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black.withOpacity(0.10),
                //                 blurRadius: 12,
                //                 offset: const Offset(0, 4),
                //               ),
                //             ],
                //             border: Border.all(
                //               color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.08),
                //               width: 2.2,
                //             ),
                //           ),
                //           child: Text(
                //             AppLocalizations.of(context)!.analyzeGallery,
                //             style: TextStyle(
                //               fontWeight: FontWeight.bold,
                //               color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1B2A4D),
                //               fontSize: 17,
                //               letterSpacing: 0.2,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
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
                // Arama çubuğu - TAMAMEN KALDIRILDI
                // Etiket chips - TAMAMEN KALDIRILDI
                // Sıralama kutusu ve yenile butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      // DropdownButton yerine PopupMenuButton ile modern ve özel menü:
                      Flexible(
                        child: PopupMenuButton<AlbumSortType>(
                          onSelected: (AlbumSortType newValue) {
                            setState(() {
                              _sortType = newValue;
                            });
                          },
                          color: const Color(0xFF1B2A4D), // Koyu arka plan
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: AlbumSortType.size,
                              child: Text(
                                appLoc.size, 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: _sortType == AlbumSortType.size ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: AlbumSortType.date,
                              child: Text(
                                appLoc.date, 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: _sortType == AlbumSortType.date ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: AlbumSortType.name,
                              child: Text(
                                appLoc.name, 
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: _sortType == AlbumSortType.name ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    _sortType == AlbumSortType.size
                                        ? appLoc.size
                                        : _sortType == AlbumSortType.date
                                            ? appLoc.date
                                            : appLoc.name,
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.w700, 
                                      fontSize: 15,
                                      letterSpacing: 0.8,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Görünüm seçenekleri
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Klasör görünümü butonu
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _viewType = ViewType.folder;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _viewType == ViewType.folder 
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: _viewType == ViewType.folder ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appLoc.folder,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: _viewType == ViewType.folder 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Tarih görünümü butonu
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _viewType = ViewType.date;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _viewType == ViewType.date 
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: _viewType == ViewType.date ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appLoc.date,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: _viewType == ViewType.date 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                        onPressed: () {
                          _forceReloadCounter++;
                          _refreshData();
                        },
                        tooltip: appLoc.refresh,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Albüm listesi (klasör kartları veya aylık gruplama)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _viewType == ViewType.folder 
                        ? _buildFolderView()
                        : _buildMonthlyView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Klasör görünümü
  Widget _buildFolderView() {
    final appLoc = AppLocalizations.of(context)!;
    return ListView.builder(
      physics: const FastScrollPhysics(),
      itemCount: _sortedAlbums.length,
      itemBuilder: (context, idx) {
        final album = _sortedAlbums[idx];
        return Dismissible(
          key: Key(album.album.id),
          direction: DismissDirection.endToStart, // Sağdan sola kaydırma
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          confirmDismiss: (direction) async {
            // Silme onayı
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(appLoc.confirmDeletion),
                content: Text('${album.album.name} klasörünü silmek istediğinize emin misiniz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(appLoc.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      appLoc.deleteAll,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            // Klasörü gerçekten sil
            try {
              await PhotoManager.editor.deleteWithIds([album.album.id]);
              print('DEBUG: Klasör silindi: ${album.album.name}');
            } catch (e) {
              print('DEBUG: Klasör silme hatası: $e');
            }
            
            // Listeyi yeniden yükle
            await _loadAllData();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${album.album.name} silindi'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Geri Al',
                  textColor: Colors.white,
                  onPressed: () {
                    // Geri alma işlemi (şimdilik sadece mesaj)
                    final appLoc = AppLocalizations.of(context)!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLoc.undoFeatureComingSoon),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: DebouncedButton(
            onPressed: () async {
              await _openAlbumDirectly(album.album);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: _buildAlbumThumbnail(album.album),
                title: Text(
                  album.album.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  '${album.count} ${appLoc.photos}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                onTap: null, // DebouncedButton üstte olduğu için null
              ),
            ),
          ),
        );
      },
    );
  }

  // Aylık görünüm - Klasör formatında
  Widget _buildMonthlyView() {
    if (_photosByMonth.isEmpty) {
      return FutureBuilder<List<PhotoItem>>(
        future: GalleryService.loadPhotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Fotoğraf veya videoları aylara göre grupla
            final groupedPhotos = _isVideoMode
                ? GalleryService.groupVideosByMonth(snapshot.data!)
                : GalleryService.groupPhotosByMonth(snapshot.data!);
            _photosByMonth = groupedPhotos;
            
            return ListView.builder(
              physics: const FastScrollPhysics(),
              itemCount: groupedPhotos.length,
              itemBuilder: (context, idx) {
                final monthKey = groupedPhotos.keys.elementAt(idx);
                final photos = groupedPhotos[monthKey]!;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: _buildMonthThumbnail(photos),
                    title: Text(
                      monthKey,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.photoCount(photos.length),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 16,
                    ),
                    onTap: () {
                      // Ay klasörüne tıklandığında fotoğrafları göster
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GalleryCleanerScreen(
                            albumId: monthKey,
                            photos: photos,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          
          return const Center(
            child: Text(
              'Fotoğraf bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      );
    }
    
    // Zaten yüklenmiş verileri göster
    return ListView.builder(
      physics: const FastScrollPhysics(),
      itemCount: _photosByMonth.length,
      itemBuilder: (context, idx) {
        final monthKey = _photosByMonth.keys.elementAt(idx);
        final photos = _photosByMonth[monthKey]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: _buildMonthThumbnail(photos),
            title: Text(
              monthKey,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.photoCount(photos.length),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
            onTap: () {
              // Ay klasörüne tıklandığında fotoğrafları göster
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryCleanerScreen(
                    albumId: monthKey,
                    photos: photos,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Ay klasörü için thumbnail oluştur
  Widget _buildMonthThumbnail(List<PhotoItem> photos) {
    if (photos.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
      );
    }
    
    // İlk 4 fotoğrafı göster
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // İlk fotoğraf (arka plan)
            if (photos.isNotEmpty)
              Positioned.fill(
                child: Image.memory(
                  photos[0].thumb,
                  fit: BoxFit.cover,
                ),
              ),
            // İkinci fotoğraf (sağ üst köşe)
            if (photos.length > 1)
              Positioned(
                top: 2,
                right: 2,
                width: 28,
                height: 28,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    photos[1].thumb,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Üçüncü fotoğraf (sol alt köşe)
            if (photos.length > 2)
              Positioned(
                bottom: 2,
                left: 2,
                width: 28,
                height: 28,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    photos[2].thumb,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Dördüncü fotoğraf (sağ alt köşe)
            if (photos.length > 3)
              Positioned(
                bottom: 2,
                right: 2,
                width: 28,
                height: 28,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    photos[3].thumb,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Optimized thumbnail builder with lazy loading
  Widget _buildAlbumThumbnail(AssetPathEntity album) {
    return FutureBuilder<Uint8List?>(
      future: _getAlbumThumbnail(album),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 24),
          );
        }
        if (snap.hasData && snap.data != null && snap.data!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snap.data!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: Colors.white, size: 24),
        );
      },
    );
  }

  // Thumbnail cache with lazy loading
  final Map<String, Future<Uint8List?>> _thumbnailCache = {};
  final Set<String> _loadingThumbnails = {};

  Future<Uint8List?> _getAlbumThumbnail(AssetPathEntity album) {
    // Eğer zaten cache'de varsa döndür
    if (_thumbnailCache.containsKey(album.id)) {
      return _thumbnailCache[album.id]!;
    }
    
    // Eğer zaten yükleniyorsa bekle
    if (_loadingThumbnails.contains(album.id)) {
      return Future.value(null);
    }
    
    // Yeni thumbnail yükle
    _loadingThumbnails.add(album.id);
    
    final future = album.getAssetListPaged(page: 0, size: 1)
        .then((assets) => assets.isNotEmpty 
            ? assets.first.thumbnailDataWithSize(const ThumbnailSize(200, 200)) 
            : null)
        .whenComplete(() => _loadingThumbnails.remove(album.id));
    
    _thumbnailCache[album.id] = future;
    return future;
  }

  // Photos/Videos toggle butonları
  Widget _buildToggleButton(bool isPhoto, String text) {
    final selected = _isVideoMode != isPhoto;
    return GestureDetector(
      onTap: () async {
        final oldMode = _isVideoMode;
        print('DEBUG: Toggle buton - Mod değişti: ${oldMode ? "Video" : "Fotoğraf"} -> ${!isPhoto ? "Video" : "Fotoğraf"}');
        
        // Mod değişkenini güncelle
        setState(() {
          _isVideoMode = !isPhoto;
        });
        
        // Veri türü değiştiği için her zaman yeni yükleme yap
        if (!_isLoadingAlbums) {
          print('DEBUG: Toggle buton - Veri türü değişti, yeni yükleme başlatılıyor');
          await _loadAllData(); // Bu fonksiyon zaten setState yapıyor
        } else {
          print('DEBUG: Toggle buton - Yükleme devam ediyor, bekle...');
        }
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



  Future<void> _initializeApp() async {
    // Eğer zaten başlatılmışsa tekrar başlatma
    if (_hasInitialized) {
      print('DEBUG: _initializeApp - Zaten başlatılmış, atlanıyor');
      return;
    }
    
    print('DEBUG: _initializeApp başladı');
    // Android özelliklerini başlat
    await GalleryService.initializeAndroidFeatures();
    // İzin kontrolü yap ve albümleri yükle (sadece bir kez)
    bool isCurrentDataLoaded = _isVideoMode ? _isVideoDataLoaded : _isPhotoDataLoaded;
    if (!_isLoadingAlbums && !isCurrentDataLoaded) {
      print('DEBUG: _initializeApp - İlk yükleme başlatılıyor');
      await _checkAndReloadAlbums();
    } else {
      print('DEBUG: _initializeApp - Veriler zaten yüklü veya yükleme devam ediyor');
    }
    // Analiz işlemini arka planda başlat
    Future.microtask(() => _labelAllPhotos());
    print('DEBUG: _initializeApp bitti');
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
        // Filesize sorting removed for performance
        list.sort((a, b) => b.count.compareTo(a.count));
        break;
    }
    return list;
  }

  // Eski fonksiyonları yeni fonksiyonlara yönlendir
  Future<void> _fetchAlbums() async {
    await _loadAllData();
  }

  Future<void> _fetchAllPhotos() async {
    await _loadAllData();
  }

  bool _isAlbumOpening = false;

  void _onAlbumTap(_AlbumWithCount album) async {
    if (_isAlbumOpening) return;
    _isAlbumOpening = true;
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryCleanerScreen(
            albumId: album.album.id,
            albumName: album.album.name,
          ),
        ),
      );
    } finally {
      _isAlbumOpening = false;
    }
  }
  }

  // Settings Dialog
  void _showSettingsDialog(BuildContext context) async {
    final appLoc = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        appLoc.settings,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings options
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildModernSettingsOption(context, 'language', '🌐', appLoc.language, ''),
                      const SizedBox(height: 8),
                      _buildModernSettingsOption(context, 'theme', '🎨', appLoc.theme, ''),
                      const SizedBox(height: 8),
                      _buildModernSettingsOption(context, 'about', 'ℹ️', appLoc.aboutTitle, ''),
                    ],
                  ),
                ),
                // Cancel button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      appLoc.cancel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (selected != null) {
      switch (selected) {
        case 'language':
          _showLanguageDialog(context);
          break;
        case 'theme':
          // Theme değişikliği için callback kullan
          // Burada tema değişikliği yapılabilir
          break;
        case 'about':
          _showAboutDialog(context);
          break;
      }
    }
  }

  Widget _buildModernSettingsOption(BuildContext context, String code, String icon, String label, String subtitle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.5) : Colors.black87.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLoc.language,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Language options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildModernLangOption(context, 'tr', 'Türkçe'),
                    const SizedBox(height: 8),
                    _buildModernLangOption(context, 'en', 'English'),
                    const SizedBox(height: 8),
                    _buildModernLangOption(context, 'es', 'Español'),
                    const SizedBox(height: 8),
                    _buildModernLangOption(context, 'ko', '한국어'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLangOption(BuildContext context, String code, String label) {
    final isSelected = false; // Basit çözüm - dil seçimi devre dışı
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Dil değişikliği devre dışı
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (Theme.of(context).brightness == Brightness.dark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))
              : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final appLoc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLoc.aboutTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      appLoc.aboutDescription,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.8) : Colors.black87.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appLoc.aboutTakeTour,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : Colors.black87.withOpacity(0.6),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              // Tour button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // OnboardingScreen removed - tour functionality disabled
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    appLoc.aboutTakeTourButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Close button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    appLoc.close,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
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