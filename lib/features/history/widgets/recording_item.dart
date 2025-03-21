import 'package:flutter/material.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/core/models/recording.dart';
import 'package:intl/intl.dart';

class RecordingItem extends StatelessWidget {
  final Recording recording;
  final VoidCallback onTap;

  const RecordingItem({
    super.key,
    required this.recording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppConstants.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recording.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (recording.isFavorite)
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Icon(
                    recording.isProcessed ? Icons.check_circle : Icons.pending,
                    size: 16,
                    color: recording.isProcessed ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recording.isProcessed ? 'Processed' : 'Pending',
                    style: TextStyle(
                      color: recording.isProcessed ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(recording.durationInSeconds),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              if (recording.summary != null && recording.summary!.isNotEmpty)
                Text(
                  recording.summary!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Text(
                _formatDate(recording.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds - minutes * 60;
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy · h:mm a').format(dateTime);
  }
} 