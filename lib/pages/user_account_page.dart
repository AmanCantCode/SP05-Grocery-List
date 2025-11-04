import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sp_grocery_list/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _email;
  String? _displayName;
  String? _avatarUrl;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _authService.getCurrentUser();
    setState(() {
      _email = user?.email;
      _displayName = user?.userMetadata?['display_name'] ?? 'User';
      _avatarUrl = user?.userMetadata?['avatar_url'];
      _nameController.text = _displayName ?? '';
    });
  }

  Future<void> _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      await _authService.updateDisplayName(newName);
      await _supabase.auth.updateUser(UserAttributes(
        data: {'display_name': newName, 'avatar_url': _avatarUrl},
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully!')),
        );
      }
      setState(() {
        _displayName = newName;
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    final file = File(pickedFile.path);
    final fileExt = file.path.split('.').last;
    final fileName = '${user.id}.$fileExt';

    try {
      await _supabase.storage.from('avatars').upload(fileName, file,
          fileOptions: const FileOptions(upsert: true));

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase.auth.updateUser(
          UserAttributes(data: {'avatar_url': publicUrl, 'display_name': _displayName}));

      setState(() => _avatarUrl = publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFFAAEA61),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Log out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFAAEA61),
                      backgroundImage:
                          _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? Text(
                              (_displayName?.isNotEmpty ?? false)
                                  ? _displayName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _email ?? 'user@example.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'Enter display name',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          _displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(_isEditing ? 'Save Name' : 'Edit Name'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAAEA61),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _isEditing ? _updateDisplayName : () {
                      setState(() => _isEditing = true);
                    },
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
