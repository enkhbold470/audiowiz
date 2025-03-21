import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/features/history/widgets/recording_item.dart';
import 'package:audiowiz/features/transcription/screens/transcription_screen.dart';
import 'package:audiowiz/features/recording/providers/recording_provider.dart';
import 'package:intl/intl.dart';

class RecordingsListScreen extends ConsumerWidget {
  const RecordingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);
    final recordings = recordingState.recordings;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the recordings
              ref.invalidate(recordingProvider);
            },
          ),
        ],
      ),
      body: recordings.isEmpty 
        ? _buildEmptyState()
        : _buildRecordingsList(context, recordings),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mic_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'No recordings yet',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Start recording to see your entries here',
            style: AppConstants.bodyStyle,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecordingsList(BuildContext context, List<Recording> recordings) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: recordings.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppConstants.smallPadding),
      itemBuilder: (context, index) {
        final recording = recordings[index];
        return RecordingItem(
          recording: recording,
          onTap: () => _navigateToTranscription(context, recording),
        );
      },
    );
  }
  
  void _navigateToTranscription(BuildContext context, Recording recording) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranscriptionScreen(recording: recording),
      ),
    );
  }
} 