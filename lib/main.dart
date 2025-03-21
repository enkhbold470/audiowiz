import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audiowiz/core/constants/app_theme.dart';
import 'package:audiowiz/features/recording/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  runApp(
    const ProviderScope(
      child: AudioWizApp(),
    ),
  );
}

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
      home: const HomeScreen(),
    );
  }
}
