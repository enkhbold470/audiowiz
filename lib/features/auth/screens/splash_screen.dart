import 'package:flutter/material.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/features/auth/screens/login_screen.dart';
import 'package:audiowiz/features/recording/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audiowiz/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if user is signed in - FIX: Use currentSession instead of getSession()
      final session = supabase.auth.currentSession;
      await Future.delayed(const Duration(milliseconds: 1500)); // Logo display time
      
      if (mounted) {
        if (session != null) {
          // User is signed in, navigate to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // No user, navigate to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // In case of auth error, direct to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.mic,
              size: 100,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoading)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}