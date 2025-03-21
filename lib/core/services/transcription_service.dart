import 'dart:async';
import 'dart:io';
import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/core/services/database_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

// Create a result class to provide more detailed information
class TranscriptionResult {
  final bool success;
  final String errorMessage;
  
  TranscriptionResult({required this.success, this.errorMessage = ''});
  
  static TranscriptionResult successful() => TranscriptionResult(success: true);
  static TranscriptionResult failure(String message) => 
      TranscriptionResult(success: false, errorMessage: message);
}

class TranscriptionService {
  static final TranscriptionService _instance = TranscriptionService._internal();
  static TranscriptionService get instance => _instance;
  
  TranscriptionService._internal();
  
  bool _isInitialized = false;
  bool _isListening = false;
  
  // Initialize with API key check
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Make sure API key is available
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('Error: OpenAI API key not found in environment variables');
      return false;
    }
    
    _isInitialized = true;
    return _isInitialized;
  }
  
  // Transcription using OpenAI Whisper API
  Future<TranscriptionResult> startFileTranscription(Recording recording, {String language = 'en'}) async {
    if (!await initialize()) {
      return TranscriptionResult.failure(
        'API key not found. Please add your OpenAI API key to the .env file.'
      );
    }
    
    try {
      // Check internet connectivity
      try {
        final result = await InternetAddress.lookup('openai.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          return TranscriptionResult.failure(
            'No internet connection. Please check your network and try again.'
          );
        }
      } on SocketException catch (_) {
        return TranscriptionResult.failure(
          'No internet connection. Please check your network and try again.'
        );
      }
      
      final transcription = await _transcribeWithWhisper(recording.filePath, language: language);
      
      // Update recording with transcription
      final updatedRecording = recording.copyWith(
        transcription: transcription,
        isProcessed: true,
      );
      
      // Save to database
      await DatabaseService.instance.updateRecording(updatedRecording);
      return TranscriptionResult.successful();
    } catch (e) {
      print('Transcription error: $e');
      String errorMessage = 'Failed to transcribe audio';
      
      if (e.toString().contains('401')) {
        errorMessage = 'Invalid API key. Please check your OpenAI API key.';
      } else if (e.toString().contains('429')) {
        errorMessage = 'API rate limit exceeded. Please try again later.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'OpenAI server error. Please try again later.';
      } else if (e.toString().contains('No API key')) {
        errorMessage = 'OpenAI API key not configured. Please add your API key to the .env file.';
      } else if (e.toString().contains('Connection')) {
        errorMessage = 'Network connection error. Please check your internet connection.';
      }
      
      return TranscriptionResult.failure(errorMessage);
    }
  }
  
  // Method to call Whisper API
  Future<String> _transcribeWithWhisper(String filePath, {String language = 'en'}) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key found in environment variables');
    }
    
    final apiBase = dotenv.env['OPENAI_API_BASE'];
    if (apiBase == null || apiBase.isEmpty) {
      throw Exception('No API base URL found in environment variables');
    }
    
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw Exception('Audio file not found at path: $filePath');
    }
    
    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBase/v1/audio/transcriptions'),
    );
    
    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
    });
    
    // Add file and fields
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: path.basename(filePath),
      ),
    );
    
    // Add model parameter (using whisper-1 model)
    request.fields['model'] = 'gpt-4o-mini-transcribe';
    
    // Add language parameter if not "en" (English is default for Whisper)
    if (language != 'en') {
      request.fields['language'] = language;
    }
    
    // Optional parameters
    // request.fields['response_format'] = 'json'; // Default is JSON
    // request.fields['temperature'] = '0'; // Control randomness (0-1)
    
    // Send request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode != 200) {
      throw Exception('Failed to transcribe: ${response.statusCode}\n$responseBody');
    }
    
    // Parse response
    final jsonResponse = json.decode(responseBody);
    return jsonResponse['text'] ?? 'Transcription completed but no text was returned';
  }
  
  // Generate a summary from transcription
  Future<bool> generateSummary(Recording recording) async {
    if (recording.transcription == null || recording.transcription!.isEmpty) {
      return false;
    }
    
    try {
      // Use OpenAI Chat API to generate a summary
      final summary = await _generateSummaryWithOpenAI(recording.transcription!);
      
      // Update recording with summary
      final updatedRecording = recording.copyWith(
        summary: summary,
      );
      
      // Save to database
      await DatabaseService.instance.updateRecording(updatedRecording);
      return true;
    } catch (e) {
      print('Summary generation error: $e');
      return false;
    }
  }
  
  // Use OpenAI Chat API to generate summary
  Future<String> _generateSummaryWithOpenAI(String transcription) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    
    final response = await http.post(
      Uri.parse('${dotenv.env['OPENAI_API_BASE']}/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that creates concise summaries of transcriptions.'
          },
          {
            'role': 'user',
            'content': 'Please summarize the following transcription in a few sentences:\n\n$transcription'
          }
        ],
        'temperature': 0.3,
        'max_tokens': 200,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to generate summary: ${response.statusCode}\n${response.body}');
    }
    
    final jsonResponse = json.decode(response.body);
    return jsonResponse['choices'][0]['message']['content'] ?? 'Summary generation completed but no text was returned';
  }
  
  // Real-time speech recognition methods could be added here
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (!_isListening) {
      _isListening = true;
      // Simulate speech recognition with a message about Whisper API
      Future.delayed(Duration(seconds: 2), () {
        onResult("Real-time transcription would require streaming audio to Whisper API, which is not implemented yet. You can record and then transcribe.");
      });
    }
  }
  
  Future<void> stopListening() async {
    _isListening = false;
  }
  
  // Dispose resources
  void dispose() {
    _isListening = false;
  }
} 