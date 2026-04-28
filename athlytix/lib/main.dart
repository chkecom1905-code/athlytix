import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialiser Firebase (utilise GoogleService-Info.plist automatiquement)
  await Firebase.initializeApp();

  runApp(const BallvynApp());
}

class BallvynApp extends StatelessWidget {
  const BallvynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BALLVYN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFF7C3AED),
          surface: Color(0xFF0F0F1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF07070F),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
