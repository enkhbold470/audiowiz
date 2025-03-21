import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;
  
  SupabaseService._internal();
  
  static final List<String> _debugLogs = [];
  static List<String> get debugLogs => _debugLogs;
  
  void _addLog(String message) {
    print('Supabase Debug: $message'); // Console log
    _debugLogs.insert(0, '${DateTime.now().toString()}: $message');
    if (_debugLogs.length > 20) _debugLogs.removeLast(); // Keep last 20 logs
  }
  
  // Check if user is logged in
  bool get isLoggedIn => supabase.auth.currentSession != null;
  
  // Get current user ID
  String? get currentUserId => supabase.auth.currentUser?.id;
  
  // Save recording to Supabase
  Future<String?> saveRecording(Recording recording) async {
    if (!isLoggedIn) {
      _addLog('❌ Not logged in, cannot save recording');
      return null;
    }
    
    try {
      _addLog('📤 Starting upload for recording: ${recording.title}');
      
      // First, upload the audio file to Supabase Storage
      final filePath = recording.filePath;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${recording.uuid}.m4a';
      
      _addLog('📁 Uploading file to storage: $fileName');
      final storageResponse = await supabase
          .storage
          .from('recordings')
          .upload(fileName, File(filePath));
          
      _addLog('✅ File uploaded successfully');

      // Get the public URL for the uploaded file
      final fileUrl = supabase
          .storage
          .from('recordings')
          .getPublicUrl(fileName);
      
      _addLog('🔗 File URL generated: $fileUrl');

      // Convert recording to match Supabase schema
      final recordingData = {
        'user_id': currentUserId,
        'title': recording.title,
        'file_path': filePath,
        'file_url': fileUrl,
        'duration_in_seconds': recording.durationInSeconds,
        'transcription': recording.transcription,
        'summary': recording.summary,
        'is_processed': recording.isProcessed,
        'is_favorite': recording.isFavorite,
        'created_at': recording.createdAt.toIso8601String(),
      };
      
      _addLog('💾 Inserting record into user_recordings table');
      _addLog('📝 Data: ${recordingData.toString()}');

      // Insert into user_recordings table
      final response = await supabase
          .from('user_recordings')
          .insert(recordingData)
          .select('id')
          .single();
      
      _addLog('✅ Record inserted successfully with ID: ${response['id']}');
      return response['id'];
    } catch (e) {
      _addLog('❌ Error: $e');
      return null;
    }
  }
  
  // Update recording in Supabase
  Future<bool> updateRecording(Recording recording, String supabaseId) async {
    if (!isLoggedIn) return false;
    
    try {
      await supabase
          .from('user_recordings')
          .update({
            'title': recording.title,
            'transcription': recording.transcription,
            'summary': recording.summary,
            'is_processed': recording.isProcessed,
            'is_favorite': recording.isFavorite,
          })
          .eq('id', supabaseId)
          .eq('user_id', currentUserId ?? ''); // Security: ensure user owns the recording
      
      return true;
    } catch (e) {
      print('Error updating recording in Supabase: $e');
      return false;
    }
  }
  
  // Delete recording from Supabase
  Future<bool> deleteRecording(String supabaseId) async {
    if (!isLoggedIn) return false;
    
    try {
      // Get the file_url before deleting the record
      final record = await supabase
          .from('user_recordings')
          .select('file_url')
          .eq('id', supabaseId)
          .eq('user_id', currentUserId ?? '')
          .single();
          
      // Delete from storage if file exists
      if (record['file_url'] != null) {
        final fileName = record['file_url'].split('/').last;
        await supabase.storage.from('recordings').remove([fileName]);
      }
      
      // Delete the record
      await supabase
          .from('user_recordings')
          .delete()
          .eq('id', supabaseId)
          .eq('user_id', currentUserId ?? '');
      
      return true;
    } catch (e) {
      print('Error deleting recording from Supabase: $e');
      return false;
    }
  }
  
  // Fetch all recordings for current user
  Future<List<Recording>> fetchUserRecordings() async {
    if (!isLoggedIn) return [];
    
    try {
      final response = await supabase
          .from('user_recordings')
          .select()
          .eq('user_id', currentUserId ?? '')
          .order('created_at', ascending: false);
      
      return response.map<Recording>((data) => Recording(
        id: null, // Local SQLite ID
        title: data['title'],
        filePath: data['file_path'],
        durationInSeconds: data['duration_in_seconds'],
        transcription: data['transcription'],
        summary: data['summary'],
        isProcessed: data['is_processed'],
        isFavorite: data['is_favorite'],
        supabaseId: data['id'],
      )).toList();
    } catch (e) {
      print('Error fetching recordings from Supabase: $e');
      return [];
    }
  }
}