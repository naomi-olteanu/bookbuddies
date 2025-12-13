import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = AuthService();
  final _userService = UserService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signup() async {
    final cred = await _authService.register(
      emailController.text,
      passwordController.text,
    );

    final user = AppUser(
      id: cred.user!.uid,
      name: nameController.text,
      email: emailController.text,
      role: 'user',
      rating: 0.0,
      favors: 10,
      bio: '',
      profilePicture: '',
      ratingSum: 0,
      ratingCount: 0,
    );

    await _userService.createUser(user);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: signup, child: const Text('Signup')),
          ],
        ),
      ),
    );
  }
}
