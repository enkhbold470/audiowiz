import 'package:flutter/material.dart';
import 'package:audiowiz/core/constants/app_constants.dart';
import 'package:audiowiz/features/auth/screens/login_screen.dart';
import 'package:audiowiz/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _avatarUrl;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user
      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email ?? 'No email available';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signOut();
      
      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                    child: _avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              _avatarUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppConstants.primaryColor,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // User email
                Center(
                  child: Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // App settings section
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        subtitle: const Text('English'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Implement language selection
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.cloud_outlined),
                        title: const Text('Cloud Sync'),
                        subtitle: const Text('Automatic'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Implement sync settings
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Account section
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Implement password change
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // App info
                Center(
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }
}