import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/features/recording/providers/recording_provider.dart';
import 'package:audiowiz/features/recording/widgets/recording_button.dart';
import 'package:audiowiz/features/history/screens/recordings_list_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:audiowiz/core/models/recording.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:audiowiz/core/services/recording_service.dart';
import 'package:audiowiz/core/services/database_service.dart';
import 'package:audiowiz/features/transcription/screens/transcription_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:audiowiz/features/auth/screens/profile_screen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  Timer? _recordingTimer;
  Duration _currentDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _setDefaultTitle();
  }
  
  void _setDefaultTitle() {
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _titleController.text = 'Recording $formattedDate $formattedTime';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final isRecording = recordingState.isRecording;
    final isProcessing = recordingState.isProcessing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AudioWiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import Audio',
            onPressed: isRecording || isProcessing ? null : _importAudioFile,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordingsListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Recording title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recording Title',
                border: OutlineInputBorder(),
              ),
              enabled: !isRecording && !isProcessing,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Recording status
            Expanded(
              child: Center(
                child: _buildContent(isRecording, isProcessing),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RecordingButton(
        isRecording: isRecording,
        onPressed: _toggleRecording,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildContent(bool isRecording, bool isProcessing) {
    if (isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitWave(
            color: AppConstants.primaryColor,
            size: 50.0,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text('Processing audio... ⏳'),
        ],
      );
    }
    
    if (isRecording) {
      final formattedDuration = _formatDuration(_currentDuration);
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsating microphone icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.2),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.redAccent,
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            '🎙️ Recording in progress...',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            formattedDuration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'Tap the stop button when you\'re done ✋',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mic_none,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        const Text(
          '🎤 Ready to record!',
          textAlign: TextAlign.center,
          style: AppConstants.subheadingStyle,
        ),
        const SizedBox(height: AppConstants.largePadding),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Tap the microphone button below to start recording your voice, lecture, or meeting',
            textAlign: TextAlign.center,
            style: AppConstants.bodyStyle,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureItem(Icons.transcribe, 'Transcribe'),
            const SizedBox(width: 24),
            _buildFeatureItem(Icons.summarize, 'Summarize'),
            const SizedBox(width: 24),
            _buildFeatureItem(Icons.share, 'Share'),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return '$hours:$minutes:$seconds';
  }
  
  void _toggleRecording() async {
    final recordingNotifier = ref.read(recordingProvider.notifier);
    final isRecording = ref.read(recordingProvider).isRecording;
    
    if (isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
      final recording = await recordingNotifier.stopRecording(_titleController.text);
      
      if (recording != null) {
        // Reset duration
        setState(() {
          _currentDuration = Duration.zero;
        });
        
        // Reset title for next recording
        _setDefaultTitle();
        
        // Show completion dialog
        if (mounted) {
          _showRecordingCompleteDialog(recording);
        }
      }
    } else {
      // Start recording
      final success = await recordingNotifier.startRecording();
      
      if (success) {
        // Start timer to track duration
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _currentDuration = Duration(seconds: timer.tick);
          });
        });
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(
              content: Text('Failed to start recording. Please check microphone permissions.'),
            ),
          );
        }
      }
    }
  }
  
  void _showRecordingCompleteDialog(Recording recording) {
    showDialog(
      context: context as BuildContext,
      builder: (context) => AlertDialog(
        title: const Text('Recording Complete'),
        content: const Text(
          'Your recording has been saved successfully.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordingsListScreen(),
                ),
              );
            },
            child: const Text('View Recordings'),
          ),
        ],
      ),
    );
  }

  Future<void> _importAudioFile() async {
    try {
      // Request storage permissions
      final storagePermission = await Permission.storage.request();
      if (!storagePermission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to import audio files')),
          );
        }
        return;
      }
      
      // Use file picker to select audio files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return; // User cancelled the picker
      }
      
      final file = result.files.first;
      if (file.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Could not access the selected file')),
          );
        }
        return;
      }
      
      // Get file info
      final audioFile = File(file.path!);
      final fileName = file.name;
      final fileSize = await audioFile.length();
      
      // Check if file size is reasonable (e.g., less than 25MB which is Whisper's limit)
      if (fileSize > 25 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('File too large! Maximum size is 25MB.')),
          );
        }
        return;
      }
      
      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final recordingsDir = '${appDir.path}/${AppConstants.recordingsDirectory}';
      await Directory(recordingsDir).create(recursive: true);
      
      final uuid = const Uuid().v4();
      final targetPath = '$recordingsDir/$uuid${extension(file.path!)}';
      await audioFile.copy(targetPath);
      
      // Show dialog to enter title
      if (mounted) {
        final titleController = TextEditingController(text: fileName.split('.').first);
        showDialog(
          context: context as BuildContext  ,
          builder: (context) => AlertDialog(
            title: const Text('Name your recording'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Recording title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  // Get approximate duration
                  final duration = await RecordingService.instance.getRecordingDuration(targetPath);
                  final durationInSeconds = duration?.inSeconds ?? 0;
                  
                  // Create recording object
                  final recording = Recording(
                    title: titleController.text.isNotEmpty ? titleController.text : 'Imported Recording',
                    filePath: targetPath,
                    durationInSeconds: durationInSeconds,
                  );
                  
                  // Save to database
                  final id = await DatabaseService.instance.insertRecording(recording);
                  final savedRecording = recording.copyWith(id: id);
                  
                  // Refresh recordings list
                  ref.invalidate(recordingProvider);
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                      const SnackBar(content: Text('Audio file imported successfully')),
                    );
                    
                    // Navigate to the recording
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranscriptionScreen(recording: savedRecording),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    }
  }

  // Helper method for feature items
  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.accentColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // void _testSupabaseConnection() async {
  //   try {
  //     final user = supabase.auth.currentUser;
  //     print('Current user: ${user?.id}, ${user?.email}');
      
  //     // Try a simple query
  //     final test = await supabase.from('user_recordings').select('id').limit(1);
  //     print('Test query result: $test');
      
  //     // Try inserting a test record
  //     final testData = {
  //       'user_id': user?.id,
  //       'title': 'Test Recording',
  //       'duration_in_seconds': 10,
  //     };
      
  //     final result = await supabase.from('user_recordings').insert(testData).select();
  //     print('Insert test result: $result');
  //   } catch (e) {
  //     print('Supabase test error: $e');
  //   }
  // }
} 