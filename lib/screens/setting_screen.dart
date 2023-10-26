import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memories_app/screens/profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _username;
  String? _userEmail;
  String? _profileImageUrl;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        _username = userData['username'];
        _userEmail = userData['email'];
        _profileImageUrl = userData['image_url'];
      });
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) =>
          route.isFirst); // This ensures you go back to the root screen.
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred during logout.'),
        ),
      );
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Out',
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        content: Text('Do you really want to log out?',
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          TextButton(
            onPressed: () {
              _handleSignOut(context);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode currentThemeMode =
        Theme.of(context).brightness == Brightness.light
            ? ThemeMode.light
            : ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () async {
              var updatedUsername = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    username: _username,
                    userEmail: _userEmail,
                    profileImageUrl: _profileImageUrl,
                  ),
                ),
              );
              if (updatedUsername != null) {
                setState(() {
                  _username = updatedUsername;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (_profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(_profileImageUrl!)
                        : null,
                    child:
                        (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username ?? 'Loading...',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                      Text(
                        _userEmail ?? 'Loading...',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          ListTile(
            trailing: const Icon(Icons.login_outlined),
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text('Press on it to Log out',
                style: TextStyle(
                  color: currentThemeMode == ThemeMode.dark
                      ? Colors.grey[450]
                      : Colors.black87,
                )),
            onTap: () {
              _confirmSignOut(context);
            },
          ),
        ],
      ),
    );
  }
}
