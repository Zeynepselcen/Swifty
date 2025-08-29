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
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../theme/app_colors.dart'; // AppColors import
import '../widgets/loading_widget.dart'; // LoadingWidget import


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
  
  // Fotoğraf yükleme progress state değişkenleri
  double _photoLoadingProgress = 0.0;
  String _photoLoadingLabel = '';
  bool _isPhotoLoading = false;
  
  // Klasör yükleme durumu
  bool _isFolderLoading = false;
  String _folderLoadingMessage = '';

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
    _selectedLanguage = 'tr'; // Varsayılan dil
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localizations'a burada eriş
    _selectedLanguage = Localizations.localeOf(context).languageCode;
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
            backgroundColor: Colors.blue, // Changed from green to blue
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
      // Recent klasörünü filtrele
      if (album.name.toLowerCase() == 'recent' || 
          album.name.toLowerCase() == 'son' ||
          album.name.toLowerCase() == 'reciente') {
        print('DEBUG: Recent klasörü filtrelendi: ${album.name}');
        continue;
      }
      
      futures.add(() async {
        try {
        final count = await album.assetCountAsync;
          print('DEBUG: Albüm ${album.name} - ${count} ${_isVideoMode ? "video" : "fotoğraf"}');
          if (count == 0) return null; // Skip empty albums
        
          // Performans için tarih hesaplamasını kaldır
          return _AlbumWithCount(album: album, count: count, latestDate: null);
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
    // Eğer zaten bir klasör açılıyorsa, yeni tıklamayı engelle
    if (_isOpeningAlbum) {
      print('DEBUG: Zaten bir klasör açılıyor, yeni tıklama engellendi');
      return;
    }
    
    _isOpeningAlbum = true;
    print('DEBUG: _openAlbumDirectly başladı - Video modu: $_isVideoMode, Albüm: ${album.name}');
    
    final appLoc = AppLocalizations.of(context)!;
    
    // Loading ekranını göster
    setState(() {
      _isFolderLoading = true;
      _folderLoadingMessage = appLoc.loadingFolder;
    });
    
    // Loading state başlat
    setState(() {
      _loadingPhotos = true;
      _isPhotoLoading = true;
      _photoLoadingProgress = 0.0;
      _photoLoadingLabel = _isVideoMode ? 'Videolar yükleniyor...' : 'Fotoğraflar yükleniyor...';
    });
    
    try {
      // Tüm fotoğrafları al (sınırsız)
      final totalCount = await album.assetCountAsync;
      print('DEBUG: Toplam ${totalCount} asset bulundu');
      
      // Progress callback ile yükleme
      final photoItems = await _loadAssetsDirectlyWithProgress(album, totalCount, (progress, current, total) {
        setState(() {
          _photoLoadingProgress = progress;
          _photoLoadingLabel = 'Fotoğraflar yükleniyor... $current/$total';
        });
      });
      
      print('DEBUG: ${photoItems.length} PhotoItem oluşturuldu');
    
      if (photoItems.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GalleryCleanerScreen(
              isVideoMode: _isVideoMode,
              albumName: album.name,
              albumId: album.id,
              photos: photoItems,
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
    } finally {
      // Flag'i sıfırla
      _isOpeningAlbum = false;
      
      // Loading ekranını gizle
      setState(() {
        _isFolderLoading = false;
        _folderLoadingMessage = '';
      });
      
      // Loading state bitir
      setState(() {
        _loadingPhotos = false;
        _isPhotoLoading = false;
        _photoLoadingProgress = 1.0;
        _photoLoadingLabel = 'Fotoğraflar hazır';
      });
    }
  }

  // Progress callback ile asset yükleme - ULTRA HIZLI
  Future<List<PhotoItem>> _loadAssetsDirectlyWithProgress(
    AssetPathEntity album, 
    int totalCount, 
    Function(double progress, int current, int total) onProgress
  ) async {
    final photoItems = <PhotoItem>[];
    
    // ULTRA HIZLI yükleme için büyük sayfa boyutu
    const int pageSize = 200; // 100'den 200'e çıkarıldı - ultra hızlı
    int currentPage = 0;
    
    // Dinamik fotoğraf sayısı - albüm büyüklüğüne göre ayarla
    final maxPhotos = totalCount > 1000 ? 800 : (totalCount > 500 ? 500 : 200);
    int processedCount = 0;
    
    while (photoItems.length < totalCount && photoItems.length < maxPhotos) {
      final assets = await album.getAssetListPaged(page: currentPage, size: pageSize);
      if (assets.isEmpty) break;
      
      // ULTRA BÜYÜK batch işleme - daha az batch, ultra hızlı
      final batchSize = 100; // 50'den 100'e çıkarıldı - ultra hızlı
      final batches = <List<AssetEntity>>[];
      
      for (int i = 0; i < assets.length; i += batchSize) {
        final end = (i + batchSize < assets.length) ? i + batchSize : assets.length;
        batches.add(assets.sublist(i, end));
      }
      
      // Her batch'i paralel olarak işle
      for (final batch in batches) {
        final futures = <Future<PhotoItem?>>[];
        
        for (final asset in batch) {
          futures.add(_processAssetUltraFast(asset)); // Yeni ultra hızlı fonksiyon
        }
        
        // Batch'i paralel olarak işle
        final results = await Future.wait(futures);
        
        // Null olmayan sonuçları ekle
        for (final result in results) {
          if (result != null) {
            photoItems.add(result);
            processedCount++;
            
            // Progress güncelle - ultra akıllı güncelleme sistemi
            // 5000 fotoğraf varsa her 100'de bir güncelle
            // 1000 fotoğraf varsa her 20'de bir güncelle
            // 500 fotoğraf varsa her 10'da bir güncelle
            // 200 fotoğraf varsa her 5'te bir güncelle
            final updateInterval = (maxPhotos / 50).clamp(1, 100).toInt();
            if (processedCount % updateInterval == 0 || processedCount == maxPhotos) {
              final progress = (processedCount / maxPhotos).clamp(0.0, 1.0);
              onProgress(progress, processedCount, maxPhotos);
            }
          }
        }
        
        // Bekleme süresini kaldır - daha hızlı
        // await Future.delayed(const Duration(milliseconds: 2));
      }
      
      currentPage++;
      
      // Güvenlik kontrolü - daha düşük limit
      if (currentPage > 20) break; // 100'den 20'ye düşürüldü
    }
    
    print('DEBUG: Toplam ${photoItems.length} fotoğraf yüklendi');
    return photoItems;
  }

  // Ultra optimize edilmiş asset yükleme (geriye uyumluluk için)
  Future<List<PhotoItem>> _loadAssetsDirectly(AssetPathEntity album, int totalCount) async {
    return _loadAssetsDirectlyWithProgress(album, totalCount, (progress, current, total) {
      // Progress callback boş - geriye uyumluluk için
    });
  }

  // Ultra hızlı asset işleme - kalite korunarak
  Future<PhotoItem?> _processAssetUltraFast(AssetEntity asset) async {
    try {
      // Yüksek kalite thumbnail alma
      final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(800, 800)); // Kalite artırıldı (400->800)
      if (thumb != null) {
        // Path'i al - daha hızlı
        String path = '';
        try {
          final file = await asset.file;
          if (file != null) {
            path = file.path;
          }
    } catch (e) {
          // Path hatası durumunda sessizce devam et
        }
        
        return PhotoItem(
          id: asset.id,
          thumb: thumb,
          date: asset.createDateTime,
          hash: '',
          type: _isVideoMode ? MediaType.video : MediaType.image,
          path: path,
          name: asset.title ?? 'Unknown',
        );
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
    return null;
  }

  // Ultra optimize edilmiş asset işleme (geriye uyumluluk için)
  Future<PhotoItem?> _processAssetOptimized(AssetEntity asset) async {
    return _processAssetUltraFast(asset);
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
        final thumb = await asset.thumbnailDataWithSize(const ThumbnailSize(800, 800)); // Kalite artırıldı (400->800)
        if (thumb != null) {
          allPhotos.add(PhotoItem(
            id: asset.id,
            thumb: thumb,
            date: asset.createDateTime,
            hash: '',
            type: MediaType.image,
            name: asset.title ?? 'Unknown',
          ));
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
          isVideoMode: false,
          albumName: 'Random 15 Folders',
          albumId: null,
          photos: allPhotos,
          onPhotosDeleted: (deletedCount) {
            // Albüm listesini güncelle
            _refreshAlbumList();
          },
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
    
    // Albümler yükleniyor ekranı kaldırıldı - direkt ana ekrana geç
    
    // Fotoğraf yükleme progress overlay kaldırıldı - direkt ana ekrana geç
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Modern arka plan - Tema moduna göre değişir
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMainGradient
                  : AppColors.mainGradient,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri butonu - sol üst köşe
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
                  child: GestureDetector(
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
                  padding: const EdgeInsets.only(top: 16, left: 0, right: 0, bottom: 0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkButtonBackground
                            : Colors.white.withOpacity(0.13),
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
                // Sıralama kutusu ve görünüm seçenekleri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      // DropdownButton yerine PopupMenuButton ile modern ve özel menü:
                      Flexible(
                        flex: 4, // Daha fazla alan kaplasın
                        child: PopupMenuButton<AlbumSortType>(
                          onSelected: (AlbumSortType newValue) {
                            setState(() {
                              _sortType = newValue;
                            });
                          },
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBackgroundSecondary
                              : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: AlbumSortType.size,
                              child: Text(
                                appLoc.size, 
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkTextPrimary
                                      : Colors.black87,
                                  fontWeight: _sortType == AlbumSortType.size ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: AlbumSortType.name,
                              child: Text(
                                appLoc.name, 
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkTextPrimary
                                      : Colors.black87,
                                  fontWeight: _sortType == AlbumSortType.name ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 17,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkButtonBackground
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBorderColor
                                    : Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    _sortType == AlbumSortType.size
                                        ? appLoc.size
                                        : appLoc.name,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.darkTextPrimary
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkAccent
                                      : Colors.grey,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(), // Sağa itmek için boşluk
                      const SizedBox(width: 8),
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
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkAccent.withOpacity(0.2)
                                        : Colors.white)
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkButtonBackground
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _viewType == ViewType.folder
                                      ? (Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.darkAccent
                                          : Colors.grey.withOpacity(0.5))
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.darkBorderColor
                                          : Colors.grey.withOpacity(0.3)),
                                  width: _viewType == ViewType.folder ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: _viewType == ViewType.folder
                                        ? (Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkAccent
                                            : AppColors.mainGradient.colors.first)
                                        : (Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkAccent
                                            : Colors.grey),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appLoc.folder,
                                    style: TextStyle(
                                      color: _viewType == ViewType.folder
                                          ? (Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkAccent
                                              : Colors.black87)
                                          : (Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkTextPrimary
                                              : Colors.black87),
                                      fontWeight: _viewType == ViewType.folder ? FontWeight.w700 : FontWeight.w600,
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
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkAccent.withOpacity(0.2)
                                        : Colors.white)
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkButtonBackground
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _viewType == ViewType.date
                                      ? (Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.darkAccent
                                          : Colors.grey.withOpacity(0.5))
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.darkBorderColor
                                          : Colors.grey.withOpacity(0.3)),
                                  width: _viewType == ViewType.date ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: _viewType == ViewType.date
                                        ? (Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkAccent
                                            : AppColors.mainGradient.colors.first)
                                        : (Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkAccent
                                            : Colors.grey),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    appLoc.date,
                                    style: TextStyle(
                                      color: _viewType == ViewType.date
                                          ? (Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkAccent
                                              : Colors.black87)
                                          : (Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkTextPrimary
                                              : Colors.black87),
                                      fontWeight: _viewType == ViewType.date ? FontWeight.w700 : FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                    ],
                  ),
                ),
                                // Yumuşak geçiş eğrisi
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBackgroundSecondary
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Alt kısım - tema moduna göre arka plan
                Expanded(
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBackgroundSecondary
                        : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _viewType == ViewType.folder 
                          ? _buildFolderView()
                          : _buildMonthlyView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay
          if (_isFolderLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingWidget(
                  message: _folderLoadingMessage,
                  size: 80,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Klasör görünümü
  Widget _buildFolderView() {
    final appLoc = AppLocalizations.of(context)!;
    
    // Yükleme durumunda göster
    if (_isLoadingAlbums) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  // Arka plan daire
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  // Progress circle
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkAccent
                              : Color(0xFFFF6B9D), // Pembe
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Albüm yükleniyor...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isVideoMode ? 'Videolar hazırlanıyor' : 'Fotoğraflar hazırlanıyor',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
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
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkAccent,
                    ),
                    child: Text(appLoc.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAccent,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: _isVideoMode ? null : _buildAlbumThumbnail(album.album),
                title: Text(
                  album.album.name,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${album.count} ${_isVideoMode ? appLoc.videos : appLoc.photos}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : Colors.grey,
                    fontSize: 15,
                  ),
                ),
                onTap: null, // DebouncedButton üstte olduğu için null
              ),
            ),
          ),
        );
      },
    );
  }

  // Aylık görünüm - Klasör formatında (Lazy Loading ile optimize edilmiş)
  Widget _buildMonthlyView() {
    final appLoc = AppLocalizations.of(context)!;
    if (_photosByMonth.isEmpty) {
      return FutureBuilder<List<PhotoItem>>(
        future: _isVideoMode ? GalleryService.loadVideos(limit: 500) : GalleryService.loadPhotos(limit: 500), // Optimize edilmiş lazy loading
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        // Arka plan daire
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        // Progress circle
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.darkAccent
                                  : Color(0xFFFF6B9D), // Pembe
                              ),
                            ),
                          ),
                        ),
                        // İkon
                        Center(
                          child: Icon(
                            _isVideoMode ? Icons.video_library : Icons.photo_library,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isVideoMode ? appLoc.loadingVideos : appLoc.loadingPhotos,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLoc.pleaseWaitThisMayTakeTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Video/Fotoğrafları aylara göre grupla
            final groupedPhotos = _isVideoMode 
                ? GalleryService.groupVideosByMonth(snapshot.data!, appLoc)
                : GalleryService.groupPhotosByMonth(snapshot.data!, appLoc);
            _photosByMonth = groupedPhotos;
    
    return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: groupedPhotos.length,
      itemBuilder: (context, idx) {
                final monthKey = groupedPhotos.keys.elementAt(idx);
                final photos = groupedPhotos[monthKey]!;
                
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCardBackground
                        : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
                    leading: null, // Thumbnail'leri kaldır - performans için
                    title: Text(
                      monthKey,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${_getAlbumCountForMonth(monthKey)} ${_isVideoMode ? appLoc.videos : appLoc.photos}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : Colors.grey,
                      size: 16,
                    ),
                    onTap: () {
                      // Ay klasörüne tıklandığında fotoğrafları göster
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GalleryCleanerScreen(
                            isVideoMode: _isVideoMode,
                            albumName: monthKey,
                            albumId: monthKey,
                            photos: photos,
                            onPhotosDeleted: (deletedCount) {
                              // Albüm listesini güncelle
                              _refreshAlbumList();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          
          return Center(
            child: Text(
              appLoc?.noPhotosFound ?? 'No photos found',
              style: TextStyle(color: Colors.grey),
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
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: null, // Thumbnail'leri kaldır - performans için
            title: Text(
              monthKey,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '${_getAlbumCountForMonth(monthKey)} ${_isVideoMode ? appLoc.videos : appLoc.photos}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : Colors.grey,
                fontSize: 15,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : Colors.grey,
              size: 16,
            ),
            onTap: () {
              // Ay klasörüne tıklandığında fotoğrafları göster
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryCleanerScreen(
                    isVideoMode: _isVideoMode,
                    albumName: monthKey,
                    albumId: monthKey,
                    photos: photos,
                    onPhotosDeleted: (deletedCount) {
                      // Albüm listesini güncelle
                      _refreshAlbumList();
                    },
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
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.calendar_today, color: Colors.grey, size: 24),
      );
    }
    
    // İlk 4 fotoğrafı göster
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withOpacity(0.1),
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
    // Video modunda hiçbir görsel eleman gösterme
    if (_isVideoMode) {
      return const SizedBox(width: 60, height: 60); // Boş alan
    }
    
    // Fotoğraf modunda normal thumbnail göster
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
    
    // Yeni thumbnail yükle - daha küçük boyut kullan
    _loadingThumbnails.add(album.id);
    
    final future = album.getAssetListPaged(page: 0, size: 1)
        .then((assets) => assets.isNotEmpty 
            ? assets.first.thumbnailDataWithSize(const ThumbnailSize(800, 800)) // Kalite artırıldı (200->800)
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
          // Aylık görünüm cache'ini temizle (video/fotoğraf modları farklı)
          _photosByMonth.clear();
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
          color: selected 
              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white)
              : Colors.transparent,
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
            color: selected 
                ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackgroundPrimary : const Color(0xFF1B2A4D))
                : Colors.white,
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

  // Ay için albüm sayısını hesapla
  int _getAlbumCountForMonth(String monthKey) {
    // Gerçek sayıları göster - o ayın gerçek fotoğraf sayısı
    if (_photosByMonth.containsKey(monthKey) && _photosByMonth[monthKey] != null) {
      return _photosByMonth[monthKey]!.length;
    }
    return 0;
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
  bool _isOpeningAlbum = false; // Yeni flag ekledik

  void _onAlbumTap(_AlbumWithCount album) async {
    if (_isAlbumOpening) return;
    _isAlbumOpening = true;
    
    final appLoc = AppLocalizations.of(context)!;
    
    // Loading ekranını göster
    setState(() {
      _isFolderLoading = true;
      _folderLoadingMessage = appLoc.loadingFolder(album.album.name);
    });
    
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryCleanerScreen(
            isVideoMode: false,
            albumName: album.album.name,
            albumId: album.album.id,
            onPhotosDeleted: (deletedCount) {
              // Albüm listesini güncelle
              _refreshAlbumList();
            },
          ),
        ),
      );
    } finally {
      _isAlbumOpening = false;
      // Loading ekranını gizle
      setState(() {
        _isFolderLoading = false;
        _folderLoadingMessage = '';
      });
    }
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

// Modern arka plan, grid ve _AlbumCard ile ilgili eklemeleri kaldırıyorum.
// Eski klasik liste, arama çubuğu, toggle ve dalgalı arka planı geri getiriyorum.
// ... eski kodu uygula ...


