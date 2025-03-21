import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audiowiz/core/services/supabase_service.dart';
import 'package:audiowiz/core/widgets/debug_overlay.dart';

class RecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your existing recording screen content
        Scaffold(
          // ... existing content
        ),
        
        // Debug overlay
        if (kDebugMode) // Only show in debug mode
          DebugOverlay(logs: SupabaseService.debugLogs),
      ],
    );
  }
} 