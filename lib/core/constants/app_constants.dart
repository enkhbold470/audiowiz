import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'AudioWiz';
  static const String appVersion = '1.0.0';
  
  // Storage
  static const String recordingsDirectory = 'recordings';
  static const String modelsDirectory = 'models';
  
  // Whisper models
  static const Map<String, String> whisperModels = {
    'tiny': 'tiny-int8.gguf',
    'base': 'base-int8.gguf',
    'small': 'small-int8.gguf',
    'medium': 'medium-int8.gguf',
  };
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(12.0));
  
  // Recording
  static const int maxRecordingDurationMinutes = 180; // 3 hours
  static const int defaultRecordingQualitySampleRate = 16000; // 16kHz
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  
  // Colors
  static const Color primaryColor = Color(0xFF6A1B9A);
  static const Color secondaryColor = Color(0xFF4527A0);
  static const Color accentColor = Color(0xFF00BFA5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFB71C1C);
  
  // Text
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
  );

  // Supported languages for transcription
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'zh': 'Chinese',
    'ko': 'Korean',
    'es': 'Spanish',
    'mn': 'Mongolian',
  };

  // Language flag emojis
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'zh': '🇨🇳',
    'ko': '🇰🇷',
    'es': '🇪🇸',
    'mn': '🇲🇳',
  };
} 