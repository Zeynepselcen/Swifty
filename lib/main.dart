import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'screens/video_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');
  ThemeMode _themeMode = ThemeMode.light; // Varsayılan açık mod

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    
    // Dil değişikliği sonrası daha güçlü yenileme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('es'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Color(0xFF0A183D),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0A183D),
          secondary: Color(0xFF233A5E),
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xFF0A183D),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0A183D),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0A183D),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0A183D)),
          bodyMedium: TextStyle(color: Color(0xFF0A183D)),
          bodySmall: TextStyle(color: Color(0xFF0A183D)),
          titleLarge: TextStyle(color: Color(0xFF0A183D)),
          titleMedium: TextStyle(color: Color(0xFF0A183D)),
          titleSmall: TextStyle(color: Color(0xFF0A183D)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A183D),
        primaryColor: Colors.white,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF233A5E),
          background: Color(0xFF0A183D),
          onPrimary: Color(0xFF0A183D),
          onSecondary: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B2A4D),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0A183D),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
      ),
      home: Builder(
        builder: (context) {
          return MainScreen(
            onLocaleChanged: _setLocale,
            currentLocale: _locale,
            isDarkTheme: _themeMode == ThemeMode.dark,
            onThemeChanged: () {
              setState(() {
                _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              });
            },
          );
        },
      ),
      routes: {
        '/main': (context) => Builder(
          builder: (context) {
            return MainScreen(
              onLocaleChanged: _setLocale,
              currentLocale: _locale,
              isDarkTheme: _themeMode == ThemeMode.dark,
              onThemeChanged: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                });
              },
            );
          },
        ),
      },
    );
  }
} 