import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {
  final Recording recording;

  const SummaryScreen({
    super.key,
    required this.recording,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareSummary(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copySummary(context),
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
                      recording.title,
                      style: AppConstants.headingStyle,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Duration: ${_formatDuration(recording.durationInSeconds)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Summary content
            Expanded(
              child: _buildSummaryContent(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleFavorite(context),
        child: Icon(
          recording.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: recording.isFavorite ? Colors.red : null,
        ),
      ),
    );
  }
  
  Widget _buildSummaryContent(BuildContext context) {
    if (recording.summary == null || recording.summary!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.summarize,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'No summary available for this recording.',
              style: AppConstants.subheadingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () => _generateSummary(context),
              child: const Text('Generate Summary'),
            ),
          ],
        ),
      );
    }
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Key Insights',
                style: AppConstants.subheadingStyle,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                recording.summary!,
                style: AppConstants.bodyStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _generateSummary(BuildContext context) {
    // In a real app, this would call a service to generate the summary
    // For demo purposes, we just update the state directly
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      // Update recording with a summary
      recording.summary = 'This is a simulated summary of the recording "${recording.title}". '
        'In a real app, this would be an actual summary created using natural language processing '
        'to extract the key points and main ideas from the transcription.';
      
      // Close loading dialog and refresh
      Navigator.pop(context);
      
      // Force refresh by rebuilding the screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(recording: recording),
        ),
      );
    });
  }
  
  void _toggleFavorite(BuildContext context) {
    // In a real app, this would update the database
    recording.isFavorite = !recording.isFavorite;
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recording.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Force refresh
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(recording: recording),
      ),
    );
  }
  
  void _shareSummary(BuildContext context) {
    if (recording.summary == null || recording.summary!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary available to share')),
      );
      return;
    }
    
    Share.share(
      'Summary: ${recording.title}\n\n${recording.summary}',
      subject: 'Summary: ${recording.title}',
    );
  }
  
  void _copySummary(BuildContext context) {
    if (recording.summary == null || recording.summary!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary available to copy')),
      );
      return;
    }
    
    Clipboard.setData(ClipboardData(text: recording.summary!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }
  
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds - minutes * 60;
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 