import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audiowiz/core/constants/app_theme.dart';
// import 'package:audiowiz/features/recording/screens/home_screen.dart';
import 'package:audiowiz/features/auth/screens/splash_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
    await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // GoTrueClient goTrueClient = GoTrueClient(
  //   url: dotenv.env['SUPABASE_URL']!,
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  // );
  // Then run your app
  runApp(
    const ProviderScope(
      child: AudioWizApp(),
    ),
  );
}

// Global instance of Supabase client
final supabase = Supabase.instance.client;

class AudioWizApp extends StatelessWidget {
  const AudioWizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioWiz',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
