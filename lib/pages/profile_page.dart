import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _userService = UserService();

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  AppUser? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final u = await _userService.getUser(_auth.currentUser!.uid);
    nameController.text = u.name;
    bioController.text = u.bio;
    setState(() {
      user = u;
      isLoading = false;
    });
  }

  Future<void> save() async {
    await _userService.updateProfile(
      user!.id,
      nameController.text,
      bioController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Email: ${user!.email}'),
            Text('Role: ${user!.role}'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
