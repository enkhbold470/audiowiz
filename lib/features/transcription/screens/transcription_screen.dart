import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:audiowiz/core/services/recording_service.dart';
import 'package:audiowiz/core/services/transcription_service.dart';
import 'package:audiowiz/core/services/database_service.dart';
import 'package:share_plus/share_plus.dart';

class TranscriptionScreen extends ConsumerStatefulWidget {
  final Recording recording;

  const TranscriptionScreen({
    super.key,
    required this.recording,
  });

  @override
  ConsumerState<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends ConsumerState<TranscriptionScreen> {
  bool _isPlaying = false;
  bool _isProcessing = false;
  late Recording _recording;
  String _selectedLanguage = 'en'; // Default to English
  
  @override
  void initState() {
    super.initState();
    _recording = widget.recording;
  }
  
  @override
  void dispose() {
    RecordingService.instance.stopPlaying();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRecording,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyTranscription,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recording info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recording.title,
                      style: AppConstants.headingStyle,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Row(
                      children: [
                        Text(_formatDuration(_recording.durationInSeconds)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: _togglePlayback,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Transcription content
            Expanded(
              child: _buildContentSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }
  
  Widget _buildContentSection() {
    if (!_recording.isProcessed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.text_fields,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'This recording has not been processed yet.',
              style: AppConstants.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Language selection dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[50],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Language: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      }
                    },
                    items: AppConstants.supportedLanguages.entries
                        .map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Text(AppConstants.languageFlags[entry.key] ?? ''),
                            const SizedBox(width: 8),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: _processRecording,
              child: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Process Now'),
            ),
          ],
        ),
      );
    }
    
    if (_recording.transcription == null || _recording.transcription!.isEmpty) {
      return const Center(
        child: Text(
          'No transcription available for this recording.',
          style: AppConstants.bodyStyle,
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transcription:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: AppConstants.defaultBorderRadius,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _recording.transcription!,
              style: AppConstants.bodyStyle,
            ),
          ),
          
          // Summary section
          if (_recording.summary != null && _recording.summary!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.summarize, color: AppConstants.accentColor),
                SizedBox(width: 8),
                Text(
                  'Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE0F7FA), // Light cyan background
                borderRadius: AppConstants.defaultBorderRadius,
                border: Border.all(color: AppConstants.accentColor.withOpacity(0.3)),
              ),
              child: Text(
                _recording.summary!,
                style: AppConstants.bodyStyle.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildBottomButton() {
    if (!_recording.isProcessed || 
        _recording.transcription == null || 
        _recording.transcription!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (_recording.summary == null || _recording.summary!.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          bottom: AppConstants.defaultPadding + MediaQuery.of(context).padding.bottom, // Add safe area padding
          top: AppConstants.defaultPadding,
        ),
        child: ElevatedButton(
          onPressed: _generateSummary,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Generate Summary'),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  void _togglePlayback() async {
    if (_isPlaying) {
      await RecordingService.instance.pausePlaying();
      setState(() {
        _isPlaying = false;
      });
    } else {
      final success = await RecordingService.instance.playRecording(_recording.filePath);
      if (success) {
        setState(() {
          _isPlaying = true;
        });
        
        // Add a listener to detect when playback stops
        Future.delayed(Duration(seconds: 1), () {
          if (mounted && !RecordingService.instance.isPlaying) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    }
  }
  
  void _processRecording() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Show a progress message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transcribing in ${AppConstants.supportedLanguages[_selectedLanguage]}...'),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Pass the selected language to the transcription service
    final success = await TranscriptionService.instance.startFileTranscription(
      _recording, 
      language: _selectedLanguage,
    );
    
    if (success) {
      // Refresh recording data from database
      final updated = await DatabaseService.instance.getRecordingById(_recording.id!);
      if (updated != null && mounted) {
        setState(() {
          _recording = updated;
          _isProcessing = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transcription completed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process recording. Please check your API key and network connection.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  void _generateSummary() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Use the transcription service to generate a summary
    final success = await TranscriptionService.instance.generateSummary(_recording);
    
    if (success) {
      // Refresh recording data from database
      final updated = await DatabaseService.instance.getRecordingById(_recording.id!);
      if (updated != null && mounted) {
        setState(() {
          _recording = updated;
          _isProcessing = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate summary. Please try again.'),
          ),
        );
      }
    }
  }
  
  void _shareRecording() {
    String content = 'Recording: ${_recording.title}\n';
    content += 'Duration: ${_formatDuration(_recording.durationInSeconds)}\n\n';
    
    if (_recording.transcription != null && _recording.transcription!.isNotEmpty) {
      content += 'Transcription:\n${_recording.transcription}\n\n';
    }
    
    if (_recording.summary != null && _recording.summary!.isNotEmpty) {
      content += 'Summary:\n${_recording.summary}';
    }
    
    Share.share(
      content,
      subject: 'Recording: ${_recording.title}',
    );
  }
  
  void _copyTranscription() {
    if (_recording.transcription == null || _recording.transcription!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transcription available to copy')),
      );
      return;
    }
    
    Clipboard.setData(ClipboardData(text: _recording.transcription!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcription copied to clipboard')),
    );
  }
  
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds - minutes * 60;
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 