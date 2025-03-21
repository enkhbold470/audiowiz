import 'package:flutter/material.dart';
import 'package:audiowiz/core/constants/app_constants.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? Colors.red : AppConstants.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
} 