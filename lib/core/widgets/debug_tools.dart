import 'package:flutter/material.dart';
import 'package:audiowiz/core/services/supabase_service.dart';

class DebugTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        try {
          // Test Supabase connection
          final response = await SupabaseService.instance.fetchUserRecordings();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Supabase test successful: ${response.toString()}'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Supabase error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Icon(Icons.bug_report),
    );
  }
} 