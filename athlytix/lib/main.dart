import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://YOUR_PROJECT.supabase.co',
);
const String _supabaseKey = String.fromEnvironment(
  'SUPABASE_KEY',
  defaultValue: 'YOUR_ANON_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseKey);
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
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
