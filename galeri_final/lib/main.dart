import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const GaleriApp());
}

class GaleriApp extends StatefulWidget {
  const GaleriApp({super.key});

  @override
  State<GaleriApp> createState() => _GaleriAppState();
}

class _GaleriAppState extends State<GaleriApp> {
  @override
  void initState() {
    super.initState();
    _requestLocalNetworkPermission();
  }

  void _requestLocalNetworkPermission() async {
    if (!Platform.isIOS) return;
    try {
      final RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.send([1, 2, 3], InternetAddress('255.255.255.255'), 65000);
      socket.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeri Temizleyici',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 