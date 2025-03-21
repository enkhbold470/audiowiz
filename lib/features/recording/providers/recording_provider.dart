import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/core/services/recording_service.dart';
import 'package:audiowiz/core/services/database_service.dart';

// Recording state class
class RecordingState {
  final bool isRecording;
  final bool isProcessing;
  final String? currentRecordingPath;
  final Duration recordingDuration;
  final List<Recording> recordings;
  
  RecordingState({
    this.isRecording = false,
    this.isProcessing = false,
    this.currentRecordingPath,
    this.recordingDuration = Duration.zero,
    this.recordings = const [],
  });
  
  RecordingState copyWith({
    bool? isRecording,
    bool? isProcessing,
    String? currentRecordingPath,
    Duration? recordingDuration,
    List<Recording>? recordings,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      currentRecordingPath: currentRecordingPath ?? this.currentRecordingPath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordings: recordings ?? this.recordings,
    );
  }
}

// Recording notifier
class RecordingNotifier extends StateNotifier<RecordingState> {
  final RecordingService _recordingService;
  final DatabaseService _databaseService;
  
  RecordingNotifier(this._recordingService, this._databaseService)
      : super(RecordingState()) {
    _loadRecordings();
  }
  
  // Load all recordings from the database
  Future<void> _loadRecordings() async {
    final recordings = await _databaseService.getAllRecordings();
    state = state.copyWith(
      recordings: recordings,
    );
  }
  
  // Start recording
  Future<bool> startRecording() async {
    final result = await _recordingService.startRecording();
    
    if (result) {
      state = state.copyWith(
        isRecording: true,
        recordingDuration: Duration.zero,
      );
    }
    
    return result;
  }
  
  // Stop recording
  Future<Recording?> stopRecording(String title) async {
    state = state.copyWith(isProcessing: true);
    
    final recording = await _recordingService.stopRecording(title);
    
    if (recording != null) {
      await _loadRecordings();
    }
    
    state = state.copyWith(
      isRecording: false,
      isProcessing: false,
    );
    
    return recording;
  }
  
  // Delete recording
  Future<bool> deleteRecording(Recording recording) async {
    final result = await _recordingService.deleteRecording(recording);
    
    if (result) {
      await _loadRecordings();
    }
    
    return result;
  }
  
  // Update recording duration
  void updateRecordingDuration(Duration duration) {
    state = state.copyWith(recordingDuration: duration);
  }
}

// Providers
final recordingServiceProvider = Provider<RecordingService>(
  (ref) => RecordingService.instance,
);

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService.instance,
);

final recordingProvider = StateNotifierProvider<RecordingNotifier, RecordingState>(
  (ref) => RecordingNotifier(
    ref.watch(recordingServiceProvider),
    ref.watch(databaseServiceProvider),
  ),
);

// Providers for filtered recordings
final favoriteRecordingsProvider = Provider<List<Recording>>(
  (ref) => ref.watch(recordingProvider).recordings
      .where((recording) => recording.isFavorite)
      .toList(),
);

final processedRecordingsProvider = Provider<List<Recording>>(
  (ref) => ref.watch(recordingProvider).recordings
      .where((recording) => recording.isProcessed)
      .toList(),
);

final pendingRecordingsProvider = Provider<List<Recording>>(
  (ref) => ref.watch(recordingProvider).recordings
      .where((recording) => !recording.isProcessed)
      .toList(),
); 