import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memories_app/providers/profile_photo_provider.dart';
import 'package:memories_app/screens/profile_image_preview_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? username;
  final String? userEmail;
  final String? profileImageUrl;

  const ProfileScreen({
    this.username,
    this.userEmail,
    this.profileImageUrl,
    super.key,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.username ?? '';
  }

  Future<void> _saveUserName() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': _nameController.text,
      });
      setState(() {
        _nameController.text = _nameController.text;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Failed to update username.'),
          ),
        );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _editUsername(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Please enter username',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    await _saveUserName();
                                    if (!mounted) {
                                      return;
                                    }
                                    Navigator.of(context)
                                        .pop(_nameController.text);
                                  },
                            child: const Text('Save'),
                          ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showImagePicker = ref.watch(imagePickerProvider);
    ThemeMode currentThemeMode =
        Theme.of(context).brightness == Brightness.light
            ? ThemeMode.light
            : ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ProfileImagePreview(
                        imageUrl: widget.profileImageUrl!,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: widget.profileImageUrl != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.profileImageUrl!,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : const Color.fromRGBO(5, 178, 74, 1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: () {
                      showImagePicker(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.person,
                size: 30,
                color: currentThemeMode == ThemeMode.dark
                    ? Colors.grey[500]
                    : Colors.black54,
              ),
              title: Text(
                _nameController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'This is the username that you entered while creating account.',
                style: TextStyle(
                  color: currentThemeMode == ThemeMode.dark
                      ? Colors.grey[500]
                      : Colors.black54,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color.fromRGBO(7, 152, 65, 1),
                ),
                onPressed: () => _editUsername(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: ListTile(
              leading: Icon(
                Icons.email,
                size: 30,
                color: currentThemeMode == ThemeMode.dark
                    ? Colors.grey[500]
                    : Colors.black54,
              ),
              title: Text(
                widget.userEmail.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'This is the email that you entered while creating account.',
                style: TextStyle(
                  color: currentThemeMode == ThemeMode.dark
                      ? Colors.grey[500]
                      : Colors.black54,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
