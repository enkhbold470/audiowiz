import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/core/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:audiowiz/core/services/supabase_service.dart';
import 'package:sqflite/sqflite.dart';

class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  static RecordingService get instance => _instance;
  
  RecordingService._internal() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentPlayingPath = null;
    });
  }
  
  final _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentPlayingPath;
  DateTime? _recordingStartTime;
  
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  
  // Initialize recordings directory
  Future<String> get _recordingsPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${AppConstants.recordingsDirectory}';
    await Directory(path).create(recursive: true);
    return path;
  }
  
  // Request permissions
  Future<bool> requestPermissions() async {
    // Always need microphone permission
    final micPermission = await Permission.microphone.request();
    
    // For storage, we need to check the Android version
    bool storagePermissionGranted = false;
    
    // For Android 13+, request media permissions
    if (Platform.isAndroid) {
      try {
        // This checks if we're on Android 13+ and requests the appropriate permission
        final storagePermission = await Permission.audio.request();
        storagePermissionGranted = storagePermission.isGranted;
      } catch (e) {
        // Fallback to the old storage permission for older versions
        final storagePermission = await Permission.storage.request();
        storagePermissionGranted = storagePermission.isGranted;
      }
    } else {
      // For iOS or other platforms
      final storagePermission = await Permission.storage.request();
      storagePermissionGranted = storagePermission.isGranted;
    }
    
    return micPermission.isGranted && storagePermissionGranted;
  }
  
  // Start recording
  Future<bool> startRecording() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return false;
    }
    
    // Check if already recording
    final isCurrentlyRecording = await _recorder.isRecording();
    if (isCurrentlyRecording) {
      return false;
    }
    
    // Generate a unique filename
    final uuid = const Uuid().v4();
    final path = await _recordingsPath;
    final filePath = '$path/$uuid.m4a';
    
    try {
      // Configure recorder and start
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: AppConstants.defaultRecordingQualitySampleRate,
        ),
        path: filePath,
      );
      
      _recordingStartTime = DateTime.now();
      _isRecording = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Stop recording and save to database
  Future<Recording?> stopRecording(String title) async {
    if (!_isRecording) {
      return null;
    }
    
    try {
      // Add a small delay to ensure encoder has finished
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Stop the recorder
      final path = await _recorder.stop();
      
      if (path == null) {
        return null;
      }
      
      _isRecording = false;
      
      // Calculate duration
      final now = DateTime.now();
      final durationInSeconds = now.difference(_recordingStartTime!).inSeconds;
      
      // Create recording object without supabaseId
      final recording = Recording(
        title: title.isNotEmpty ? title : 'Recording ${now.toString()}',
        filePath: path,
        durationInSeconds: durationInSeconds,
        // Don't include supabaseId field
      );
      
      // Use DatabaseService directly instead of accessing the database
      final id = await DatabaseService.instance.insertRecording(recording);
      
      final savedRecording = recording.copyWith(id: id);
      
      // Skip Supabase save for now
      // if (SupabaseService.instance.isLoggedIn) { ... }
      
      return savedRecording;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }
  
  // Delete recording
  Future<bool> deleteRecording(Recording recording) async {
    try {
      // Delete file
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Delete from database
      if (recording.id != null) {
        await DatabaseService.instance.deleteRecording(recording.id!);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Play recording
  Future<bool> playRecording(String filePath) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }
    
    try {
      await _audioPlayer.play(DeviceFileSource(filePath));
      _currentPlayingPath = filePath;
      _isPlaying = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Pause playing
  Future<bool> pausePlaying() async {
    if (!_isPlaying) return false;
    
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Resume playing
  Future<bool> resumePlaying() async {
    if (_isPlaying || _currentPlayingPath == null) return false;
    
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Stop playing
  Future<bool> stopPlaying() async {
    if (!_isPlaying && _currentPlayingPath == null) return false;
    
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPlayingPath = null;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get recording duration
  Future<Duration?> getRecordingDuration(String filePath) async {
    try {
      return await _audioPlayer.setSource(DeviceFileSource(filePath)).then((_) {
        return _audioPlayer.getDuration();
      });
    } catch (e) {
      return null;
    }
  }
  
  // Dispose resources
  void dispose() {
    _recorder.dispose();
    _audioPlayer.dispose();
  }
}