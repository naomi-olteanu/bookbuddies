import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  void login() async {
    try {
      await _authService.login(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      setState(() {
    error = 'Invalid email or password';
  });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            Text(error, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupPage()),
              ),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
